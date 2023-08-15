%% Plots Area de Fractura.
% Nota: Los elementos que poseen nodos en la interseccion solo suman una
% vez que sus 4 nodos se encuentren rotos.

for iBomba = 1:bombaProperties.nBombas
    
tInicioISIPLocal = temporalProperties.tInicioISIP(iBomba);
tFinalISIPLocal = temporalProperties.tFinalISIP(iBomba);

% subplot(1,bombaProperties.nBombas,iBomba);
figure('Name',sprintf("Bomba %d",iBomba));

% Calculo de area de fractura.
areaPTimes   = zeros(temporalProperties.nTimes,1); % Area de fractura Vertical.
areaSTimes   = zeros(temporalProperties.nTimes,1); % Area de fractura Horizontal.
volPTimes    = zeros(temporalProperties.nTimes,1); % Volumen de fractura Vertical.
volSTimes    = zeros(temporalProperties.nTimes,1); % Volumen de fractura Horizontal.
areaPG       = zeros(meshInfo.nCohesivos,4);
nodosMuertos = meshInfo.cohesivos.deadFlagTimes;
meshInfo.cohesivos.dNCalculado
for iCohesivo = 1:meshInfo.nCohesivos
    areaPG(iCohesivo,:) = getJac(meshInfo.cohesivos,iCohesivo);
end

for iTime = 1:temporalProperties.nTimes
    areaPrim = 0;
    areaSec  = 0;
    volPrim = 0;
    volSec  = 0;
    
    for iCohesivo = 1:meshInfo.nCohesivos
        area                    = sum(nodosMuertos(iCohesivo,:,iTime).*areaPG(iCohesivo,:));
        volMsk                  = meshInfo.cohesivos.dNTimes(iCohesivo,:,iTime) > 0;
        vol                     = sum(nodosMuertos(iCohesivo,volMsk,iTime).*areaPG(iCohesivo,volMsk).*meshInfo.cohesivos.dNTimes(iCohesivo,volMsk,iTime));
            
        if sum(ismember(meshInfo.cohesivos.elements(iCohesivo,:),meshInfo.elementsBarra.X1)) > 2 % Elementos en el plano vertical pero sin nodos en la interseccion.  
            areaPrim            = areaPrim + area;
            volPrim             = volPrim + vol;
            
        elseif sum(ismember(meshInfo.cohesivos.elements(iCohesivo,:),meshInfo.elementsBarra.Z1)) > 2 || ...
               sum(ismember(meshInfo.cohesivos.elements(iCohesivo,:),meshInfo.elementsBarra.Z2)) > 2 || ...
               sum(ismember(meshInfo.cohesivos.elements(iCohesivo,:),meshInfo.elementsBarra.Z3)) > 2 % Elementos en los planos horizontales pero sin nodos en la interseccion.            
           areaSec              = areaSec + area;
           volSec               = volSec + vol;
           
        elseif (sum(ismember(meshInfo.cohesivos.elements(iCohesivo,:),meshInfo.elementsBarra.Y)) + sum(ismember(meshInfo.cohesivos.elements(iCohesivo,:),meshInfo.elementsBarra.INT))) > 2  % Elementos en el plano vertical pero con nodos en la interseccion.
            if all(nodosMuertos(iCohesivo,:,iTime))
                areaPrim        = areaPrim + area;
                volPrim         = volPrim + vol;
            else
                nodosNoIntersec = ~ismember(meshInfo.cohesivos.elements(iCohesivo,:),meshInfo.elementsBarra.INT);
                area            = sum(nodosMuertos(iCohesivo,nodosNoIntersec,iTime).*areaPG(iCohesivo,nodosNoIntersec));
                vol             = sum(nodosMuertos(iCohesivo,nodosNoIntersec & volMsk,iTime).*areaPG(iCohesivo,nodosNoIntersec & volMsk).*meshInfo.cohesivos.dNTimes(iCohesivo,nodosNoIntersec & volMsk,iTime));
                
                areaPrim        = areaPrim + area;
                volPrim         = volPrim + vol;
                
            end

        else % Elementos en el plano horizontal pero con nodos en la interseccion.
            if all(nodosMuertos(iCohesivo,:,iTime))
                areaSec         = areaSec + area;
            else
                nodosNoIntersec = ~ismember(meshInfo.cohesivos.elements(iCohesivo,:),meshInfo.elementsBarra.INT);
                area            = sum(nodosMuertos(iCohesivo,nodosNoIntersec,iTime).*areaPG(iCohesivo,nodosNoIntersec));
                vol             = sum(nodosMuertos(iCohesivo,nodosNoIntersec & volMsk,iTime).*areaPG(iCohesivo,nodosNoIntersec & volMsk).*meshInfo.cohesivos.dNTimes(iCohesivo,nodosNoIntersec & volMsk,iTime));
               
                areaSec         = areaSec + area;
                volSec          = volSec + vol;
                
            end

        end 
    end    
    
    areaPTimes(iTime) = areaPrim/1000^2;% Areas en m^2.
    areaSTimes(iTime) = areaSec/1000^2;
    volPTimes(iTime)  = volPrim/1000^3;% Volumen en m^3.
    volSTimes(iTime)  = volSec/1000^3;

