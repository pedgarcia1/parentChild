figure
hold on
indiceTiempo   = temporalProperties.drainTimes+1:temporalProperties.nTimes;
tiempo         = cumsum(temporalProperties.deltaTs(indiceTiempo));
iTimeFinalISIP = sum(tiempo<=temporalProperties.tFinalISIP) + temporalProperties.drainTimes;
nFrac          = numel(bombaProperties.nodoBomba);
for iFrac = 1:nFrac
    plot(tiempo(iTimeFinalISIP-temporalProperties.drainTimes:end),QTimes(bombaProperties.nodoBomba(iFrac),iTimeFinalISIP:end),'-')
end


if nFrac == 1 % Si hay una sola fractura el caudal total vale lo mismo que el caudal de esa unica fractura.
    QTotal = QTimes(bombaProperties.nodoBomba(iFrac),iTimeFinalISIP:end);
else
    QTotal = sum(QTimes(bombaProperties.nodoBomba(:),iTimeFinalISIP:end));
end

plot(tiempo(iTimeFinalISIP-temporalProperties.drainTimes:end),QTotal,'-')
title('Caudal durante produccion')

leyenda = {};
for iFrac = 1:nFrac
    leyenda{iFrac,1} = ['Q Frac: ',num2str(iFrac)];
end
leyenda = [leyenda;{'Q Total'}];
legend(leyenda{:})

ylim([QTotal(end)*1.5 QTimes(bombaProperties.nodoBomba(iFrac),end)/1.1])
xlim([temporalProperties.tFinalISIP tiempo(end)])
ylabel('Q [BPM] ')
xlabel('tiempo [s]')
grid

