function [ RP,delta ] = getRPropante(paramDiscEle,propantes,KCohesivosPropante,direccionFrac)
delta      = zeros(paramDiscEle.nDofTot_P,3);
nodosLado1 = propantes.elements.H8(:,1:4);
nodosLado2 = propantes.elements.H8(:,5:8);

nodosLado1Unicos = unique(nodosLado1);
nodosLado1Unicos = nodosLado1Unicos(2:end); % Hay que sacarle el 0 como nodo.

nodosLado2Unicos = unique(nodosLado2);
nodosLado2Unicos = nodosLado2Unicos(2:end); % Hay que sacarle el 0 como nodo.

for iNodo = 1:numel(nodosLado1Unicos);
    delta(nodosLado1Unicos(iNodo),direccionFrac) = -mean(propantes.aberturaFinal(nodosLado1Unicos(iNodo) == nodosLado1))/2;
end

for iNodo = 1:numel(nodosLado2Unicos);
    delta(nodosLado2Unicos(iNodo),direccionFrac) = mean(propantes.aberturaFinal(nodosLado2Unicos(iNodo) == nodosLado2))/2;
end
delta = reshape(delta',[],1);
RP    = KCohesivosPropante*delta;
end