end

% Plot area de factura vs tiempo.
indiceTiempo    = temporalProperties.drainTimes+1:temporalProperties.nTimes;
tiempo          = cumsum(temporalProperties.deltaTs(indiceTiempo));
iTimeInicioISIP = sum(tiempo<=tInicioISIPLocal)+temporalProperties.drainTimes;

% figure
subplot(1,3,1)
plot(tiempo(1:iTimeInicioISIP-temporalProperties.drainTimes),areaPTimes(temporalProperties.drainTimes+1:iTimeInicioISIP),'-r');
hold on
plot(tiempo(1:iTimeInicioISIP-temporalProperties.drainTimes),areaSTimes(temporalProperties.drainTimes+1:iTimeInicioISIP),'-b');
ylabel('Area [m^2]')
yyaxis right
plot(tiempo(1:iTimeInicioISIP-temporalProperties.drainTimes),volPTimes(temporalProperties.drainTimes+1:iTimeInicioISIP),'--r');
plot(tiempo(1:iTimeInicioISIP-temporalProperties.drainTimes),volSTimes(temporalProperties.drainTimes+1:iTimeInicioISIP),'--b');
% plot(tiempo(1:iTimeInicioISIP-temporalProperties.drainTimes),3*tiempo(1:iTimeInicioISIP-temporalProperties.drainTimes)*0.00264979,'--m');

% plot(tiempo,volPTimes(temporalProperties.drainTimes+1:end),'--r');
% plot(tiempo,volSTimes(temporalProperties.drainTimes+1:end),'--b');
title('Area de fractura')
legend('Area fractura vertical','Area fractura horizontal','Volumen fractura vertical','Volumen fractura horizontal') 
ylabel('Volumen [m^3]')
xlabel('deltaT [s]')
grid 

% Plot area de fractura en forma para un tiempo especifico.

subplot(1,3,2)
iTimeEspecifico = sum(tiempo <= tiempoArea);
nodosMuertosPlotMsk = logical(nodosMuertos(:,:,iTimeEspecifico+temporalProperties.drainTimes));
dNMod = meshInfo.cohesivos.dNTimes(:,:,iTimeEspecifico+temporalProperties.drainTimes);
dNMod(dNMod<0 & ~nodosMuertosPlotMsk) = 0;
dNMod(dNMod>0 & nodosMuertosPlotMsk) = 1;


bandplot2(meshInfo.cohesivos.elements,meshInfo.nodes,dNMod,[0 1],'k',2)
view(-40,25)
hold on
nodosMuertosPlot = unique(meshInfo.cohesivos.elements(nodosMuertosPlotMsk));
scatter3(meshInfo.nodes(nodosMuertosPlot,1),meshInfo.nodes(nodosMuertosPlot,2),meshInfo.nodes(nodosMuertosPlot,3),'k')
title(['Forma de la fractura en tiempo: ',num2str(tiempoArea),' [s]'])

subplot(1,3,3)
figure
dN = meshInfo.cohesivos.dNTimes(:,:,iTimeEspecifico+temporalProperties.drainTimes);
bandplot2(meshInfo.cohesivos.elements,meshInfo.nodes,dN)
view(-40,25)
hold on
scatter3(meshInfo.nodes(nodosMuertosPlot,1),meshInfo.nodes(nodosMuertosPlot,2),meshInfo.nodes(nodosMuertosPlot,3),'k')
title(['Separacion Normal en tiempo: ',num2str(tiempoArea),' [s]'])

BPM2m3s     = 0.00264979;
volumenBomba = bombaProperties.QbombasOG(end)*bombaProperties.tbombasOG(end)*BPM2m3s;
volumenFrac  = volPTimes(iTimeInicioISIP) + volSTimes(iTimeInicioISIP);
fprintf(['La diferencia entre lo que inyecta la bobma y ve la fractura en su punto maximo es: ',num2str(volumenBomba-volumenFrac),' [m^3]\n'])

% %% Volumen alternativo.
% iTime = iTimeInicioISIP;
% areaTot = 0;
% volTot  = 0;
% for iCohesivo  = 1:meshInfo.nCohesivos
%     area    = sum(areaPG(iCohesivo,:));
%     volMsk  = meshInfo.cohesivos.dNTimes(iCohesivo,:,iTime) > 0;
%     vol     = sum(areaPG(iCohesivo,volMsk).*meshInfo.cohesivos.dNTimes(iCohesivo,volMsk,iTime));
%     
%     areaTot = areaTot + area/1000^2;
%     volTot  = volTot + vol/1000^3;
% end

end















