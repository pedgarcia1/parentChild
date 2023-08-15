%% START %%
clc
clearvars
close all
addpath('Mallas') 
addpath('funciones') 

debugPlots = false;
saveMat    = true;
barrerasFlag = true;

%% DESIRED GAP %%
gap = 1e-4;
tol = 2;
fprintf('%s: %d %s \n','Gap elegido',gap,'mm')

%% MESH LOADING %%
% LOAD NODES FROM ADINA%%

nombreOutput  = 'ParentChild_prueba_nuevaBarrera_v3.mat';
nodes         = load('Mallas/ParentChild_nodes.txt'); 
elements      = load('Mallas/ParentChild_elements.txt');


% nombreOutput  = 'parentChild_1.mat';
% nodes         = load('MULTIFRAC_PC_nodes.txt'); 
% elements      = load('MULTIFRAC_PC_elements.txt');


% fprintf('%s: %s \n','Nombre de corrida',nombreOutput)

mapeoNodos              = nodes(:,1);
nNod                    = size(nodes,1);
nodes(:,[1 5])          = [];

elements(:,[1 10:end])  = [];
nel                     = size(elements,1);

% MUEVO EL SISTEMA DE COORDENADAS A LA ESQUINA MAS AUSTRAL %%%%
moverEjes = [-min(nodes(:,1))*ones(nNod,1) -min(nodes(:,2))*ones(nNod,1) -min(nodes(:,3))*ones(nNod,1)];
nodes     = nodes + moverEjes;
    
% Arreglo para que la numeracion de nodos arranque en 1%%
 for iNod = 1:size(nodes,1)
        nodoAMapear = mapeoNodos(iNod);
        elements(ismember(elements,nodoAMapear)) = iNod;
 end
 
 if debugPlots == 1
     plotMeshColo3D(nodes,elements,'w')
     xlabel('x')
     ylabel('y')
     zlabel('z')
     axis equal
 end
 
%% ELEMENTS Y NODES SIN MODIFICAR %%

elementsVanilla = elements;
nodesVanilla    = nodes;
nodes           = nodes*76/24*1000;

%% DIMENSIONES DOMINIO %%
anchoX = max(nodes(:,1));
anchoY = max(nodes(:,2));
anchoZ = max(nodes(:,3));
ancho = [anchoX;anchoY;anchoZ];

figure
plotMeshColo3D(nodes,elements,'w')
xlabel 'x'
ylabel 'y'
zlabel 'z'

%% NODO BOMBA Y MONITORES

sizeElements = ones(1,3)*36e3;
posNodoBomba(1,:) = [anchoX/2 anchoY/2 anchoZ/2];

[nodoBomba,nodosMonitores] = findMonitores(nodes, posNodoBomba,sizeElements);

% agregar print de  la posicion de los nodos monitores
%% ACTUALIZACIÓN DOMINIO %%
anchoX = max(nodes(:,1));
anchoY = max(nodes(:,2));
anchoZ = max(nodes(:,3));
xPositions = unique(nodes(:,1));
%% MODIFICACION DE LA DISTANCIA ENTRE FRACTURAS %%
 
% nodes = resizeFracX(nodes,paramX);

if debugPlots == 1
    plotMitadMalla(nodes,elements,1.98)
end

elementSize.X = abs((nodes(elements(1,5),1)) - nodes(elements(1,1),1)); %largo elementos gruesos 

%% DEFINICION DE LAS FRACTURAS %%

%% FRACTURA YZ1 %%
fractura.X1.anchoFisuraY = 76*7*1e3;
fractura.X1.anchoFisuraZ = 76*1e3;
Y0 = 76*1e3;
Z0 = 76*1e3;
fractura.X1.posXFractura = anchoX/2;
fractura.X1.posYFractura = [Y0 Y0+fractura.X1.anchoFisuraY];
fractura.X1.posZFractura = [Z0 Z0+fractura.X1.anchoFisuraZ];

%% NODOS FRACTURAS %%
[nodesFisu.X1.coords, nodesFisu.X1.index] = nodosFracturasX2(fractura.X1.posXFractura,fractura.X1.posYFractura,fractura.X1.posZFractura,nodes,tol);

if debugPlots == 1
    figure
    hold on
    scatter3(nodesFisu.X1.coords(:,1),nodesFisu.X1.coords(:,2),nodesFisu.X1.coords(:,3),'r')
end

