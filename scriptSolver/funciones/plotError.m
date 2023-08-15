clf
subplot(1,3,1)
plot(errorRelU{iTime}(:,:),'o-r')
hold on
plot(ones(1,nIter)*algorithmProperties.toleranciaU,'--r')
legend('error U','cota')
grid
ylim([-0.01 algorithmProperties.toleranciaU*100])

subplot(1,3,2)
plot(errorRelP{iTime}(:,:),'o-b')
hold on
plot(ones(1,nIter)*algorithmProperties.toleranciaP,'--b')
legend('error P','cota')
title(['Errores en cada iteracion. iTime: ',num2str(iTime)])
grid
ylim([-0.01 algorithmProperties.toleranciaP*100])

subplot(1,3,3)
plot(errorRelCohesivos{iTime}(:,:),'o-g')
hold on
plot(ones(1,nIter)*algorithmProperties.toleranciaCohesivos,'--g')
legend('error Cohesivos','cota')
grid
ylim([-0.01 algorithmProperties.toleranciaCohesivos*100])

drawnow