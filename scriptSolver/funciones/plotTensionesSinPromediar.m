%-------------------------------------------------------------------------%
%%%                              TENSIONES                              %%%
%-------------------------------------------------------------------------%
indiceTiempo = temporalProperties.drainTimes+1:temporalProperties.nTimes;
tiempo = cumsum(temporalProperties.deltaTs(indiceTiempo));
iTimeEspecifico = sum(tiempo <= tiempoTensiones) + temporalProperties.drainTimes;
%- Tensiones. (Solo esta calculando para un tiempo en particular)
unod = pGaussParam.upg; 
stressPG = zeros(paramDiscEle.nel,paramDiscEle.nNodEl,6);%cell(nnodel,size(constitutivas{1},1),nel,length(Time));
for itime = iTimeEspecifico
    for iele = 1:paramDiscEle.nel 
        nodesEle = meshInfo.nodes(meshInfo.elements(iele,:),:);

        for npg = 1:size(unod,1)
        
            % Puntos nodales
            ksi  = unod(npg,1);
            eta  = unod(npg,2);
            zeta = unod(npg,3);

            % Derivadas de las funciones de forma respecto de ksi, eta, zeta         
  
            % Derivadas de las funciones de forma respecto de ksi, eta, zeta
            dN = [ ((eta - 1)*(zeta + 1))/8, -((eta - 1)*(zeta - 1))/8, ((eta + 1)*(zeta - 1))/8, -((eta + 1)*(zeta + 1))/8, -((eta - 1)*(zeta + 1))/8, ((eta - 1)*(zeta - 1))/8, -((eta + 1)*(zeta - 1))/8, ((eta + 1)*(zeta + 1))/8
                ((ksi - 1)*(zeta + 1))/8, -((ksi - 1)*(zeta - 1))/8, ((ksi - 1)*(zeta - 1))/8, -((ksi - 1)*(zeta + 1))/8, -((ksi + 1)*(zeta + 1))/8, ((ksi + 1)*(zeta - 1))/8, -((ksi + 1)*(zeta - 1))/8, ((ksi + 1)*(zeta + 1))/8
                ((eta - 1)*(ksi - 1))/8,  -((eta - 1)*(ksi - 1))/8,  ((eta + 1)*(ksi - 1))/8,  -((eta + 1)*(ksi - 1))/8,  -((eta - 1)*(ksi + 1))/8,  ((eta - 1)*(ksi + 1))/8,  -((eta + 1)*(ksi + 1))/8,  ((eta + 1)*(ksi + 1))/8 ];
            
            dN = dN(:,[8,4,1,5,7,3,2,6]);

            jac = dN*nodesEle;                

            % Derivadas de las funciones de forma respecto de x,y,z
            dNxyz = jac\dN;          % dNxyz = inv(jac)*dN
            
            B = zeros(6,paramDiscEle.nDofEl);

            B(1,1:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(1,:);
            B(2,2:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(2,:); 
            B(3,3:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(3,:);
            B(4,1:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(2,:);
            B(4,2:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(1,:);
            B(5,2:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(3,:);
            B(5,3:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(2,:);
            B(6,1:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(3,:);
            B(6,3:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(1,:);

            eleDofs = paramDiscEle.nodeDofs(meshInfo.elements(iele,:),:);
            eleDofs = reshape(eleDofs',[],1);

            stressPG(iele,npg,:) = (constitutivas{iele}(:,:,npg))*B*dTimes(eleDofs,itime) + initialStressSolPG{iele}(:,npg);
            
%             stress(iele,npg,:) = (constitutivas{iele}(:,:,npg))*B*dTimes(eleDofs,itime);
        end
    end
end

%- Presiones efectivas.
presionEfectivaPG = zeros(paramDiscEle.nel,paramDiscEle.nNodEl,6);
for iTime = iTimeEspecifico
    pressureTimes = dTimes(paramDiscEle.nDofTot_U+1:paramDiscEle.nDofTot_U+paramDiscEle.nDofTot_P,iTime)*temporalProperties.preCond;
    for iele = 1:paramDiscEle.nel
        for nP = 1:size(unod,1)
            
            ksi  = unod(nP,1);
            eta  = unod(nP,2);
            zeta = unod(nP,3);
            
            % Funciones de forma

            N = [ (1-ksi)*(1-eta)*(1+zeta)/8, (1-ksi)*(1-eta)*(1-zeta)/8, (1-ksi)*(1+eta)*(1-zeta)/8.... 
                  (1-ksi)*(1+eta)*(1+zeta)/8, (1+ksi)*(1-eta)*(1+zeta)/8, (1+ksi)*(1-eta)*(1-zeta)/8....
                  (1+ksi)*(1+eta)*(1-zeta)/8, (1+ksi)*(1+eta)*(1+zeta)/8 ];
            
            N = N(1,[8,4,1,5,7,3,2,6]);   
            
%             presionEfectiva(iele,nP,:) = (Biot{iele}(:,:,nP)*N*pressureTimes(meshInfo.elements(iele,:)))'+ (Biot{iele}(:,:,nP)*initialPPoral)';
             presionEfectivaPG(iele,nP,:) = (Biot{iele}(:,:,nP)*N*pressureTimes(meshInfo.elements(iele,:)))';
        end
    end
end


tensionEfectivaPG = stressPG - presionEfectivaPG;
% tensionEfectivaPG = stressPG;

 %% Exptrapolacion de valores en puntos de gauss a nodos.
  % Para plotear necesito los valores nodales asique extrapolo los
  % valores en los puntos de gauss a los nodos y hago el promedio de cada
  % elementos.
  unodNodal            = pGaussParam.upg*3;
  tensionEfectivaNodal = zeros(paramDiscEle.nel,8,6) ; 
  
  for iele = 1:paramDiscEle.nel
      for ipg = 1:size(unodNodal,1)
          
          ksi  = unodNodal(ipg,1);
          eta  = unodNodal(ipg,2);
          zeta = unodNodal(ipg,3);
          
          % Funciones de forma
          N = [ (1-ksi)*(1-eta)*(1+zeta)/8, (1-ksi)*(1-eta)*(1-zeta)/8, (1-ksi)*(1+eta)*(1-zeta)/8....
              (1-ksi)*(1+eta)*(1+zeta)/8, (1+ksi)*(1-eta)*(1+zeta)/8, (1+ksi)*(1-eta)*(1-zeta)/8....
              (1+ksi)*(1+eta)*(1-zeta)/8, (1+ksi)*(1+eta)*(1+zeta)/8 ];
          
          N = N(1,[8,4,1,5,7,3,2,6]);
          % Extrapolacion de puntos de gauss a nodos.
          tensionEfectivaNodal(iele,ipg,1) = N*tensionEfectivaPG(iele,:,1)';
          tensionEfectivaNodal(iele,ipg,2) = N*tensionEfectivaPG(iele,:,2)';
          tensionEfectivaNodal(iele,ipg,3) = N*tensionEfectivaPG(iele,:,3)';
          tensionEfectivaNodal(iele,ipg,4) = N*tensionEfectivaPG(iele,:,4)';
          tensionEfectivaNodal(iele,ipg,5) = N*tensionEfectivaPG(iele,:,5)';
          tensionEfectivaNodal(iele,ipg,6) = N*tensionEfectivaPG(iele,:,6)';
      end
  end
 
% mPa a psi/ft, estando a 2935 m de profundidad.
meter2feet = 3.28;
mPa2psi    = 145;
depthMalla = 2953; % metros de profundidad       

%% PLOTS DE TENSIONES SIN PROMEDIAR.

plotElemental(meshInfo.nodes,meshInfo.elements,tensionEfectivaPG(:,:,1)*mPa2psi,'Y','Tensiones Sin Promediar','x [mm]','y [mm]','z [mm]','Sx [psi]')
plotElemental(meshInfo.nodes,meshInfo.elements,tensionEfectivaPG(:,:,2)*mPa2psi,'Y','Tensiones Sin Promediar','x [mm]','y [mm]','z [mm]','Sy [psi]')
plotElemental(meshInfo.nodes,meshInfo.elements,tensionEfectivaPG(:,:,3)*mPa2psi,'Y','Tensiones Sin Promediar','x [mm]','y [mm]','z [mm]','Sz [psi]')
plotElemental(meshInfo.nodes,meshInfo.elements,tensionEfectivaPG(:,:,4)*mPa2psi,'Y','Tensiones Sin Promediar','x [mm]','y [mm]','z [mm]','Tauxy [psi]')
plotElemental(meshInfo.nodes,meshInfo.elements,tensionEfectivaPG(:,:,5)*mPa2psi,'Y','Tensiones Sin Promediar','x [mm]','y [mm]','z [mm]','Tauyz [psi]')
plotElemental(meshInfo.nodes,meshInfo.elements,tensionEfectivaPG(:,:,6)*mPa2psi,'Y','Tensiones Sin Promediar','x [mm]','y [mm]','z [mm]','Tauxz [psi]')

% gradientesPG = -1*mPa2psi*tensionEfectivaPG/(2953*3.28);
% plotElemental(meshInfo.nodes,meshInfo.elements,gradientesPG(:,:,1),'Y','Gradiente de Tensiones','x [mm]','y [mm]','z [mm]','S_x [psi/ft]')
% plotElemental(meshInfo.nodes,meshInfo.elements,gradientesPG(:,:,2),'Y','Gradiente de Tensiones','x [mm]','y [mm]','z [mm]','S_y [psi/ft]')
% plotElemental(meshInfo.nodes,meshInfo.elements,gradientesPG(:,:,3),'Y','Gradiente de Tensiones','x [mm]','y [mm]','z [mm]','S_z [psi/ft]')

% gradientesPG = -1*mPa2psi*tensionEfectivaPG/(2953*3.28);
% plotElemental(meshInfo.nodes,meshInfo.elements,gradientesPG(:,:,1),'N',[],[],[],[],[])
% set(gca,'xtick',[],'ytick',[],'ztick',[])

% plotElemental(meshInfo.nodes,meshInfo.elements,tensionEfectivaPG(:,:,1),'Y','Tensiones Sin Promediar','x [mm]','y [mm]','z [mm]','Sx [MPa]')
% plotElemental(meshInfo.nodes,meshInfo.elements,tensionEfectivaPG(:,:,2),'Y','Tensiones Sin Promediar','x [mm]','y [mm]','z [mm]','Sy [MPa]')
% plotElemental(meshInfo.nodes,meshInfo.elements,tensionEfectivaPG(:,:,3),'Y','Tensiones Sin Promediar','x [mm]','y [mm]','z [mm]','Sz [MPa]')



