function  [nodesNew,elements] = generadorDeBarreras(posBarrera1,espesorBarrera1,nodes,elements,tol,debugPlots)
%% BARRERA 1 %%

%%% NODOS BARRERA %%% 
nodosBarrera = find(abs(nodes(:,3)-posBarrera1)<tol);
nodosBarreraLogical = abs(nodes(:,3)-posBarrera1)<tol;
nodosPlusLogical = nodes(:,3)>(posBarrera1 - tol);
nodosPlus    = xor(nodosPlusLogical,nodosBarreraLogical);

%%% ELEMENTS FRACTURAS %%%
[elementsFisu.index, elementsFisu.nodes,elementsDosNodos,nodesIndex2Nodos] = elementsFracturas(elements,nodosBarrera);

if debugPlots == 1
    figure
    PlotMeshHold(nodes,elements,0,'k',0.05)
    PlotMeshHold(nodes,elements(elementsFisu.index,:,:),0,'r',1)
    hold off
end
 
%%% ELEMENTS PLUS Y MINUS %%%

[elementsFisu.minus,elementsFisu.plus] = elementsPlusMinusZ(nodosBarrera,nodes,elements,elementsFisu.index);

%%% PLUS Y MINUS 2 NODOS %%
plus2Nodos = false(size(elementsDosNodos,1),1);
auxAPlus = false(size(elementsDosNodos,1),8);
auxBPlus = zeros(size(elementsDosNodos,1),8);
auxAMinus = false(size(elementsDosNodos,1),8);
auxBMinus = zeros(size(elementsDosNodos,1),8);

for iEle = 1:size(elementsDosNodos,1)
    ele = elementsDosNodos(iEle);
    nodesEle = elements(ele,:);
    
    if sum(nodes(nodesEle,3)>(posBarrera1 + tol)) > 4
        plus2Nodos(iEle) = true;
        [a,b] = ismember(nodesEle,elements(elementsFisu.plus,:));
        auxAPlus(iEle,:) = a;
        auxBPlus(iEle,:) = b;
    else
        [a,b] = ismember(nodesEle,elements(elementsFisu.minus,:));
        auxAMinus(iEle,:) = a;
        auxBMinus(iEle,:) = b;
    end
            
    
end
elementsPlus2Nodos = elementsDosNodos(plus2Nodos);
elementsMinus2Nodos = elementsDosNodos(~plus2Nodos);
auxAMinus = auxAMinus(~plus2Nodos,:);
auxBMinus = auxBMinus(~plus2Nodos,:);
auxAPlus  = auxAPlus(plus2Nodos,:);
auxBPlus  = auxBPlus(plus2Nodos,:);


%%% ELEMENT PAIRS, NECESARIOS PARA GENERAR LOS NUEVOS ELEMENTOS %%%
nPairs                      = size(elementsFisu.plus,1);
elementPairs.nodesIndexPlus = false(nPairs,8);
% elementPairs.auxPlus        = zeros(nPairs,8);
elementPairs.nodesIndexMinus = false(nPairs,8);
% elementPairs.auxMinus        = zeros(nPairs,8);
elementPairs.elePlus         = zeros(nPairs,1);
elementPairs.eleMinus        = zeros(nPairs,1);

for iele = 1:size(elementsFisu.plus,1)
    elePlus = elementsFisu.plus(iele);
    nodesEle = elements(elePlus,:);
    [nodesInFisu_index,auxPlus] = ismember(nodesEle,nodosBarrera);
    nodesInFisu      = nodesEle(nodesInFisu_index);
    %%% ahora buscamos su pareja %%%
    posInElementsMinus = ismember(elements(elementsFisu.minus,:),nodesInFisu);
    eleMinusLogical    = sum(posInElementsMinus,2)>3;
    eleMinus           = elementsFisu.minus(eleMinusLogical);
    [nodesInFisu_indexMinus] = posInElementsMinus(eleMinusLogical,:);
    elementPairs.nodesIndexPlus(iele,:) = nodesInFisu_index;
    elementPairs.nodesIndexMinus(iele,:)= nodesInFisu_indexMinus;
    elementPairs.elePlus(iele,:)        = elePlus;
    elementPairs.eleMinus(iele,:)       = eleMinus;
