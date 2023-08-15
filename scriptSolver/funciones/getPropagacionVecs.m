function [intNodes,nodosMuertos,meshInfo,produccionDesplazamientosImpuestos,fracturing2ProductionFlag] = getPropagacionVecs( meshInfo,temporalProperties,cohesivosProperties )
%% VECTORES RELACIONADOS A LA PROPAGACION %%
%%% Estos vectores estan asociados a que nodos de fluidos estan activos, es
%%% decir que nodos porales veran sus conductividades afectadas por la
%%% fractura
%%% NOTA SOBRE EL ALGORITMO DE PROPAGACION: en este caso 3D, el algoritmo
%%% de propagacion funciona de la siguiente manera, al morir un elemento
%%% cohesivos, todos los elementos que tengan conexion con dicho cohesivo
%%% pasan a ser parte del dominio de la fractura. Es decir, se extiende la
%%% malla de fluidos hasta ese punto y se toman las superficies asociadas a
%%% este cohesivo con biot = 1.
% elementsBarra son los nodos apareados de los elementos planos cohesivos.
% relatedEB guarda cuales son las parejas de nodos que tiene cada elemento
% cohesivo.

cohesivos = meshInfo.cohesivos;
elementsFisu = meshInfo.elementsFisu;
elementsFluidos = meshInfo.elementsFluidos;
%%

intNodes = meshInfo.CRFluidos(sum(meshInfo.CRFluidos>0,2)>3,:);
intNodes = nonzeros(unique(intNodes));

[~,deadElementsBarra]                                   = ismember(cohesivos.deadCohesivos,meshInfo.elementsBarra.ALL);
deadCohesivosIntPoints                                  = ismember(cohesivos.relatedEB,deadElementsBarra);
cohesivos.deadFlag(deadCohesivosIntPoints)              = true;
nodosMuertos                                            = reshape(meshInfo.elementsBarra.ALL(unique(cohesivos.relatedEB(logical(cohesivos.deadFlag))),:),[],1);

elementsFisu.ALL.nodesInFisu                            = zeros(size(elementsFisu.ALL.nodes));
auxElements                                             = meshInfo.elements(elementsFisu.ALL.index,:);
elementsFisu.ALL.nodesInFisu(elementsFisu.ALL.nodes)    = auxElements(elementsFisu.ALL.nodes);

elementsFisu.fracturados            = sum(ismember(elementsFisu.ALL.nodesInFisu,nodosMuertos),2) > 0;                       % Este vector indica, segun como esten ordenados los elementsFisu, quienes de ellos 
                                                                                                                            % se comportan como parte de la fractura.
elementsFluidos.activos             = sum(ismember(elementsFluidos.elements,nodosMuertos),2) > 0;                           % Este vector indica, segun como esten ordenados los elementsFluidos, quienes estan activos.
elementsFluidos.activosTimes        = sparse(size(elementsFluidos.elements,1), 1);
elementsFluidos.activosTimes(:,1)   = elementsFluidos.activos;
cohesivos.deadFlagTimes             = zeros(meshInfo.nCohesivos,cohesivosProperties.npiCohesivos,1);
cohesivos.elementsFluidosActivos    = elementsFluidos.activos;
cohesivos.biot(elementsFluidos.activos,:) = 1;                                                                              % Biot == 1 si el elemento de fluidos esta activo

produccionDesplazamientosImpuestos = false;
fracturing2ProductionFlag          = false;

%%
meshInfo.cohesivos = cohesivos;
meshInfo.elementsFisu = elementsFisu; 
meshInfo.elementsFluidos = elementsFluidos;

end

