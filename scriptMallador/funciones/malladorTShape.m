%% MALLADOR TSHAPE 2020 %%
%%% El siguiente programa es una mallador diseñado especificamente para
%%% generar una interseccion perpendicular de fracturas.
%%% - Posee constraints para los bordes de la fractura
%%% - Posee elementos de Winkler

%% START %%
clc
clearvars
close all

debugPlots = 1;
remesh  = 0;

%% DESIRED GAP %%
gap = 1e-9;
tol = 0.01;

%% MESH LOADING %%
nodes                   = load('nodes36-10.txt');     
nodes(:,[1 5])          = [];
elements                = load('elements36-10.txt');
elements(:,[1 10:end])  = [];
nel                     = size(elements,1);

plotMeshColo3D(nodes,elements,'w')

%% ELEMENTS Y NODES SIN MODIFICAR %%

elementsVanilla = elements;
nodesVanilla    = nodes;

%% DIMENSIONES DOMINIO %%

anchoX = max(nodes(:,1));
anchoY = max(nodes(:,2));
anchoZ = max(nodes(:,3));

xPositions = unique(nodes(:,1));

%% FRACTURA X - Z  (Y FIJO) %%
fractura.Y.anchoFisuraX = xPositions(end-1);        %% Que no llegue hasta el final, tiene que ser exacto
fractura.Y.anchoFisuraZ = anchoZ;% + espesorBarrera3;

fractura.Y.posXFractura = [0 fractura.Y.anchoFisuraX ];
fractura.Y.posYFractura = anchoY/2;
fractura.Y.posZFractura = [(anchoZ - fractura.Y.anchoFisuraZ) / 2  (anchoZ - fractura.Y.anchoFisuraZ) / 2 + fractura.Y.anchoFisuraZ ];
                         
%% FRACTURA X - Y  (Z FIJO) %%
fractura.Z.anchoFisuraX = xPositions(end-1);        %% Que no llegue hasta el final, tiene que ser exacto
fractura.Z.anchoFisuraY = anchoY;% + espesorBarrera3;

fractura.Z.posXFractura = [0 fractura.Z.anchoFisuraX ];
fractura.Z.posYFractura = [(anchoY - fractura.Z.anchoFisuraY ) / 2  (anchoY - fractura.Z.anchoFisuraY ) / 2 + fractura.Z.anchoFisuraY];
fractura.Z.posZFractura = anchoZ/2;


%% NODOS FRACTURAS %%
[nodesFisu.Y.coords, nodesFisu.Y.index] = nodosFracturasY2(fractura.Y.posXFractura,fractura.Y.posYFractura,fractura.Y.posZFractura,nodes,tol);
[nodesFisu.Z.coords, nodesFisu.Z.index] = nodosFracturasZ(fractura.Z.posXFractura,fractura.Z.posZFractura,fractura.Z.posYFractura,nodes,tol);

if debugPlots == 1
    figure
    scatter3(nodesFisu.Y.coords(:,1),nodesFisu.Y.coords(:,2),nodesFisu.Y.coords(:,3))
    hold on
    scatter3(nodesFisu.Z.coords(:,1),nodesFisu.Z.coords(:,2),nodesFisu.Z.coords(:,3))
end

%% INTERSECCION %%
nodesInt.INT.index = nodesFisu.Y.index(ismember(nodesFisu.Y.index, nodesFisu.Z.index));
 
%% NODOS FRACTURAS SIN INTERSECCIONES %%
nodesFisu.Y.sinInt = removeIntNodes(nodesFisu.Y.index,nodesInt.INT.index);
nodesFisu.Z.sinInt = removeIntNodes(nodesFisu.Z.index,nodesInt.INT.index);
       
if debugPlots == 1
    figure
    scatter3(nodes(nodesFisu.Y.sinInt,1),nodes(nodesFisu.Y.sinInt,2),nodes(nodesFisu.Y.sinInt,3))
    hold on
    scatter3(nodes(nodesFisu.Z.sinInt,1),nodes(nodesFisu.Z.sinInt,2),nodes(nodesFisu.Z.sinInt,3))
