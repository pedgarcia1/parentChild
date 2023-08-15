function [elementsMinusNumber,elementsPlusNumber] = elementsPlusMinusX(nodesIndex,nodes,elements,elementsFisuIndex)
%%% By manny 21/03/2019 inspirado en Pablo Medina
elementsFisu = elements(elementsFisuIndex,:);

stirrMinus = false(size(elementsFisu,1),1);
% stirrPlus = false(size(fractura.Vert1.elements,1),1);
stirr = false(4,size(elementsFisu,1));

for iEle = 1:size(elementsFisu,1)  
    a=ismember(elementsFisu(iEle,:),nodesIndex);
    b=~a;
    caraPlus_xCoord=nodes(elementsFisu(iEle,a),1);
    caraMinus_xCoord=nodes(elementsFisu(iEle,b),1);
    for iNodFace = 1:length(caraPlus_xCoord)
        if caraPlus_xCoord(iNodFace)>caraMinus_xCoord(iNodFace)
            stirr(iNodFace,iEle)=true;
        end
    end
    if sum(stirr(:,iEle))==4
        stirrMinus(iEle) = true;
    end
end
stirrPlus = ~stirrMinus;
elementsMinus = elementsFisu(stirrMinus,:);
elementsPlus = elementsFisu(stirrPlus,:);
elementsMinusNumber = elementsFisuIndex(stirrMinus);
elementsPlusNumber = elementsFisuIndex(stirrPlus);
