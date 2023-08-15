function [nodesNew,newNode] = nodesGenerator3(nodes2DuplicateIndex,nodes,nodesNew,gap,dir)
%%% Esta pequeña funcion agrega los nodos con el gap deseado.

if dir == 2
    newNode = nodes(nodes2DuplicateIndex,:) + [ zeros(size(nodes2DuplicateIndex,1),1)  gap*ones(size(nodes2DuplicateIndex,1),1) zeros(size(nodes2DuplicateIndex,1),1) ] ;
    nodesNew = [ nodesNew
                 newNode];
else if dir == 3
        newNode = nodes(nodes2DuplicateIndex,:) + [ zeros(size(nodes2DuplicateIndex,1),1) zeros(size(nodes2DuplicateIndex,1),1)   gap*ones(size(nodes2DuplicateIndex,1),1) ];
        nodesNew = [ nodesNew
                     newNode];
    else
        newNode =  nodes(nodes2DuplicateIndex,:) + [gap*ones(size(nodes2DuplicateIndex,1),1)  zeros(size(nodes2DuplicateIndex,1),1)  zeros(size(nodes2DuplicateIndex,1),1) ];
        nodesNew = [ nodesNew
                     newNode];
    end
end

end