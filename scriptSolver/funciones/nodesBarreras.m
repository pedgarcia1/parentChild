function [ meshInfo ] = nodesBarreras(physicalProperties,meshInfo)
nBarreras                    = numel(physicalProperties.constitutive.depthL);
limitesBarreras              = zeros(nBarreras,2);
nNodes                       = size(meshInfo.nodes,1);
meshInfo.nodesBarreras.nodes = [];
meshInfo.nodesBarreras.index = [];
testigo                      = false;
tol                          = 1e-3;

for iBarrera = 1:nBarreras
    limitesBarreras(iBarrera,:) = [physicalProperties.constitutive.depthL(iBarrera), physicalProperties.constitutive.depthL(iBarrera)+ physicalProperties.constitutive.eL(iBarrera)];
end
limitesBarreras = unique(limitesBarreras);

for iNode = 1:nNodes
    posZNodal = meshInfo.nodes(iNode,3);
    
    for iBarrera = 1:nBarreras*2
        if testigo == false
            testigo = abs(posZNodal - limitesBarreras(iBarrera,1)) <= tol || abs(posZNodal - limitesBarreras(iBarrera,1)) <= tol;
        end
    end
    
    if testigo == true
        meshInfo.nodesBarreras.index = [meshInfo.nodesBarreras.index; iNode];
        meshInfo.nodesBarreras.nodes = [meshInfo.nodesBarreras.nodes; meshInfo.nodes(iNode,:)];
        testigo                      = false;
    end
end
end
