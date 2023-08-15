%- Tensiones. (Solo esta calculando para un tiempo en particular)
unod = pGaussParam.upg; 
%- Presiones efectivas.
presionEfectiva = zeros(paramDiscEle.nel,paramDiscEle.nNodEl,6);
for iTime = iTimeEspecifico
    pressureTimes = dTimes(paramDiscEle.nDofTot_U+1:paramDiscEle.nDofTot_U+paramDiscEle.nDofTot_P,iTime)*temporalProperties.preCond;
    for iEle = 1:paramDiscEle.nel
        for nP = 1:size(unod,1)
            
            ksi  = unod(nP,1);
            eta  = unod(nP,2);
            zeta = unod(nP,3);
            
            % Funciones de forma

            N = [ (1-ksi)*(1-eta)*(1+zeta)/8, (1-ksi)*(1-eta)*(1-zeta)/8, (1-ksi)*(1+eta)*(1-zeta)/8.... 
                  (1-ksi)*(1+eta)*(1+zeta)/8, (1+ksi)*(1-eta)*(1+zeta)/8, (1+ksi)*(1-eta)*(1-zeta)/8....
                  (1+ksi)*(1+eta)*(1-zeta)/8, (1+ksi)*(1+eta)*(1+zeta)/8 ];
            
            N = N(1,[8,4,1,5,7,3,2,6]);   
            
            presionEfectiva(iEle,nP,:) = (N*pressureTimes(meshInfo.elements(iEle,:)))'/physicalProperties.poroelasticas.pPoral;
        end
    end
end


tensionEfectiva = presionEfectiva;

 %% Exptrapolacion de valores en puntos de gauss a nodos.
  % Para plotear necesito los valores nodales asique extrapolo los
  % valores en los puntos de gauss a los nodos y hago el promedio de cada
  % elementos.
  unodNodal            = pGaussParam.upg*3;
  tensionEfectivaNodal = zeros(paramDiscEle.nel,8,6) ; 
  
  for iEle = 1:paramDiscEle.nel
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
          tensionEfectivaNodal(iEle,ipg,1) = N*tensionEfectiva(iEle,:,1)';
          tensionEfectivaNodal(iEle,ipg,2) = N*tensionEfectiva(iEle,:,2)';
          tensionEfectivaNodal(iEle,ipg,3) = N*tensionEfectiva(iEle,:,3)';
          tensionEfectivaNodal(iEle,ipg,4) = N*tensionEfectiva(iEle,:,4)';
          tensionEfectivaNodal(iEle,ipg,5) = N*tensionEfectiva(iEle,:,5)';
          tensionEfectivaNodal(iEle,ipg,6) = N*tensionEfectiva(iEle,:,6)';
      end
  end
 
 
 % Promedio de tensiones nodales.
  avgStress = zeros(paramDiscEle.nDofTot_P,6); % Descuenta la presion efectiva de las tensiones.
  for inode = 1:paramDiscEle.nDofTot_P
      [I,J] = find(meshInfo.elements == inode);
      nShare = length(I);
      for ishare = 1:nShare
          avgStress(inode,:) = avgStress(inode,:) + squeeze(tensionEfectivaNodal(I(ishare),J(ishare),:))';
      end
      avgStress(inode,:) = avgStress(inode,:) / nShare;
  end

%% PLOTS DE TENSIONES PROMEDIADAS.
plotColo3D(meshInfo.nodes(1:paramDiscEle.nDofTot_P,:),meshInfo.elements,avgStress(:,1))
title(['iTime: ',num2str(iTimeEspecifico)]);