end

%% ELEMENTOS FRACTURAS %%
[elementsFisu.Y.index, elementsFisu.Y.nodes] =   elementsFracturas(elements,nodesFisu.Y.index);
[elementsFisu.Z.index, elementsFisu.Z.nodes] =   elementsFracturas(elements,nodesFisu.Z.index);

elementsFisu.ALL.index = [ elementsFisu.Y.index
                           elementsFisu.Z.index ];
elementsFisu.ALL.nodes = [ elementsFisu.Y.nodes
                           elementsFisu.Z.nodes ];                       
                       
if debugPlots == 1
    figure
    plotMeshColo3D(nodes,elements,'k',0.05)
    plotMeshColo3D(nodes,elements(elementsFisu.ALL.index,:,:),'r',1)
    hold off
end


%% ELEMENTOS MINUS PLUS %% 
                         
[elementsFisu.Y.minus,elementsFisu.Y.plus] = elementsPlusMinusY(nodesFisu.Y.index,nodes,elements,elementsFisu.Y.index);

if debugPlots == 1
    figure
    hold on
    plotMeshColo3D(nodes,elements,'k',0.05)
    plotMeshColo3D(nodes,elements(elementsFisu.Y.minus,:),'r',1)
    plotMeshColo3D(nodes,elements(elementsFisu.Y.plus,:),'y',1)
end

[elementsFisu.Z.minus,elementsFisu.Z.plus]  = elementsPlusMinusZ(nodesFisu.Z.index,nodes,elements,elementsFisu.Z.index);

if debugPlots == 1
    figure
    hold on
    plotMeshColo3D(nodes,elements,'k',0.05)
    plotMeshColo3D(nodes,elements(elementsFisu.Z.minus,:),'r',1)
    plotMeshColo3D(nodes,elements(elementsFisu.Z.plus,:),'y',1)
end
                         
%% A PARTIR DE AHORA COMIENZA LA SEPARACIÓN (LOS PLUS),GENERACION DE GAP,NODOS DE FLUIDOS Y ELEMENTS BARRA %%
%%% Primero se separan todos lso elementos y nodos que no son parte
%%% de alguna interseccion.

%%% FISURA Y %%%

nNod = size(nodes,1);
nodesNew = nodes;
nodesNew_LastPosition = size(nodesNew,1);
                                           
nodesNew = nodesGenerator(nodesFisu.Y.sinInt,nodes,nodesNew,gap,2);                       

