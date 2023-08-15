function [deltaPropante] = getDeltaForRPropante(propanteProperties,meshInfo,paramDiscEle,cohesivos)
deltaPropanteAux = cell(size(meshInfo.nodes,1),1);
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
        deltaPropanteAux{nodesIDEelementMinus(iNode),1} = [deltaPropanteAux{nodesIDEelementMinus(iNode),1},-nodosDesplazados{iEle}(:,iNode)/2];
        deltaPropanteAux{nodesIDEelementPlus(iNode)}    = [deltaPropanteAux{nodesIDEelementPlus(iNode)}, nodosDesplazados{iEle}(:,iNode)/2];
    end
end


nodosPropantes_minus = unique(cohesivos.related8Nodes(propanteProperties.propantesActivosTotales,1:4));
nodosPropantes_plus = unique(cohesivos.related8Nodes(propanteProperties.propantesActivosTotales,5:8));

deltaPropante = zeros(paramDiscEle.nDofTot_U,1);

for iNode = [nodosPropantes_minus;nodosPropantes_plus]'
    if any(deltaPropanteAux{iNode}(1,:)~= 0)
        deltaPropante(iNode*3-2) = sum(deltaPropanteAux{iNode}(1,deltaPropanteAux{iNode}(1,:)~= 0))/numel(deltaPropanteAux{iNode}(1,deltaPropanteAux{iNode}(1,:)~= 0));
    end
    if any(deltaPropanteAux{iNode}(2,:)~= 0)
        deltaPropante(iNode*3-1) = sum(deltaPropanteAux{iNode}(2,deltaPropanteAux{iNode}(2,:)~= 0))/numel(deltaPropanteAux{iNode}(2,deltaPropanteAux{iNode}(2,:)~= 0));
    end
    if any(deltaPropanteAux{iNode}(3,:)~= 0)
        deltaPropante(iNode*3-0) = sum(deltaPropanteAux{iNode}(3,deltaPropanteAux{iNode}(3,:)~= 0))/numel(deltaPropanteAux{iNode}(3,deltaPropanteAux{iNode}(3,:)~= 0));
    end
end
end

