%% Plots de Presion del nodo bomba & caudal de bomba vs tiempo.

for iBomba = 1:bombaProperties.nBombas
    
tInicioISIPLocal = temporalProperties.tInicioISIP(iBomba);
tFinalISIPLocal = temporalProperties.tFinalISIP(iBomba);

% subplot(1,bombaProperties.nBombas,iBomba);
figure('Name',sprintf("Bomba %d",iBomba));

indiceTiempo = temporalProperties.drainTimes+1:temporalProperties.nTimes;
tiempo = cumsum(temporalProperties.deltaTs(indiceTiempo));
%- Plot: Presion nodo bomba calculado por FEA.
pFEA = zeros(1,temporalProperties.nTimes);
for iTime = 1:temporalProperties.nTimes
    pTime           = dTimes(paramDiscEle.nDofTot_U+1:paramDiscEle.nDofTot_U+paramDiscEle.nDofTot_P,iTime)*temporalProperties.preCond;
    pFEA(iTime)     = pTime(bombaProperties.nodoBomba(1));    % Presion en el nodo Bomba calculada por FEA en cada iTime.
end

% Presion vs tiempo durante proceso de fractura.
% figure
subplot(1,3,1)
% iTimeInicioISIP = sum(tiempo<=tInicioISIPLocal)+temporalProperties.drainTimes;
iTimeInicioISIP = sum(tiempo<=tInicioISIPLocal)+temporalProperties.drainTimes;
scatter(tiempo(1:iTimeInicioISIP-temporalProperties.drainTimes),pFEA(temporalProperties.drainTimes+1:iTimeInicioISIP)*1e6/6894.76);
title('Presion y Q durante fractura')
ylabel('Presion FEA [Psi]')
% xlabel('tiempo [s]')
minimo = min(pFEA(temporalProperties.drainTimes+1:iTimeInicioISIP))*1e6/6894.76;
maximo = max(pFEA(temporalProperties.drainTimes+1:iTimeInicioISIP))*1e6/6894.76;
ylim([minimo maximo])
xlim([0 tInicioISIPLocal])
grid
yyaxis right
plot(tiempo(1:iTimeInicioISIP-temporalProperties.drainTimes),QTimes(bombaProperties.nodoBomba(1),temporalProperties.drainTimes+1:iTimeInicioISIP))


% Presion vs tiempo con bomba apagada.
subplot(1,3,2)
iTimeInicioISIP = sum(tiempo<=tInicioISIPLocal)+temporalProperties.drainTimes;
iTimeFinalISIP = sum(tiempo<=tFinalISIPLocal)+temporalProperties.drainTimes;
scatter(tiempo(iTimeInicioISIP-temporalProperties.drainTimes:iTimeFinalISIP-temporalProperties.drainTimes),pFEA(iTimeInicioISIP:iTimeFinalISIP)*1e6/6894.76);
title('Presion y Q con bomba apagada')
% ylabel('Presion FEA [Psi]')
xlabel('tiempo [s]')
minimo = min(pFEA(iTimeInicioISIP:iTimeFinalISIP))*1e6/6894.76;
maximo = max(pFEA(iTimeInicioISIP:iTimeFinalISIP))*1e6/6894.76;
ylim([minimo maximo])
xlim([tInicioISIPLocal, tFinalISIPLocal])
grid
yyaxis right
plot(tiempo(iTimeInicioISIP-temporalProperties.drainTimes:iTimeFinalISIP-temporalProperties.drainTimes),QTimes(bombaProperties.nodoBomba(1),iTimeInicioISIP:iTimeFinalISIP))


% Presion vs tiempo durante produccion.
subplot(1,3,3)
iTimeFinalISIP = sum(tiempo<=tFinalISIPLocal)+temporalProperties.drainTimes;
scatter(tiempo(iTimeFinalISIP-temporalProperties.drainTimes:end),pFEA(iTimeFinalISIP:end)*1e6/6894.76);
title('Presion y Q durante produccion')
% ylabel('Presion FEA [Psi]')
% xlabel('tiempo [s]')
minimo = min(pFEA(iTimeFinalISIP:end))*1e6/6894.76;
maximo = max(pFEA(iTimeFinalISIP:end))*1e6/6894.76;
ylim([minimo maximo])
xlim([tFinalISIPLocal tiempo(end)])
grid
yyaxis right
plot(tiempo(iTimeFinalISIP-temporalProperties.drainTimes:end),QTimes(bombaProperties.nodoBomba(1),iTimeFinalISIP:end))
ylim([QTimes(bombaProperties.nodoBomba(1),end)*1.1 0])
ylabel('Q [BPM] ')

end
