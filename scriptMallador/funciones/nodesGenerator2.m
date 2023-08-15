function nodesNew = nodesGenerator(nodes2DuplicateIndex,nodes,nodesNew,gap,normal)
%%% Esta pequeña funcion agrega los nodos con el gap deseado.
nodesNew = [nodesNew
            nodes(nodes2DuplicateIndex,:) + ones(sizenodes2DuplicateIndex,1),3).*normal*gap];
end