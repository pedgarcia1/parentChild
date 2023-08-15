%-------------------------------------------------------------------------%
%%%                              TENSIONES                              %%%
%-------------------------------------------------------------------------%
indiceTiempo = temporalProperties.drainTimes+1:temporalProperties.nTimes;
tiempo = cumsum(temporalProperties.deltaTs(indiceTiempo));
iTimeEspecifico = sum(tiempo <= tiempoTensiones) + temporalProperties.drainTimes;
%- Tensiones. (Solo esta calculando para un tiempo en particular)
unod = pGaussParam.upg; 
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
             presionEfectivaPG(iele,nP,:) = (N*pressureTimes(meshInfo.elements(iele,:)))';
        end
    end
end


tensionEfectivaPG =  presionEfectivaPG;
mPa2psi           = 145;
  

%% PLOTS DE TENSIONES SIN PROMEDIAR.

plotElemental(meshInfo.nodes,meshInfo.elements,tensionEfectivaPG(:,:,1)*mPa2psi,'Y','Presiones Sin Promediar','x [mm]','y [mm]','z [mm]','Pp [psi]')


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



