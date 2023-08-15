function [paramDiscEle] = getParamDiscEle( meshInfo, eleType )
% getParamDiscEle es una funcion que sirve para determinar parametros de
% discretizacion de los elementos que componen la malla. Por el momento
% solo funcion con elementos H8.

% eleType: tipo de elemento (por el momento solo 'H8')

% Toda la informacion se guarda en la estrcutura paramDiscEle y los campos 
% se detallan a continuacion.
% paramDiscEle = 
%             nDofNod: numero de dofs por nodo.
%             nNodEle: numero de nodos por elemento.
%              nDofEl: numero de dofs por elementos.
%     nDofElCohesivos: numero de dofs por elemento cohesivo.
%                nNod: numero de nodos.
%                 nel: numero de elementos.
%           nDofTot_U: numero de dofs relacionados a desplazamientos.
%           nDofTot_P: numero de dofs relacionados a presiones.
%            nodeDofs: dofs asociados a nodos. 
%%
switch eleType
    case 'H8'
        nDofNod         = 3;
        nNodEl          = 8;
        nDofElCohesivos = 24;           
end

nNod           = size(meshInfo.nodes,1);
nel            = size(meshInfo.elements,1);
nDofTot_U      = nDofNod*nNod;
nDofTot_P      = nNod; 
nDofEl          = nNodEl*nDofNod;
nodeDofs       = reshape(1:nDofTot_U,nDofNod,nNod)';


% Reenombre de variables y gurdado en estructura.
paramDiscEle.nDofNod         = nDofNod;
paramDiscEle.nNodEl          = nNodEl ;
paramDiscEle.nDofElCohesivos = nDofElCohesivos;            
paramDiscEle.nNod            = nNod ;
paramDiscEle.nel             = nel;
paramDiscEle.nDofTot_U       = nDofTot_U;
paramDiscEle.nDofTot_P       = nDofTot_P ;
paramDiscEle.nDofEl          = nDofEl;
paramDiscEle.nodeDofs        = nodeDofs;


end
