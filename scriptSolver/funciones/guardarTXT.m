indiceTiempo = temporalProperties.drainTimes+1:temporalProperties.nTimes;
tiempo = cumsum(temporalProperties.deltaTs(indiceTiempo));
pFEA = zeros(1,temporalProperties.nTimes);
for iTime = 1:temporalProperties.nTimes
    pTime           = dTimes(paramDiscEle.nDofTot_U+1:paramDiscEle.nDofTot_U+paramDiscEle.nDofTot_P,iTime)*temporalProperties.preCond;
    pFEA(:,iTime)     = pTime(bombaProperties.nodoBomba(1));    % Presion en el primer nodo Bomba calculada por FEA en cada iTime.
end

%% Tiempos
fid = fopen(['tiempo_',nombreCorrida,'.txt'],'wt');
fprintf(fid,'%.6f\n',tiempo);
fclose(fid);
%% Presiones en nodo bomba
MPa2psi = 1e6/6894.76;
p = pFEA(1,temporalProperties.drainTimes+1:end)*MPa2psi;
fid = fopen(['presion_',nombreCorrida,'.txt'],'wt');
fprintf(fid,'%.6f\n',p);

fclose('all');

%% Presiones en nodesSample
if isfield(meshInfo,'nodosSample')
    MPa2psi = 1e6/6894.76;
    coord = meshInfo.nodosSample.X1; %si solo hay nodos en X1
    if isfield(meshInfo.nodosSample,'X2') %si tambien hay en X2
        coord = [coord ; meshInfo.nodosSample.X2];
        if isfield(meshInfo.nodosSample,'X3') %si tambien hay en X3
            coord = [coord; meshInfo.nodosSample.X3];
        end
    end
    nodIdx = zeros(1,size(coord,1));
    auxPrint = [];
    for i=1:length(nodIdx)
        aux=find(meshInfo.nodes(:,1)==coord(i,1) & meshInfo.nodes(:,2)==coord(i,2) & meshInfo.nodes(:,3)==coord(i,3));
        nodIdx(i)=aux(1); %no deberian haber nodos con las mismas coordenadas, pero con esto me cubro de un error por si pasa
        auxPrint = [auxPrint, '%.6f '];
    end
    auxPrint = [auxPrint(1:end-1) '\n'];
    pTimes = dTimes(paramDiscEle.nDofTot_U+1:paramDiscEle.nDofTot_U+paramDiscEle.nDofTot_P,indiceTiempo)*temporalProperties.preCond;
    pNodosSample = pTimes(nodIdx,:)*MPa2psi;
    %cada columna tiene las presiones a lo largo del tiempo de un nodo
    %sample...cómo guardo a qué nodo pertenece qué columna? con su indice
    %en la primera fila tal vez?
    fid = fopen(['presion_nodos_sample_',nombreCorrida,'.txt'],'wt');
    fprintf(fid,auxPrint,pNodosSample);
    fclose('all');
end

%% Caudales
Q = QTimes(bombaProperties.nodoBomba(1),temporalProperties.drainTimes+1:end);
fid = fopen(['Q_',nombreCorrida,'.txt'],'wt');
fprintf(fid,'%.6f\n',Q);

fclose('all');
