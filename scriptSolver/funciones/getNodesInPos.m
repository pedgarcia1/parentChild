function [ nodesFound ] = getNodesInPos( tol,meshInfo,posNodoBomba)
if isempty(posNodoBomba)
    x = 0;
    y = meshInfo.anchoY/2;
    z = meshInfo.anchoZ/2;
else
    x = posNodoBomba(1);
    y = posNodoBomba(2);
    z = posNodoBomba(3);
end

tolX = tol;
tolY = tol;
tolZ = tol;
nodesFound = [];
while isempty(nodesFound)
    posX = abs(meshInfo.nodes(:,1)-x)<tolX;
    posY = abs(meshInfo.nodes(:,2)-y)<tolY;
    posZ = abs(meshInfo.nodes(:,3)-z)<tolZ;
    msk = posX & posY & posZ;
    aux = 1:size(meshInfo.nodes,1);
    nodesFound = aux(msk);
    if ~any(posX)
        tolX = tolX+1;
    elseif ~any(posY)
        tolY = tolY+1;
    elseif ~any(posZ)
        tolZ = tolZ+1;
    end
end
end



