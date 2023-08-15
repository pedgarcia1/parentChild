% Timesteps y tiempos importantes
nfracturas=2;
indiceTiempo = temporalProperties.drainTimes+1:temporalProperties.nTimes; %timesteps desde que inicia la fractura hasta que termina la produccion
tiempo = cumsum(temporalProperties.deltaTs(indiceTiempo)); %tiempo [s] de cada timestep
iTimeInicioFrac(1)=temporalProperties.drainTimes+1; %timestep en el que inicia de fractura
for i=1:nfracturas    
    iTimeInicioISIP(i)=temporalProperties.drainTimes+find(tiempo>=temporalProperties.tInicioISIP(i),1); %timestep en el que inicia el isip
    iTimeInicioProd(i)=temporalProperties.drainTimes+find(tiempo>=temporalProperties.tInicioProduccion(i),1); %timestep en el que inicia la produccion
end
iTimeInicioFrac(2)=iTimeInicioISIP(1)+1;

% Plot de volumen de liquido que entro por el nodo bomba vs timesteps
volDeLiquidoAcumuladoDeltaTs = -cumsum(temporalProperties.deltaTs(iTimeInicioFrac(1):end-1).*sum(QTimes(bombaProperties.nodoBomba,iTimeInicioFrac(1):end))); %hace deltaT * caudal en bpm. Y hace el cumsum de eso.
volDeLiquidoAcumuladoDeltaTs = volDeLiquidoAcumuladoDeltaTs/60; %para pasar de bpm*seg, a barriles acumulados

figure
plot((1:length(volDeLiquidoAcumuladoDeltaTs))+temporalProperties.drainTimes,volDeLiquidoAcumuladoDeltaTs);
xlabel('timesteps');ylabel('Barriles acumulados');title('Barriles inyectados vs timesteps');grid on

% Plot de volumen de liquido que entro por el nodo bomba vs tiempo fisico
figure
semilogx(tiempo((iTimeInicioFrac:temporalProperties.nTimes)-temporalProperties.drainTimes),volDeLiquidoAcumuladoDeltaTs);
xlabel('tiempo [s]');ylabel('Barriles acumulados');title('Barriles inyectados vs tiempo');grid on

figure
plot(tiempo((iTimeInicioFrac:temporalProperties.nTimes)-temporalProperties.drainTimes),volDeLiquidoAcumuladoDeltaTs);
xlabel('tiempo [s]');ylabel('Barriles acumulados');title('Barriles inyectados vs tiempo');grid on
