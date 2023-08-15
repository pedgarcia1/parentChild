function [nodes] = resizeFracX(nodes,paramX)

nodesParamX = nodes(:,1)*paramX;
nodes(:,1) = nodesParamX;

end

