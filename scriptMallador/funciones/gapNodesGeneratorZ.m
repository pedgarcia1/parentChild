function nodesNew = gapNodesGeneratorZ(nodes2DuplicateIndex,nodes,nodesNew,gap)
%%% Esta pequeña funcion agrega los nodos con el gap deseado.
nodesNew = [ nodesNew
             nodes(nodes2DuplicateIndex,:) + [ zeros(size(nodes2DuplicateIndex,1),1) zeros(size(nodes2DuplicateIndex,1),1) gap*ones(size(nodes2DuplicateIndex,1),1)] ];

end