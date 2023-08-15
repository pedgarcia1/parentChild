function [meshInfo] = meshVerification(meshInfo)
if isfield(meshInfo,'winkler')
    cprintf('Err','La malla ingresada tiene winklers. Para continuar se remueven automaticamente.\n' )
    cprintf('Err','Se agrega pausa de 10s para lectura de mensaje\n')
    pause(10)   
    
    nWinklers      = size(meshInfo.winkler,1);
    meshInfo.nodes = meshInfo.nodes(1:end-nWinklers,:);
    meshInfo       = rmfield(meshInfo,'winkler');
end

% for iEle = 1:size(meshInfo.cohesivos.elements,1)
%     elementalNodes = meshInfo.nodes(meshInfo.cohesivos.related8Nodes(2,:),:);
%     elementalProjectedNodes = (meshInfo.cohesivos.T(:,:,iEle)'*elementalNodes')';
%     elementalProjectedNodes = elementalProjectedNodes(:,~all(abs(diff(elementalProjectedNodes))< 1));
%     aux           = abs(diff(elementalProjectedNodes));
%     aux(aux == 0) = [];
%     gapInicial    = min(aux);
%     assert(gapInicial < 1,'Gap Inicial mayor a 1mm');
% end

end