%% ELEMENTOS FRACTURAS %%
%encuentra los elementos que conforman los planos de fractura
[elementsFisu.X1.index, elementsFisu.X1.nodes] = elementsFracturas(elements,nodesFisu.X1.index);

elementsFisu.ALL.index = [ elementsFisu.X1.index];
                          
                       
elementsFisu.ALL.nodes = [ elementsFisu.X1.nodes];
                             
if debugPlots == 1
    figure
%     plotMeshColo3D(nodes,elements,'k',0.05)
    plotMeshColo3D(nodes,elements(elementsFisu.X1.index,:,:),'r',1)
%     plotMeshColo3D(nodes,elements(elementsFisu.X2.index,:,:),'b',1)
    axis equal
    hold off
end

%% ELEMENTOS MINUS PLUS %%
                         
[elementsFisu.X1.minus,elementsFisu.X1.plus] = elementsPlusMinusX(nodesFisu.X1.index,nodes,elements,elementsFisu.X1.index);
if debugPlots == 1
    figure
    hold on
    plotMeshColo3D(nodes,elements,'k',0.05)
    plotMeshColo3D(nodes,elements(elementsFisu.X1.minus,:),'r',1)
    plotMeshColo3D(nodes,elements(elementsFisu.X1.plus,:),'y',1)

    axis equal
end

%%  ELEMENTS EDGE %% 
elementsEdge = [];

for i = 1:3
    x1 = false(nel,1);
    x2 = false(nel,1);
    for iele = 1:nel
        iCoordEle = nodes(elements(iele,:),i); %saco los nodos de la fila i de la matriz de elementos
        if any(iCoordEle <= ancho(i)+tol & iCoordEle >= ancho(i)-tol) %veo si alguna coordenada esta en el borde superior
            x1(iele) = true;
        end
        if any(iCoordEle <= tol & iCoordEle >= -tol) %veo si alguna coordenada esta en el borde inferior
            x2(iele) = true;
        end
    end
    elementsEdge = [elementsEdge
                    elements(x1,:)
                    elements(x2,:)];                
end

elementsEdge = unique(elementsEdge,'rows');

if debugPlots == 1
    figure
    hold on
    plotMeshColo3D(nodes,elements,'k',0.05)
    plotMeshColo3D(nodes,elementsEdge,'r',1)
end

%% SEPARACIÓN %%

%% FISURA X1 %%
nNod = size(nodes,1);
nodesNew = nodes;
nodesNew_LastPosition = size(nodesNew,1);                                         
nodesNew = nodesGenerator(nodesFisu.X1.index,nodes,nodesNew,gap,1);                       

