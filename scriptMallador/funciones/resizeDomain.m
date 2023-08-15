function [nodes] = resizeDomain(nodes,paramX,paramY,paramZ)

nodesParamX = nodes(:,1)*paramX;
nodesParamY = nodes(:,2)*paramY;
nodesParamZ = nodes(:,3)*paramZ;

nodes(:,1) = nodesParamX;
nodes(:,2) = nodesParamY;
nodes(:,3) = nodesParamZ;
end

