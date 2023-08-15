function nodesNew = nodesGenerator(nodes2DuplicateIndex,nodes,nodesNew,gap,dir)
%%% Esta pequeña funcion agrega los nodos con el gap deseado.

if dir == 2
nodesNew = [ nodesNew
             nodes(nodes2DuplicateIndex,:) + [ zeros(size(nodes2DuplicateIndex,1),1)  gap*ones(size(nodes2DuplicateIndex,1),1) zeros(size(nodes2DuplicateIndex,1),1) ] ];
% nodesNew(nodes2DuplicateIndex,2) =  nodesNew(nodes2DuplicateIndex,2) - gap/2*ones(size(nodes2DuplicateIndex,1),1);
else if dir == 3
        nodesNew = [ nodesNew
            nodes(nodes2DuplicateIndex,:) + [ zeros(size(nodes2DuplicateIndex,1),1) zeros(size(nodes2DuplicateIndex,1),1)   gap*ones(size(nodes2DuplicateIndex,1),1) ] ];
%         nodesNew(nodes2DuplicateIndex,3) =  nodesNew(nodes2DuplicateIndex,3) - gap/2*ones(size(nodes2DuplicateIndex,1),1);
    else
        nodesNew = [ nodesNew
            nodes(nodes2DuplicateIndex,:) + [gap*ones(size(nodes2DuplicateIndex,1),1)  zeros(size(nodes2DuplicateIndex,1),1)  zeros(size(nodes2DuplicateIndex,1),1) ] ];
    end
end

end