% ELEMENTS BARRA Y NODOS FLUIDOS
elementsBarra.X1            = [nodesFisu.X1.index (nodesNew_LastPosition+1:size(nodesNew,1))'];
nodosFluidos.coords         = nodes(nodesFisu.X1.index,:);
nodosFluidos.index          = nodesFisu.X1.index;
elementsBarra.ALL           = elementsBarra.X1;
nElementsBarra              = size(elementsBarra.ALL,1);
nodosFluidos.EB_Asociados   = (1:1:nElementsBarra)';
EBindex.X1                   = (1:1:nElementsBarra)';

%%% Se arreglan las conexiones elementales

nelPlus = size(elementsFisu.X1.plus,1);

for iEle = 1:nelPlus
    element                = elementsFisu.X1.plus(iEle);
    nodesInElement         = elements(element,:);
    [indexA]               = ismember(nodesInElement,nodesFisu.X1.index);
    [~, indexB]            = ismember(nodesInElement(indexA),nodesFisu.X1.index);
    replacementNodes       = indexB + ones(size(indexB))*nodesNew_LastPosition;
    nodesInElement(indexA) = replacementNodes;
    elements(element,:)    = nodesInElement;
end

if debugPlots == 1
    figure
    hold on
    Draw_Barra(elementsBarra.ALL,nodesNew,'k')
    PlotMesh(nodesNew,elements(elementsFisu.X1.index,:,:))
    hold off
end

%% FISURA X1 %%%
%%% Elementos que NO estan en elementsFisu
elementsMedium = (1:1:size(elements,1))';
elementsMedium = setdiff(elementsMedium, elementsFisu.X1.index);
nelElementsMedium = size(elementsMedium,1);
plusSelector = false(nelElementsMedium,1);

%%% Busco los que estan del lado plus de la fractura!
for iEle = 1:nelElementsMedium
    element = elementsMedium(iEle);
    nodesInElement = elements(element,:);
    nodeCoordsX1    = nodesNew(nodesInElement,1);
    if sum(nodeCoordsX1>(fractura.X1.posXFractura))>=4
        plusSelector(iEle) = true;
    end
    
    
end

elementsMediumPlus = elementsMedium(plusSelector);

if debugPlots == 1
    figure
    hold on
    plotMeshColo3D(nodes,elements(elementsMedium,:),'k',0.05)
    plotMeshColo3D(nodes,elements(elementsMediumPlus,:),[0 0.9128 0],1)
    figure
    plotMeshColo3D(nodesNew,elements(elementsMediumPlus,:))
    
    figure
    plotMeshColo3D(nodesNew,elements(elementsMediumPlus,:),[0 0.9128 0],1)
    plotMeshColo3D(nodesNew,elements(elementsFisu.X1.plus,:),'y',1)
        hold on
    Draw_Barra(elementsBarra.ALL,nodesNew,'k')
    figure
    plotMeshColo3D(nodesNew,elements(elementsMediumPlus,:),[0 0.9128 0],1)
    plotMeshColo3D(nodesNew,elements(elementsFisu.X1.plus,:),'y',1)
end

%% CONSTRAINTS FLUIDOS %%
CRFluidos = [elementsBarra.ALL zeros(size(elementsBarra.ALL,1),3)];

%% FISURA X1 %%%
nodesInt.INT.index = [];
nodesFisu.X1.sinInt = removeIntNodes(nodesFisu.X1.index,nodesInt.INT.index);
nodesFisu.X1.sinIntCoords = nodesNew(nodesFisu.X1.sinInt,:);

startingPoint            = [fractura.X1.posXFractura fractura.X1.posYFractura(1) fractura.X1.posZFractura(1)];
endingPoint              = [fractura.X1.posXFractura fractura.X1.posYFractura(1) fractura.X1.posZFractura(2)];
indexVector              = pointsIn3DLine(nodesFisu.X1.sinIntCoords,startingPoint,endingPoint);
nodosBoundary.X1.sinInt  = nodesFisu.X1.sinInt(indexVector);

startingPoint            = [fractura.X1.posXFractura fractura.X1.posYFractura(1) fractura.X1.posZFractura(1)];
endingPoint              = [fractura.X1.posXFractura fractura.X1.posYFractura(2) fractura.X1.posZFractura(1)];
indexVector              = pointsIn3DLine(nodesFisu.X1.sinIntCoords,startingPoint,endingPoint);
nodosBoundary.X1.sinInt  = [nodosBoundary.X1.sinInt
                           nodesFisu.X1.sinInt(indexVector)];
                       
startingPoint            = [fractura.X1.posXFractura fractura.X1.posYFractura(1) fractura.X1.posZFractura(2)];
endingPoint              = [fractura.X1.posXFractura fractura.X1.posYFractura(2) fractura.X1.posZFractura(2)];
indexVector              = pointsIn3DLine(nodesFisu.X1.sinIntCoords,startingPoint,endingPoint);
nodosBoundary.X1.sinInt  = [nodosBoundary.X1.sinInt
                           nodesFisu.X1.sinInt(indexVector)];
                       
startingPoint            = [fractura.X1.posXFractura fractura.X1.posYFractura(2) fractura.X1.posZFractura(1)];
endingPoint              = [fractura.X1.posXFractura fractura.X1.posYFractura(2) fractura.X1.posZFractura(2)];
indexVector              = pointsIn3DLine(nodesFisu.X1.sinIntCoords,startingPoint,endingPoint);
nodosBoundary.X1.sinInt  = [nodosBoundary.X1.sinInt
                           nodesFisu.X1.sinInt(indexVector)];
                    
nodosBoundary.X1.sinInt  = unique(nodosBoundary.X1.sinInt);


if debugPlots == 1
    figure
    scatter3(nodesFisu.X1.sinIntCoords(:,1),nodesFisu.X1.sinIntCoords(:,2),nodesFisu.X1.sinIntCoords(:,3))
    hold on
    scatter3(nodesNew(nodosBoundary.X1.sinInt,1),nodesNew(nodosBoundary.X1.sinInt,2),nodesNew(nodosBoundary.X1.sinInt,3),'r')
end


startingPoint            = [fractura.X1.posXFractura fractura.X1.posYFractura(1) fractura.X1.posZFractura(2)];
endingPoint              = [fractura.X1.posXFractura fractura.X1.posYFractura(2) fractura.X1.posZFractura(2)];
indexVector              = pointsIn3DLine(nodesFisu.X1.coords,startingPoint,endingPoint);
nodosBoundary.X1.all     = nodesFisu.X1.sinInt(indexVector);

startingPoint            = [fractura.X1.posXFractura fractura.X1.posYFractura(1) fractura.X1.posZFractura(2)];
endingPoint              = [fractura.X1.posXFractura fractura.X1.posYFractura(2) fractura.X1.posZFractura(2)];
indexVector              = pointsIn3DLine(nodesFisu.X1.coords,startingPoint,endingPoint);
nodosBoundary.X1.all     = [nodosBoundary.X1.sinInt
                           nodesFisu.X1.sinInt(indexVector)];
                       
startingPoint            = [fractura.X1.posXFractura fractura.X1.posYFractura(2) fractura.X1.posZFractura(1)];
endingPoint              = [fractura.X1.posXFractura fractura.X1.posYFractura(2) fractura.X1.posZFractura(2)];
indexVector              = pointsIn3DLine(nodesFisu.X1.coords,startingPoint,endingPoint);
nodosBoundary.X1.all     = [nodosBoundary.X1.sinInt
                           nodesFisu.X1.sinInt(indexVector)];

nodosBoundary.X1.all     = unique(nodosBoundary.X1.all);                      

if debugPlots == 1
    figure
    scatter3(nodesFisu.X1.sinIntCoords(:,1),nodesFisu.X1.sinIntCoords(:,2),nodesFisu.X1.sinIntCoords(:,3))
    hold on
    scatter3(nodesNew(nodosBoundary.X1.sinInt,1),nodesNew(nodosBoundary.X1.sinInt,2),nodesNew(nodosBoundary.X1.sinInt,3),'r')
end

%% SE AGREGAN LOS NUEVOS NODOS EN LOS BORDES (LOS TERCEROS EN DISCORDIA) %%

nodesNew_LastPosition    = size(nodesNew,1);
nodesNew                 = nodesGenerator(nodosBoundary.X1.sinInt,nodesNew,nodesNew,gap/2,1);
nodosBordesNewIndex.X1   = (nodesNew_LastPosition+1:1:size(nodesNew,1))';

nodoInterseccion.X1 = nodosBoundary.X1.all(~(ismember(nodosBoundary.X1.all,nodosBoundary.X1.sinInt)));

%% GENERACION DE CONSTRAINTS RELATIONS %%
% Indica que elementsBarra le corresponde a cada nodoBoundary
[~,relatedEB.X1]        = ismember(nodosBoundary.X1.sinInt,elementsBarra.X1);         

%NO HAY INTERSECCIONES
nInts = 0;
constraintsRelations    = zeros(size(nodosBoundary.X1.sinInt,1)+nInts,5);
counter                 = 1;

%%% FRACTURA X1 %%%
if ~isempty(nodosBordesNewIndex.X1)
    for iNod = 1:size(nodosBoundary.X1.sinInt,1)  
        relationNodes                   = elementsBarra.X1(relatedEB.X1(iNod),:);     
        constraintsRelations(counter,:) = [ nodosBordesNewIndex.X1(iNod) relationNodes 0 0];
        counter                         = counter + 1;
    end
end


%% SEPARACION DE LAS CONECTIVIDADES EN LOS BORDES %%

%%% FISURA X1 %%%
elementsMedium = (1:1:size(elements,1))';
elementsMedium = setdiff(elementsMedium, elementsFisu.X1.index);
nelElementsMedium = size(elementsMedium,1);

for iEle = 1:nelElementsMedium
    element = elementsMedium(iEle);
    nodesInElement = elements(element,:);
    [indexA] = ismember(nodesInElement,nodosBoundary.X1.sinInt);
   
    [~, indexB] = ismember(nodesInElement(indexA),nodosBoundary.X1.sinInt);
    
    nodesInElement(indexA) = nodosBordesNewIndex.X1(indexB);
    
    elements(element,:) = nodesInElement;
end

%% ULTIMOS CONSTRAINT RELATION ASOCIADOS A LA INTERSECCIONES Y SU SEPARACION %%
%% INT X1 %%
nodesNew_LastPosition   = size(nodesNew,1);
auxVec                  = [nodesNew(nodoInterseccion.X1,1) nodesNew(nodoInterseccion.X1,2)+gap/2 nodesNew(nodoInterseccion.X1,3)+gap/2];
nodesNew                = [nodesNew
                           auxVec];
nodosBordesNewIndex.INT.X1 = (nodesNew_LastPosition+1:1:size(nodesNew,1))';
% NO HAY INTERSECCIONES
%%% AGREGO LAS CONSTRAINTS RELATIONS A LAS DE FLUIDOS %%%


% relationNodes                   = intRelatedNodes.X1(ismember(intRelatedNodes.X1(:,1),nodoInterseccion.X1),:);
% constraintsRelations(counter,:) = [ nodosBordesNewIndex.INT.X1 relationNodes];

[aux1,aux2] = ismember(CRFluidos(:,[1 2]),constraintsRelations(:,[2 3]),'rows');

%%% HAY QUE AGREGAR AQUELLOS CONTRAINTS DONDE 3 NODOS TIENEN LA MISMA P %%%
    CRFluidos(aux1,:) = constraintsRelations(nonzeros(aux2),:);
    
if debugPlots == 1
    plotMeshColo3D(nodesNew,elements,'w')
end

nodes = nodesNew; 

%% MALLA FLUIDOS Y ELEMENTS COHESIVOS%%
%%% Utilizo las caras de los elementsFisu MINUS para generar los grupos de 4
%%% nodos, que luego seran ordenados.

counter = 0;
elementsFisu.ALL.minus      = [elementsFisu.X1.minus];
                           
[~,indexAuxX1]               = ismember(elementsFisu.X1.minus,elementsFisu.X1.index);

elementsFisu.ALL.minusNodes = [elementsFisu.X1.nodes(indexAuxX1,:)];
                           
elementsFisu.X1.minusNodes   = elementsFisu.X1.nodes(indexAuxX1,:);
% elementsFisu.X2.minusNodes   = elementsFisu.X2.nodes(indexAuxX2,:);
                                                         
nelEleFisu                  = size(elementsFisu.ALL.minus,1);
fourNodesEles               = zeros(nelEleFisu,4);
elementsFluidos.elements    = zeros(nelEleFisu,4);
cohesivos.elements          = zeros(nelEleFisu,4);
cohesivos.related8Nodes     = zeros(nelEleFisu,8);
cohesivos.type              = zeros(nelEleFisu,1); %% Este indica si es fractura, Z, Y, O X
cohesivos.name              = cell(nelEleFisu,1);


%%% RELATED NODES TO THE INTERFACE ELEMENTS (8 FOR Q4) %%%

%%% X1 %%% 
for iEle = 1:size(elementsFisu.X1.minus)
    nodesEle    = elements(elementsFisu.X1.minus(iEle),:);
    nodesInFisu = nodesEle(elementsFisu.X1.minusNodes(iEle,:));
    [~,relatedEB] = ismember(nodesInFisu,elementsBarra.ALL(EBindex.X1));
    auxEB         = elementsBarra.ALL(EBindex.X1,:);
    
    relatedEBNodes = auxEB(relatedEB,:);
    relatedEB      = EBindex.X1(relatedEB);
    
    nodesEle = nodesNew(nodesInFisu,:); 
    nodesEleNew = nodesEle - repmat(nodesEle(1,:),4,1);
   
    versori  =  nodes(relatedEBNodes(1,2),:)' - nodes(relatedEBNodes(1,1),:)';
    versori  =  versori / norm(versori);
    
    auxVec   = nodesEle(2,:)' -  nodesEle(1,:)';
    versorj  = cross(auxVec,versori);
    versorj  = versorj / norm(versorj);
    
    versork  = cross(versori,versorj);
    versork  = versork / norm(versork);
    
    T = [versori versorj versork];
    
    nodesEleRot = (T' * (nodesEleNew'))';
    
    %%% Obtengo el centroide
    centroid    = [sum(nodesEleRot(:,2))/4 sum(nodesEleRot(:,3))/4];
    rays        = nodesEleRot(:,[2 3]) -  repmat(centroid,4,1);
    angles      = atan2(rays(:,2),rays(:,1));
    angles      = angles + (angles<0)*2*pi;
    
    %%% Con los angulos obtengo asi finalmente el orden correcto
    [~, correctOrder] = sort(angles);
    counter = counter + 1;
         
    %%% VUELVO A CALCULAR OTRA VEZ LA MATRIZ DE ROTACION PARA ASEGURARME
    %%% QUE NINGUN EJE ESTE ALINEADO CON UNA DIAGONAL 
    
    nodesEleReOrder = nodesEle(correctOrder,:);
    
    auxVec   = nodesEleReOrder(1,:)' -  nodesEleReOrder(4,:)';
    
    versorj  = cross(auxVec,versori);
    versorj  = versorj / norm(versorj);
    
    versork  = cross(versori,versorj);
    versork  = versork / norm(versork);
    
    T = [versori versorj versork];
    
    nodesEleRot = (T' * (nodesEleNew'))';
     
    elementsFluidos.elements(counter,:)    = nodesInFisu(correctOrder);
    elementsFluidos.relatedEB(counter,:)   = relatedEB(correctOrder);
    elementsFluidos.nodesEle(:,:,counter)  = [nodesEleRot(correctOrder,2) nodesEleRot(correctOrder,3)];
    elementsFluidos.T(:,:,counter)         = T;
    
    cohesivos.elements(counter,:)       = nodesInFisu(correctOrder);
    cohesivos.relatedEB(counter,:)      = relatedEB(correctOrder);
    cohesivos.type(counter)             = 3;
    cohesivos.name{counter}             = 'X1';
    cohesivos.nodesEle(:,:,counter)     = [nodesEleRot(correctOrder,2) nodesEleRot(correctOrder,3)];
    cohesivos.T(:,:,counter)            = T;
    relatedEB                           = relatedEB(correctOrder);
    relatedEBNodes                      = relatedEBNodes(correctOrder,:);
    
    cohesivos.related8Nodes(counter,:) = [relatedEBNodes(:,1)' relatedEBNodes(:,2)'];
