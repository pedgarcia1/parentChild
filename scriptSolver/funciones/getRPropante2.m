function [ RP,delta ] = getRPropante2(propanteProperties,cohesivos,KCohesivosPropante,paramDiscEle,meshInfo)
% HAY QUE CORREGIR PARA EL CASO QUE CONVIVAN FRACTURAS HORIZONTALES CON
% VERTICALES!!!!!!!!
delta = zeros(paramDiscEle.nDofTot_P,3);
nodosPropantes_minus = unique(propanteProperties.elements.Q4);
nodosPropantes_minus = nodosPropantes_minus(2:end);
nodosDesplazados     = cell(1,1);

for iEle = propanteProperties.propantesActivosTotales'
    aperturasNormalElemento = propanteProperties.aperturaFinal(iEle,:);
    Rot = cohesivos.T(:,:,iEle);
    
    desplazamientosElementoProyect = [aperturasNormalElemento',zeros(4,2)];
    desplazamientosElementoMod     = desplazamientosElementoProyect*Rot';   
    
    nodosDesplazados{iEle,1} = desplazamientosElementoMod'; 
end

iEle  = [];
iN = [];

for iNodo = nodosPropantes_minus'
    aux = [];
    [iEle,iN] = find(iNodo == propanteProperties.elements.Q4);
    nodoPropantes_plus = meshInfo.elementsBarra.ALL(meshInfo.elementsBarra.ALL(:,1) == iNodo,2);
    if numel(nodoPropantes_plus) > 1 % Esto sucede cuando tenemos cruce de fracturas. Hay un nodo minus por cada 2 plus.
        nodoPropantes_plus = nodoPropantes_plus(ismember(nodoPropantes_plus,propanteProperties.elements.H8(iEle,:)));
    end
for i = 1:size(iEle)
    aux = [aux,nodosDesplazados{iEle(i)}(:,iN(i))]; 
end
    delta(iNodo,:) = -mean(aux,2)/2;
    delta(nodoPropantes_plus,:) = +mean(aux,2)/2;
end
delta = reshape(delta',[],1);
RP    = KCohesivosPropante*delta;
end





