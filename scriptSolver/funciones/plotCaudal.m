%% Plots de caudal de bomba vs tiempo.
indiceTiempo = temporalProperties.drainTimes+1:temporalProperties.nTimes;
tiempo = cumsum(temporalProperties.deltaTs(indiceTiempo));
iTimeInicioISIP = sum(tiempo<=temporalProperties.tInicioISIP)+temporalProperties.drainTimes;

BPM2mm3s = 0.00264979 * (1000)^3;
figure
plot(bombaProperties.tbombasOG, bombaProperties.QbombasOG,'-')
hold on
plot(bombaProperties.tbombas, bombaProperties.Qbombas/0.00264979 / (1000)^3,'-')
title('Q Bomba vs tiempo')
xlabel('Tiempo[s]')
ylabel('Q [BPM]')
legend('Q de entrada','Q suavizado');
xlim([0 temporalProperties.tInicioISIP])
grid


