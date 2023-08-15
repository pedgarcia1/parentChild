function [ meshInfo ] = elementsBarreras(physicalProperties,meshInfo)
nBarreras                          = numel(physicalProperties.constitutive.depthL);
nElements                          = size(meshInfo.elements,1);
limitesBarreras                    = zeros(nBarreras,2);
meshInfo.elementsBarreras.elements = [];
meshInfo.elementsBarreras.index    = [];
testigo                            = false;
tol                                = 1e-3;

for iBarrera = 1:nBarreras
    limitesBarreras(iBarrera,:) = [physicalProperties.constitutive.depthL(iBarrera), physicalProperties.constitutive.depthL(iBarrera)+ physicalProperties.constitutive.eL(iBarrera)];
end

for iElement = 1:nElements
    nodosElemento = meshInfo.elements(iElement,:);
    posZnodal     = sort(meshInfo.nodes(nodosElemento,3))';
    for iBarrera = 1:nBarreras
        if testigo == false
            testigo = all([abs(posZnodal(1:4) - limitesBarreras(iBarrera,1)) <= tol,abs(posZnodal(5:end) - limitesBarreras(iBarrera,2)) <= tol]);
        end
    end
    if testigo == true
        meshInfo.elementsBarreras.index    = [meshInfo.elementsBarreras.index; iElement];
        meshInfo.elementsBarreras.elements = [meshInfo.elementsBarreras.elements; nodosElemento];
        testigo                            = false;
    end
end
end

