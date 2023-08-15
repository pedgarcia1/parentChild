function [elementsIndex, nodesIndex,elementsDosNodos,nodesIndex2Nodos] = elementsFracturas(elements,nodesFisuIndex)
%%% Encuentra los elementos que tienen alguna cara pegada a la figura. Entrega a su vez que nodos son 
%%% los que estan pegados a la fisura. En el caso de elementos H8, son 8
%%% nodos.

nel = size(elements,1);
counter = 1;
counter2 = 1;
nodesIndex2Nodos = [];
elementsDosNodos = [];
elementsIndex = [];
nodesIndex = [];

for iEle = 1:nel
   nodesEle = elements(iEle,:);
   nodesInFisu_index = ismember(nodesEle,nodesFisuIndex);
   nNodesInFisu = sum(nodesInFisu_index);
   
   if nNodesInFisu == 4
       elementsIndex(counter,1) = iEle;
       nodesIndex(counter,:) = nodesInFisu_index;
       counter = counter + 1;
   end
   if nNodesInFisu == 2
       elementsDosNodos(counter2,1) = iEle;
        
       
       nodesIndex2Nodos(counter2,:) = nodesInFisu_index;
       counter2 = counter2 +1;
   end
   
end

nodesIndex = logical(nodesIndex);
end