end


if debugPlots == 1
    figure
    PlotMeshHold(nodes,elements,0,'k',0.05)
    PlotMeshHold(nodes,elements(elementsFisu.minus,:),0,'r',1)
    PlotMeshHold(nodes,elements(elementsFisu.plus,:),0,'y',1)
end
%%% Separacion de ambas caras %%%
nodesNew = nodes;
nodesNew_LastPosition = size(nodesNew,1);

%%% GENERO EL GAP %%%%
nodesNew = gapNodesGeneratorZ(nodosBarrera,nodes,nodesNew,espesorBarrera1);                       

%%% ELEVO EL RESTO DE NODOS ADEMAS DE LOS NUEVOS %%%
nodesNew(nodosPlus,3) = nodesNew(nodosPlus,3) + espesorBarrera1; 
% ELEMENTS BARRA Y NODOS FLUIDOS

% Se arreglan las conexiones elementales
nelPlus = size(elementsFisu.plus,1);

for iEle = 1:nelPlus
    element = elementsFisu.plus(iEle);
    nodesInElement = elements(element,:);
    [indexA] = ismember(nodesInElement,nodosBarrera);
    [~, indexB] = ismember(nodesInElement(indexA),nodosBarrera);
    
    replacementNodes = indexB + ones(size(indexB))*nodesNew_LastPosition;
    
    nodesInElement(indexA) = replacementNodes;
    
    elements(element,:) = nodesInElement;
end

% if debugPlots == 1
%     figure
%     hold on
%     Draw_Barra(elementsBarra,nodesNew,'k')
%     PlotMesh(nodesNew,elements(elementsFisu.index,:,:))
%     hold off
% end

%%% GENERACION DE LOS NUEVOS NODOS %%%
counter  = size(elements,1) + 1;
counter1 = counter;
elements = [elements; zeros(nPairs,8)];


for iPair = 1:nPairs
    elePlus = elementPairs.elePlus(iPair);
    nodosPlus = elements(elePlus,elementPairs.nodesIndexPlus(iPair,:));
    eleMinus = elementPairs.eleMinus(iPair);
    nodosMinus = elements(eleMinus,elementPairs.nodesIndexMinus(iPair,:));
    
    %%% Antes de armarlos tengo que arreglar el orden de los nodos pa q de
    %%% bien el elements
    %%% Sort plus
    [~,aux] = sort(nodesNew(nodosPlus,2),'descend');
    highYNodes = nodosPlus(aux(1:2));
    lowYNodes  = nodosPlus(aux(3:4));
    [~,aux2] = sort(nodesNew(highYNodes,1),'descend');
    [~,aux3] = sort(nodesNew(lowYNodes,1));
    nodosPlus = [highYNodes(aux2) lowYNodes(aux3)];
    
    %%% Sort minus
    [~,aux] = sort(nodesNew(nodosMinus,2),'descend');
    highYNodes = nodosMinus(aux(1:2));
    lowYNodes  = nodosMinus(aux(3:4));
    [~,aux2] = sort(nodesNew(highYNodes,1),'descend');
    [~,aux3] = sort(nodesNew(lowYNodes,1));
    nodosMinus = [highYNodes(aux2) lowYNodes(aux3)];
    
    elements(counter,:) = [nodosPlus nodosMinus];
    counter = counter + 1;
    
end


%%% ARREGLO LOS DOS NODOS %%%

for iele = 1:size(elementsPlus2Nodos,1)
    ele = elementsPlus2Nodos(iele);
    auxA = auxAPlus(iele,:);
    auxB = auxBPlus(iele,:);
    elementsFisuPlus = elements(elementsFisu.plus,:);
    
    elements(ele,auxA) = elementsFisuPlus(auxB(auxA));

end
end