end

%% BARRERAS %%
posBarrera2 = 145.5e3; % NO poner la barrera en los elementos del borde de los cohesivos
espesorBarrera2 = 1e3;
posBarrera1 = 82.5e3; % NO poner la barrera en los elementos del borde de los cohesivos
espesorBarrera1 = 1e3; 
tol = 2e-5;
debugPlots = true;
printFlag = true;
if barrerasFlag
    if debugPlots
        figure
        subplot(1,2,1)
        plotMeshColo3D3(nodes,elements,cohesivos.elements,'off','on','w','r')
        title("Sin Barreras");
    end

    % [nodes,elements] = generadorDeBarreras(posBarrera2,espesorBarrera2,nodes,elements,tol,true);
    % [nodes,elements] = generadorDeBarreras(posBarrera1,espesorBarrera1,nodes,elements,tol,true);

    nodes = generadorDeBarrerasSimples(posBarrera2,espesorBarrera2,fractura,'X1',cohesivos,nodes,elements,tol,true);
    nodes = generadorDeBarrerasSimples(posBarrera1,espesorBarrera1,fractura,'X1',cohesivos,nodes,elements,tol,true);

    posiblesNodosBarrera1 = [posBarrera1 - espesorBarrera1/2,posBarrera1 + espesorBarrera1/2];
    posiblesNodosBarrera2 = [posBarrera2 - espesorBarrera2/2,posBarrera2 + espesorBarrera2/2];

    [~,I1] = sort(abs(posiblesNodosBarrera1 - anchoY/2),'ascend');
    zBarrera1 = posiblesNodosBarrera1(I1(1));
    [~,I2] = sort(abs(posiblesNodosBarrera2 - anchoY/2),'ascend');
    zBarrera2 = posiblesNodosBarrera2(I2(1));

    if printFlag
        fprintf("depthL = [%.2f %.2f] \n",zBarrera1,zBarrera2);
        fprintf("eL = [%.2f %.2f] \n",espesorBarrera1,espesorBarrera2);
    end
    
    if debugPlots
        subplot(1,2,2)
        plotMeshColo3D3(nodes,elements,cohesivos.elements,'off','on','w','r')
        title("Con Barreras");
    end
end

%% NODOS MONITORES


%% OUTPUTS
figure
plotMeshColo3D(nodes,elements)
if saveMat
    save(nombreOutput,'nodes','elements','elementsEdge','elementsFisu','elementsBarra','nodosFluidos','elementsFluidos','anchoX','anchoY','anchoZ','cohesivos','CRFluidos','elementsMediumPlus','constraintsRelations','nodosBoundary');
end
  