nodes                   = load('MallaCasingFinalNodos.txt'); 
mapeoNodos              = nodes(:,1);
nNod                    = size(nodes,1);
nodes(:,[1 5])          = [];

% LOAD ELEMENTS FROM ADINA %%
elements                = load('MallaCasingFinalElementos.txt');
elements(:,[1 10:end])  = [];
nel                     = size(elements,1);

% MUEVO EL SISTEMA DE COORDENADAS A LA ESQUINA MAS AUSTRAL %%%%
dimSquare               = 90;
moverEjes               = [-min(nodes(:,1))*ones(nNod,1) -min(nodes(:,2))*ones(nNod,1) -min(nodes(:,3))*ones(nNod,1)];
nodes                   = nodes + moverEjes;
    
% Arreglo para que la numeracion de nodos arranque en 1%%
 for iNod = 1:size(nodes,1)
        nodoAMapear = mapeoNodos(iNod);
        elements(ismember(elements,nodoAMapear)) = iNod;
 end
 


menorz1 = nodes(elements(:,1),3) <= max(nodes(:,3))/2;
menorz2 = nodes(elements(:,2),3) <= max(nodes(:,3))/2;
menorz3 = nodes(elements(:,3),3) <= max(nodes(:,3))/2;
menorz4 = nodes(elements(:,4),3) <= max(nodes(:,3))/2;
menorz5 = nodes(elements(:,5),3) <= max(nodes(:,3))/2;
menorz6 = nodes(elements(:,6),3) <= max(nodes(:,3))/2;
menorz7 = nodes(elements(:,7),3) <= max(nodes(:,3))/2;
menorz8 = nodes(elements(:,8),3) <= max(nodes(:,3))/2;



condicionXo = double([menorz1 menorz2 menorz3 menorz4 menorz5 menorz6 menorz7 menorz8]) ;
[logicX0, indexX0] = ismembertol(condicionXo,[1 1 1 1 1 1 1 1],'OutputAllIndices',true,'ByRows',true);



index = logical(cell2mat(indexX0));

 plotMeshColo3D(nodes,elements(index,:),'w')



CX0 = C(logicX0,:);
[IX0] = agregarPuntoInterseccion(CX0,P,vecNormX,pointX0);
[NewC,P] = compararNewPoint(IX0,CX0,P,1,1);  %anteultimo input indica que coordenada comparar  y ultimo indica si la comparacion es por mayor o por menor
index = logical(cell2mat(indexX0));
puntosX0 = IX0;
[C, P] = ActualizarC(C,NewC,index,P);


