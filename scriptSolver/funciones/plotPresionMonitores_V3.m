%% Plots de Presion del nodo bomba vs tiempo.
autoLimXY = 1; % limites X e Y, false automaticos, true calculados segun tiempo de fractura o produccion segun corresponda

tInicioISIPLocal = temporalProperties.tInicioISIP(1);
tFinalISIPLocal = temporalProperties.tFinalISIP(1);
legendHandles = [];
figure;
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
legendString{iNodo} = sprintf('Nodo Monitor %d',iNodo);
subplot(1,3,1); hold on;
% posAux = monitoresProperties.posNodos(iNodo,:);
% annotation( 'textbox' , [0.5 0.5 0.25 0.25] ,'String',sprintf('idNodo %d - posNodo [%d,%d,%d]',monitoresProperties.nodoMonitores(iNodo),posAux(1),posAux(2),posAux(3)) );
iTimeInicioISIP = sum(tiempo<=tInicioISIPLocal)+temporalProperties.drainTimes;
% auxHandle = scatter(tiempo(1:iTimeInicioISIP-temporalProperties.drainTimes),pFEA(temporalProperties.drainTimes+1:iTimeInicioISIP)*1e6/6894.76);
auxHandle = plot(tiempo(1:iTimeInicioISIP-temporalProperties.drainTimes),pFEA(temporalProperties.drainTimes+1:iTimeInicioISIP)*1e6/6894.76);
legendHandles = [legendHandles,auxHandle];
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
subplot(1,3,2); hold on;
iTimeInicioISIP = sum(tiempo<=tInicioISIPLocal)+temporalProperties.drainTimes;
iTimeFinalISIP = sum(tiempo<=tFinalISIPLocal)+temporalProperties.drainTimes;
plot(tiempo(iTimeInicioISIP-temporalProperties.drainTimes:iTimeFinalISIP-temporalProperties.drainTimes),pFEA(iTimeInicioISIP:iTimeFinalISIP)*1e6/6894.76);
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
f = subplot(1,3,3); hold on;
iTimeFinalISIP = sum(tiempo<=tFinalISIPLocal)+temporalProperties.drainTimes;
plot(tiempo(iTimeFinalISIP-temporalProperties.drainTimes:end),pFEA(iTimeFinalISIP:end)*1e6/6894.76);
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
legend(f,legendHandles,legendString,'Location','bestoutside');

figure
legendHandles = [];
hold on
plotMeshColo3D(meshInfo.nodes,meshInfo.elements,meshInfo.cohesivos.elements,'on','on','w','r','k',0.05); % Se plotea la malla
for iNodo = 1:monitoresProperties.nNodos
    aux = scatter3(monitoresProperties.posNodos(iNodo,1),monitoresProperties.posNodos(iNodo,2),monitoresProperties.posNodos(iNodo,3),'filled','LineWidth',10,'MarkerFaceAlpha', 1);
    legendHandles = [legendHandles,aux];
end
legend(legendHandles,legendString,'Location','bestoutside');