% ELEMENTS BARRA Y NODOS FLUIDOS
elementsBarra.Y             = [nodesFisu.Y.sinInt (nodesNew_LastPosition+1:size(nodesNew,1))'];
nodosFluidos.coords         = nodes(nodesFisu.Y.sinInt,:);
nodosFluidos.index          = nodesFisu.Y.sinInt;
elementsBarra.ALL           = elementsBarra.Y;
nElementsBarra              = size(elementsBarra.ALL,1);
nodosFluidos.EB_Asociados   = (1:1:nElementsBarra)';
EBindex.Y                   = (1:1:nElementsBarra)';
% Se arreglan las conexiones elementales
nelPlus = size(elementsFisu.Y.plus,1);

for iEle = 1:nelPlus
    element = elementsFisu.Y.plus(iEle);
    nodesInElement = elements(element,:);
    [indexA] = ismember(nodesInElement,nodesFisu.Y.sinInt);
    [~, indexB] = ismember(nodesInElement(indexA),nodesFisu.Y.sinInt);
    
    replacementNodes = indexB + ones(size(indexB))*nodesNew_LastPosition;
    
    nodesInElement(indexA) = replacementNodes;
    
    elements(element,:) = nodesInElement;
end

                         
if debugPlots == 1
    figure
    hold on
    Draw_Barra(elementsBarra.ALL,nodesNew,'k')
    PlotMesh(nodesNew,elements(elementsFisu.Y.index,:,:))
    hold off
end
                         
                         
%%% FISURA Z %%%
nodesNew_LastPosition = size(nodesNew,1);
                                           
nodesNew = nodesGenerator(nodesFisu.Z.sinInt,nodes,nodesNew,gap,3);                       

% ELEMENTS BARRA Y NODOS FLUIDOS
elementsBarra.Z             = [nodesFisu.Z.sinInt (nodesNew_LastPosition+1:size(nodesNew,1))'];
nodosFluidos.coords         = [nodosFluidos.coords
                               nodes(nodesFisu.Z.sinInt,:)];
nodosFluidos.index          = [nodosFluidos.index
                               nodesFisu.Z.sinInt];
nodosFluidos.EB_Asociados   = [nodosFluidos.EB_Asociados
                               (nElementsBarra+1:1:size(nodosFluidos.coords,1))'];
lastEB                      = size(elementsBarra.ALL,1);
nNewEBs                     = size(elementsBarra.Z,1);
EBindex.Z                   = [(lastEB+1:1:lastEB+nNewEBs)'];
elementsBarra.ALL           = [elementsBarra.ALL
                               elementsBarra.Z];

nElementsBarra              = size(elementsBarra.ALL,1);
% Se arreglan las conexiones elementales
nelPlus = size(elementsFisu.Z.plus,1);

for iEle = 1:nelPlus
    element = elementsFisu.Z.plus(iEle);
    nodesInElement = elements(element,:);
    [indexA] = ismember(nodesInElement,nodesFisu.Z.sinInt);
    [~, indexB] = ismember(nodesInElement(indexA),nodesFisu.Z.sinInt);
    
    replacementNodes = indexB + ones(size(indexB))*nodesNew_LastPosition;
    
    nodesInElement(indexA) = replacementNodes;
    
    elements(element,:) = nodesInElement;
end

                         
if debugPlots == 1
    figure
    hold on
    Draw_Barra(elementsBarra.ALL,nodesNew,'k')
    PlotMesh(nodesNew,elements(elementsFisu.Z.index,:,:))
    hold off
end

%% CONSTRAINTS FLUIDOS %%

CRFluidos = [elementsBarra.ALL zeros(size(elementsBarra.ALL,1),3) ];
            
                      
                         
%% INTERSECCIONES %%
%%% intRelations tiene todos los grupos de 4 nodos que se encuentran en la
%%% interseccion, servira para CR y para los CTFluidos.

elementsBarra.INT = [];

%%% INT1 : Y CON Z %%%
[elements,nodesNew,nodosFluidos,elementsBarra,EBindex,intRelations] = gapInterseccionesEB(nodesInt.INT.index,nodesNew,gap,elementsFisu.Y.plus,elementsFisu.Z.plus,elements,nodosFluidos,elementsBarra,EBindex);

CRFluidos = [ CRFluidos
              [intRelations zeros(size(intRelations,1),1)] ];
                        
if debugPlots == 1
    figure
    plotMeshColo3D(nodesNew,elements(elementsFisu.ALL.index,:,:))
    hold on
    Draw_Barra(elementsBarra.ALL,nodesNew,'k')
    hold off
end

if debugPlots == 1
    figure
    hold on
    Draw_Barra(elementsBarra.ALL,nodesNew,'k')
    for iInt = 1:size(intRelations,1)
        scatter3(nodesNew(intRelations(iInt,:),1),nodesNew(intRelations(iInt,:),2),nodesNew(intRelations(iInt,:),3))
    end
end

%% NODOS BOUNDARY %% 
%%% Primero se generan todos aquellos que no esten en la interseccion por
%%% otro lado, los nodosBoundary, es decir aquellos nodos que se encuentran
%%% en el borde de las fisuras y todavia estan unidos a los elementos del
%%% medio son los nodosFisu iniciales, ya que son nos nodos generados los
%%% que cambiaron de posicion y conectividad.
nodesFisu.Y.sinIntCoords = nodesNew(nodesFisu.Y.sinInt,:);
nodesFisu.Z.sinIntCoords = nodesNew(nodesFisu.Z.sinInt,:); 

%%% FISURA Y %%%
startingPoint           = [fractura.Y.posXFractura(2) fractura.Y.posYFractura 0];
endingPoint             = [fractura.Y.posXFractura(2) fractura.Y.posYFractura anchoZ];
indexVector             = pointsIn3DLine(nodesFisu.Y.sinIntCoords,startingPoint,endingPoint);
nodosBoundary.Y.sinInt  = nodesFisu.Y.sinInt(indexVector);

indexVector             = pointsIn3DLine(nodesFisu.Y.coords,startingPoint,endingPoint);
nodosBoundary.Y.all     = nodesFisu.Y.index(indexVector);
if debugPlots == 1
    figure
    scatter3(nodesFisu.Y.sinIntCoords(:,1),nodesFisu.Y.sinIntCoords(:,2),nodesFisu.Y.sinIntCoords(:,3))
    hold on
    scatter3(nodesNew(nodosBoundary.Y.sinInt ,1),nodesNew(nodosBoundary.Y.sinInt,2),nodesNew(nodosBoundary.Y.sinInt,3),'r')
end

%%% FISURA Z %%%
startingPoint           = [fractura.Z.posXFractura(2) fractura.Z.posYFractura(1) fractura.Z.posZFractura];
endingPoint             = [fractura.Z.posXFractura(2) fractura.Z.posYFractura(2) fractura.Z.posZFractura];
indexVector             = pointsIn3DLine(nodesFisu.Z.sinIntCoords,startingPoint,endingPoint);
nodosBoundary.Z.sinInt  = nodesFisu.Z.sinInt(indexVector);

indexVector             = pointsIn3DLine(nodesFisu.Z.coords,startingPoint,endingPoint);
nodosBoundary.Z.all     = nodesFisu.Z.index(indexVector);
if debugPlots == 1
    figure
    scatter3(nodesFisu.Z.coords(:,1),nodesFisu.Z.coords(:,2),nodesFisu.Z.coords(:,3))
    hold on
    scatter3(nodesNew(nodosBoundary.Z.sinInt ,1),nodesNew(nodosBoundary.Z.sinInt,2),nodesNew(nodosBoundary.Z.sinInt,3),'r')
end

%%% BUSCO EL NODO DE INTERSECCION %%%
%%% Las siguientes lineas basicamente se fijan que nodo esta en
%%% nodosBoundary.all pero no esta en el sinInt.

nodoInterseccion = nodosBoundary.Y.all(~(ismember(nodosBoundary.Y.all,nodosBoundary.Y.sinInt)));

%% SE AGREGAN LOS NUEVOS NODOS EN LOS BORDES (LOS TERCEROS EN DISCORDIA) %%

nodesNew_LastPosition   = size(nodesNew,1);
nodesNew                = nodesGenerator(nodosBoundary.Y.sinInt,nodesNew,nodesNew,gap/2,2);
nodosBordesNewIndex.Y   = (nodesNew_LastPosition+1:1:size(nodesNew,1))';

nodesNew_LastPosition   = size(nodesNew,1);
nodesNew                = nodesGenerator(nodosBoundary.Z.sinInt,nodesNew,nodesNew,gap/2,3);
nodosBordesNewIndex.Z   = (nodesNew_LastPosition+1:1:size(nodesNew,1))';


%% GENERACION DE CONSTRAINTS RELATIONS %%
[~,relatedEB.Y]         = ismember(nodosBoundary.Y.sinInt,elementsBarra.Y);         % Indica que elementsBarra le corresponde a cada nodoBoundary
[~,relatedEB.Z]         = ismember(nodosBoundary.Z.sinInt,elementsBarra.Z);         % Indica que elementsBarra le corresponde a cada nodoBoundary
constraintsRelations    = zeros(size(nodosBoundary.Y.sinInt,1)+size(nodosBoundary.Z.sinInt,1) + 1,5);
counter                 = 1;

%%% FRACTURA Y %%%
for iNod = 1:size(nodosBoundary.Y.sinInt,1)  
    relationNodes                   = elementsBarra.Y(relatedEB.Y(iNod),:);     
    constraintsRelations(counter,:) = [ nodosBordesNewIndex.Y(iNod) relationNodes 0 0];
    counter                         = counter + 1;
end

%%% FRACTURA Z %%%
for iNod = 1:size(nodosBoundary.Y.sinInt,1)  
    relationNodes                   = elementsBarra.Z(relatedEB.Z(iNod),:);     
    constraintsRelations(counter,:) = [ nodosBordesNewIndex.Z(iNod) relationNodes 0 0];
    counter                         = counter + 1;
end
%% SEPARACION DE LAS CONECTIVIDADES EN LOS BORDES %%

%%% FISURA Y %%%
elementsMedium = (1:1:size(elements,1))';
elementsMedium = setdiff(elementsMedium, elementsFisu.Y.index);
nelElementsMedium = size(elementsMedium,1);

for iEle = 1:nelElementsMedium
    element = elementsMedium(iEle);
    nodesInElement = elements(element,:);
    [indexA] = ismember(nodesInElement,nodosBoundary.Y.sinInt);
   
    [~, indexB] = ismember(nodesInElement(indexA),nodosBoundary.Y.sinInt);
    
    nodesInElement(indexA) = nodosBordesNewIndex.Y(indexB);
    
    elements(element,:) = nodesInElement;
end


%%% FISURA Z %%%
elementsMedium = (1:1:size(elements,1))';
elementsMedium = setdiff(elementsMedium, elementsFisu.Z.index);
nelElementsMedium = size(elementsMedium,1);

for iEle = 1:nelElementsMedium
    element = elementsMedium(iEle);
    nodesInElement = elements(element,:);
    [indexA] = ismember(nodesInElement,nodosBoundary.Z.sinInt);
   
    [~, indexB] = ismember(nodesInElement(indexA),nodosBoundary.Z.sinInt);
    
    nodesInElement(indexA) = nodosBordesNewIndex.Z(indexB);
    
    elements(element,:) = nodesInElement;
end

%% ULTIMO CONSTRAINT RELATION ASOCIADO A LA INTERSECCION Y SU SEPARACION %%
nodesNew_LastPosition   = size(nodesNew,1);
auxVec                  = [nodesNew(nodoInterseccion,1) nodesNew(nodoInterseccion,2)+gap/2 nodesNew(nodoInterseccion,3)+gap/2 ];
nodesNew                = [nodesNew
                           auxVec];
nodosBordesNewIndex.INT = (nodesNew_LastPosition+1:1:size(nodesNew,1))';

%%% CONSTRAINTS RELATIONS %%%
relationNodes            = intRelations(ismember(nodoInterseccion,intRelations),:);
constraintsRelations(counter,:) = [ nodosBordesNewIndex.INT relationNodes];

%%% AGREGO LAS CONSTRAINTS RELATIONS A LAS DE FLUIDOS %%%
[aux1,aux2] = ismember(CRFluidos(:,[1 2]),constraintsRelations(:,[2 3]),'rows');
%%% HAY QUE AGREGAR AQUELLOS CONTRAINTS DONDE 3 NODOS TIENEN LA MISMA P %%%
CRFluidos(aux1,:) = constraintsRelations(nonzeros(aux2),:);

%%% INT %%%

elementsMedium = (1:1:size(elements,1))';
elementsMedium = setdiff(elementsMedium, elementsFisu.Z.index);
nelElementsMedium = size(elementsMedium,1);

for iEle = 1:nelElementsMedium
    element = elementsMedium(iEle);
    nodesInElement = elements(element,:);
    [indexA] = ismember(nodesInElement,nodoInterseccion);
   
    [~, indexB] = ismember(nodesInElement(indexA),nodoInterseccion);
    
    nodesInElement(indexA) = nodosBordesNewIndex.INT(indexB);
    
    elements(element,:) = nodesInElement;
end

if debugPlots == 1
    plotMeshColo3D(nodesNew,elements,'w')
end



nodes = nodesNew;

%% GENERACION DE ELEMENTOS DE FUNDACION DE WINKLER %%

tol             = 1e-8;
caraInferior    = abs(nodes(:,3) - 0) < tol;
caraSuperior    = abs(nodes(:,3) - anchoZ) < tol;
caraSur         = abs(nodes(:,2) - 0) < tol;
caraNorte       = abs(nodes(:,2) - anchoY) < tol;
caraEste        = abs(nodes(:,1) - anchoX) < tol;
caraOeste       = abs(nodes(:,1) - 0) < tol;

%%% VOY GENERANDO LAS CAPAS DE NODOS PARA HACER LOS WINKLER %%%
%%% LA CARA OESTE ES LA QUE POSEE SIMETRIA  ASI QUE ESA NO PRECISA WINKLER %%%

%%% INFERIOR %%%
nNod = size(nodes,1);
nodesNew = nodes;
nodesNew_LastPosition = size(nodesNew,1);                                     
nodesNew = nodesGenerator(find(caraInferior),nodes,nodesNew,-1,3);

% ELEMENTS BARRA Y NODOS FLUIDOS
elementsWinkler          = [find(caraInferior) (nodesNew_LastPosition+1:size(nodesNew,1))'];
winkler.Inferior =  (nodesNew_LastPosition+1:size(nodesNew,1))';
%%% SUPERIOR %%%
nodesNew_LastPosition = size(nodesNew,1);                                     
nodesNew = nodesGenerator(find(caraSuperior),nodes,nodesNew,1,3);

% ELEMENTS BARRA Y NODOS FLUIDOS
elementsWinkler          = [elementsWinkler
                            find(caraSuperior) (nodesNew_LastPosition+1:size(nodesNew,1))'];
winkler.Superior =  (nodesNew_LastPosition+1:size(nodesNew,1))';                         
                     
%%% NORTE %%%
nodesNew_LastPosition = size(nodesNew,1);                                     
nodesNew = nodesGenerator(find(caraNorte),nodes,nodesNew,1,2);

% ELEMENTS BARRA Y NODOS FLUIDOS
elementsWinkler          = [elementsWinkler
                            find(caraNorte) (nodesNew_LastPosition+1:size(nodesNew,1))'];
winkler.Norte =  (nodesNew_LastPosition+1:size(nodesNew,1))';
%%% SUR %%%
nodesNew_LastPosition = size(nodesNew,1);                                     
nodesNew = nodesGenerator(find(caraSur),nodes,nodesNew,-1,2);

% ELEMENTS BARRA Y NODOS FLUIDOS
elementsWinkler          = [elementsWinkler
                            find(caraSur) (nodesNew_LastPosition+1:size(nodesNew,1))'];
winkler.Sur =  (nodesNew_LastPosition+1:size(nodesNew,1))';
%%% ESTE %%%
nodesNew_LastPosition = size(nodesNew,1);                                     
nodesNew = nodesGenerator(find(caraEste),nodes,nodesNew,1,1);

% ELEMENTS BARRA Y NODOS FLUIDOS
elementsWinkler          = [elementsWinkler
                            find(caraEste) (nodesNew_LastPosition+1:size(nodesNew,1))'];
winkler.Este =  (nodesNew_LastPosition+1:size(nodesNew,1))';                        
if debugPlots == 1
    figure
    hold on
    Draw_Barra(elementsWinkler,nodesNew,'k')
    PlotMesh(nodesNew,elements)
    hold off
end
winkler.elements = elementsWinkler;


%% AREA COMPUTATION OF WINKLER ELEMENTS %%
%%% INFERIOR %%%
areas = winklerArea(nodes,elements,caraInferior,3);
winkler.areas = areas(caraInferior);
winkler.areaInf = sum(areas);
%%% SUPERIOR %%%
areas = winklerArea(nodes,elements,caraSuperior,3);
winkler.areas = [   winkler.areas 
                    areas(caraSuperior) ];
winkler.areaSup = sum(areas);                
%%% NORTE %%%
areas = winklerArea(nodes,elements,caraNorte,2);
winkler.areas = [   winkler.areas 
                    areas(caraNorte) ]; 
winkler.areaNor = sum(areas);                
%%% SUR %%%
areas = winklerArea(nodes,elements,caraSur,2);
winkler.areas = [   winkler.areas 
                    areas(caraSur) ];
winkler.areaSur = sum(areas);                
%%% ESTE %%%
areas = winklerArea(nodes,elements,caraEste,1);
winkler.areas = [   winkler.areas 
                    areas(caraEste) ]; 
                
winkler.areaEste = sum(areas);                
                
nodes = nodesNew;

%% MALLA FLUIDOS Y ELEMENTS COHESIVOS%%
%%% Utilizo las caras de los elementsFisu MINUS para generar los grupos de 4
%%% nodos, que luego seran ordenados.

counter = 1;
elementsFisu.ALL.minus      = [elementsFisu.Y.minus
                               elementsFisu.Z.minus];
[~,indexAuxY]                = ismember(elementsFisu.Y.minus,elementsFisu.Y.index);
[~,indexAuxZ]                = ismember(elementsFisu.Z.minus,elementsFisu.Z.index);

elementsFisu.ALL.minusNodes = [elementsFisu.Y.nodes(indexAuxY,:)
                               elementsFisu.Z.nodes(indexAuxZ,:)];
                           
elementsFisu.Y.minusNodes   = elementsFisu.Y.nodes(indexAuxY,:);
elementsFisu.Z.minusNodes   = elementsFisu.Z.nodes(indexAuxZ,:);
             
                           
nelEleFisu                  = size(elementsFisu.ALL.minus,1);
fourNodesEles               = zeros(nelEleFisu,4);
elementsFluidos.elements    = zeros(nelEleFisu,4);
cohesivos.elements          = zeros(nelEleFisu,4);
cohesivos.related8Nodes     = zeros(nelEleFisu,8);



%%% RELATED NODES TO THE INTERFACE ELEMENTS (8 FOR Q4) %%%


%%% Y %%% 
for iEle = 1:size(elementsFisu.Y.minus)
    nodesInEle    = elements(elementsFisu.Y.minus(iEle),:);
    nodesInFisu = nodesInEle(elementsFisu.Y.minusNodes(iEle,:));
    [~,relatedEB] = ismember(nodesInFisu,elementsBarra.ALL(EBindex.Y));
    auxEB         = elementsBarra.ALL(EBindex.Y,:);
    
    relatedEBNodes = auxEB(relatedEB,:);
    relatedEB      = EBindex.Y(relatedEB);
    
    nodesEle = nodesNew(nodesInFisu,:);
     
    nodesEleNew = nodesEle - repmat(nodesEle(1,:),4,1);
    
    versori  = nodesEle(1,:)' - nodesEle(4,:)';
    versori  = versori / norm(versori);
    
    auxVec   = nodesEle(1,:)' - nodesEle(3,:)';
    
    versork  = cross(auxVec,versori);
    versork  = versork / norm(versork);
    
    versorj  = cross(versork,versori);
    versorj  = versorj / norm(versorj);
    
    T           = [versori/norm(versori) versorj/norm(versorj) versork/norm(versork)];
    
    nodesEleRot = (T' * (nodesEleNew'))';
    %%% Obtengo el centroide
    centroid    = [sum(nodesEleRot(:,1))/4 sum(nodesEleRot(:,2))/4];
    rays        = nodesEleRot(:,[1 2]) -  repmat(centroid,4,1);
    angles      = atan2(rays(:,2),rays(:,1));
    angles      = angles + (angles<0)*2*pi;
    %%% Con los angulos obtengo asi finalmente el orden correcto
    [~, correctOrder] = sort(angles);
     
     
    
    
    elementsFluidos.elements(iEle,:)    = nodesInFisu(correctOrder);
    elementsFluidos.relatedEB(iEle,:)   = relatedEB(correctOrder);
    elementsFluidos.nodesEle(:,:,iEle)  = [nodesEleRot(correctOrder,1) nodesEleRot(correctOrder,2)];
    elementsFluidos.localC(:,:,iEle)    = [versori/norm(versori) versorj/norm(versorj) versork/norm(versork)];
    
    
    cohesivos.elements(iEle,:)      = nodesInFisu(correctOrder);
    cohesivos.relatedEB(iEle,:)     = relatedEB(correctOrder);
    relatedEB                       = relatedEB(correctOrder);
    relatedEBNodes                  = relatedEBNodes(correctOrder,:);
    
    cohesivos.related8Nodes(iEle,:) = [relatedEBNodes(:,1)' relatedEBNodes(:,2)'];

end
lastPos = size(elementsFisu.Y.minus,1);


%%% Z %%% 
for iEle = 1:size(elementsFisu.Z.minus)
    nodesEle    = elements(elementsFisu.Z.minus(iEle),:);
    nodesInFisu = nodesEle(elementsFisu.Z.minusNodes(iEle,:));
    [~,relatedEB] = ismember(nodesInFisu,elementsBarra.ALL(EBindex.Z));
    auxEB         = elementsBarra.ALL(EBindex.Z,:);
    
    relatedEBNodes = auxEB(relatedEB,:);
    
    relatedEB      = EBindex.Z(relatedEB);
   
    
    nodesEle = nodesNew(nodesInFisu,:);
     
    nodesEleNew = nodesEle - repmat(nodesEle(1,:),4,1);
    
    versori  = nodesEle(1,:)' - nodesEle(4,:)';
    versori  = versori / norm(versori);
    
    auxVec   = nodesEle(1,:)' - nodesEle(3,:)';
    
    versork  = cross(auxVec,versori);
    versork  = versork / norm(versork);
   
    versorj  = cross(versork,versori);
    versorj  = versorj / norm(versorj);
    
    T           = [versori/norm(versori) versorj/norm(versorj) versork/norm(versork)];
    
    nodesEleRot = (T' * (nodesEleNew'))';
    %%% Obtengo el centroide
    centroid    = [sum(nodesEleRot(:,1))/4 sum(nodesEleRot(:,2))/4];
    rays        = nodesEleRot(:,[1 2]) -  repmat(centroid,4,1);
    angles      = atan2(rays(:,2),rays(:,1));
    angles      = angles + (angles<0)*2*pi;
    %%% Con los angulos obtengo asi finalmente el orden correcto
    [~, correctOrder] = sort(angles);
     
     
    
    
    elementsFluidos.elements(lastPos + iEle,:)    = nodesInFisu(correctOrder);
    elementsFluidos.relatedEB(lastPos + iEle,:)   = relatedEB(correctOrder);
    elementsFluidos.nodesEle(:,:,lastPos + iEle)  = [nodesEleRot(correctOrder,1) nodesEleRot(correctOrder,2)];
    elementsFluidos.localC(:,:,lastPos + iEle)    = [versori/norm(versori) versorj/norm(versorj) versork/norm(versork)];
    
    
    cohesivos.elements(lastPos + iEle,:)      = nodesInFisu(correctOrder);
    cohesivos.relatedEB(lastPos + iEle,:)     = relatedEB(correctOrder);
    relatedEB                       = relatedEB(correctOrder);
    relatedEBNodes                  = relatedEBNodes(correctOrder,:);
    
    cohesivos.related8Nodes(lastPos + iEle,:) = [relatedEBNodes(:,1)' relatedEBNodes(:,2)'];
end
figure
PlotMesh(nodes,elementsFluidos.elements)

figure
%% OUTPUTS
plotMeshColo3D(nodes,elements)
save('outputPreProcesadorTShape-36-10.mat','nodes','elements','elementsFisu','elementsBarra','nodosFluidos','elementsFluidos','anchoX','anchoY','anchoZ','winkler','cohesivos','CRFluidos','constraintsRelations');

                                                  
                         
                         
                         
                         
                         
                         
