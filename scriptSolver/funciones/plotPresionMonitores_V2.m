%% Plots de Presion del nodo bomba vs tiempo.
autoLimXY = 1; % limites X e Y, false automaticos, true calculados segun tiempo de fractura o produccion segun corresponda

tInicioISIPLocal = temporalProperties.tInicioISIP(1);
tFinalISIPLocal = temporalProperties.tFinalISIP(1);

for iNodo = 1:monitoresProperties.nNodos

indiceTiempo = temporalProperties.drainTimes+1:temporalProperties.nTimes;
tiempo = cumsum(temporalProperties.deltaTs(indiceTiempo));
%- Plot: Presion nodo bomba calculado por FEA.
pFEA = zeros(1,temporalProperties.nTimes);
for iTime = 1:temporalProperties.nTimes
    pTime           = dTimes(paramDiscEle.nDofTot_U+1:paramDiscEle.nDofTot_U+paramDiscEle.nDofTot_P,iTime)*temporalProperties.preCond;
    pFEA(iTime)     = pTime(monitoresProperties.nodoMonitores(iNodo));    % Presion en el nodo Monitores calculada por FEA en cada iTime.
end

% Presion vs tiempo durante proceso de fractura. 'String' ,sprintf('idNodo %d - posNodo [%d,%d,%d]',monitoresProperties.nodoMonitores(iNodo),posAux(1),posAux(2),posAux(3)) 
figure('Name',sprintf('Nodo Monitor %d',iNodo));
subplot(1,3,1)
% posAux = monitoresProperties.posNodos(iNodo,:);
% annotation( 'textbox' , [0.5 0.5 0.25 0.25] ,'String',sprintf('idNodo %d - posNodo [%d,%d,%d]',monitoresProperties.nodoMonitores(iNodo),posAux(1),posAux(2),posAux(3)) );
iTimeInicioISIP = sum(tiempo<=tInicioISIPLocal)+temporalProperties.drainTimes;
scatter(tiempo(1:iTimeInicioISIP-temporalProperties.drainTimes),pFEA(temporalProperties.drainTimes+1:iTimeInicioISIP)*1e6/6894.76);
title('Presion durante fractura')
ylabel('Presion FEA [Psi]')
% xlabel('tiempo [s]')
minimo = min(pFEA(temporalProperties.drainTimes+1:iTimeInicioISIP))*1e6/6894.76;
maximo = max(pFEA(temporalProperties.drainTimes+1:iTimeInicioISIP))*1e6/6894.76;
if minimo < maximo && ~autoLimXY % agreago if porque si no completo la corrida a veces minimo = maximo y tiran error, si la corrida termino deberian funcionar bien
    ylim([minimo maximo])
    xlim([0 tInicioISIPLocal])
end
grid 
% Presion vs tiempo con bomba apagada.
subplot(1,3,2)
iTimeInicioISIP = sum(tiempo<=tInicioISIPLocal)+temporalProperties.drainTimes;
iTimeFinalISIP = sum(tiempo<=tFinalISIPLocal)+temporalProperties.drainTimes;
scatter(tiempo(iTimeInicioISIP-temporalProperties.drainTimes:iTimeFinalISIP-temporalProperties.drainTimes),pFEA(iTimeInicioISIP:iTimeFinalISIP)*1e6/6894.76);
title('Presion con bomba apagada')
% ylabel('Presion FEA [Psi]')
xlabel('tiempo [s]')
minimo = min(pFEA(iTimeInicioISIP:iTimeFinalISIP))*1e6/6894.76;
maximo = max(pFEA(iTimeInicioISIP:iTimeFinalISIP))*1e6/6894.76;
if minimo < maximo && ~autoLimXY
    ylim([minimo maximo])
    xlim([tInicioISIPLocal, tFinalISIPLocal])
end
grid

% Presion vs tiempo durante produccion.
subplot(1,3,3)
iTimeFinalISIP = sum(tiempo<=tFinalISIPLocal)+temporalProperties.drainTimes;
scatter(tiempo(iTimeFinalISIP-temporalProperties.drainTimes:end),pFEA(iTimeFinalISIP:end)*1e6/6894.76);
title('Presion durante produccion')
% ylabel('Presion FEA [Psi]')
% xlabel('tiempo [s]')
minimo = min(pFEA(iTimeFinalISIP:end))*1e6/6894.76;
maximo = max(pFEA(iTimeFinalISIP:end))*1e6/6894.76;
if minimo < maximo && ~autoLimXY
    ylim([minimo maximo])
    xlim([tFinalISIPLocal tiempo(end)])
end
grid

end