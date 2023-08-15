function [RP, delta] = getRPropante3(propanteProperties,meshInfo,paramDiscEle,cohesivos,KCohesivosPropante)
deltaAux = cell(size(meshInfo.nodes,1),1);
propanteProperties.propantesActivosTotales;
nodosDesplazados     = cell(1,1);

for iEle = propanteProperties.propantesActivosTotales'
    aperturasNormalElemento = propanteProperties.aperturaFinal(iEle,:);
    Rot = cohesivos.T(:,:,iEle);
    
    desplazamientosElementoProyect = [aperturasNormalElemento',zeros(4,2)];
    desplazamientosElementoMod     = desplazamientosElementoProyect*Rot';   
    
    nodosDesplazados{iEle,1} = desplazamientosElementoMod'; 
end

for iEle = propanteProperties.propantesActivosTotales'
    nodesIDEelementMinus = cohesivos.related8Nodes(iEle,1:4);
    nodesIDEelementPlus  = cohesivos.related8Nodes(iEle,5:8);
    for iNode = 1:4
        deltaAux{nodesIDEelementMinus(iNode),1} = [deltaAux{nodesIDEelementMinus(iNode),1},-nodosDesplazados{iEle}(:,iNode)/2];
        deltaAux{nodesIDEelementPlus(iNode)}    = [deltaAux{nodesIDEelementPlus(iNode)}, nodosDesplazados{iEle}(:,iNode)/2];
    end
end


nodosPropantes_minus = unique(cohesivos.related8Nodes(propanteProperties.propantesActivosTotales,1:4));
nodosPropantes_plus = unique(cohesivos.related8Nodes(propanteProperties.propantesActivosTotales,5:8));

delta = zeros(paramDiscEle.nDofTot_U,1);

for iNode = [nodosPropantes_minus;nodosPropantes_plus]'
    if any(deltaAux{iNode}(1,:)~= 0)
        delta(iNode*3-2) = sum(deltaAux{iNode}(1,deltaAux{iNode}(1,:)~= 0))/numel(deltaAux{iNode}(1,deltaAux{iNode}(1,:)~= 0));
    end
    if any(deltaAux{iNode}(2,:)~= 0)
        delta(iNode*3-1) = sum(deltaAux{iNode}(2,deltaAux{iNode}(2,:)~= 0))/numel(deltaAux{iNode}(2,deltaAux{iNode}(2,:)~= 0));
    end
    if any(deltaAux{iNode}(3,:)~= 0)
        delta(iNode*3-0) = sum(deltaAux{iNode}(3,deltaAux{iNode}(3,:)~= 0))/numel(deltaAux{iNode}(3,deltaAux{iNode}(3,:)~= 0));
    end
end
RP    = KCohesivosPropante*delta;
