clear;clc;close all; format shortg;
set(0, 'DefaultFigureWindowStyle', 'docked'); warning('off', 'MATLAB:Figure:SetPositionDocked');
tStart=tic;
%-------------------------------------------------------------------------%
%% %%%%%%%%%%%%%%%%%%%      MAIN Parent-Child       %%%%%%%%%%%%%%%%%%%% %%
%-------------------------------------------------------------------------%
%% Variables a modificar segun lo requerido en cada corrida:
% Variables de inicio de corrida.
guardarCorrida    = 'Y'; % Si se quiere guardar la corrida. "Y" o "N".
direccionGuardado = 'C:\Users\pgarcia\Documents\Parent-Child Rev.8 29-11-2022\Resultados de corridas\ParentChild_SRV\'; % Direccion donde se guarda la informacion.
nombreCorrida     = 'ParentChild_Pedro_SRV_2'; % Nombre de la corrida. La corrida se guarda en la carpeta "Resultado de corridas" en una subcarpeta con este nombre.

cargaDatos     = 'load'; % Forma en la que se cargan las propiedades de entrada. "load" "test" "default" "change".
archivoLectura = 'ParentChild_Pedro_10.txt'; % Nombre del archivo con las propiedades de entrada. 

tSaveParcial   = []; % Guardado de resultados parciales durante la corrida. Colocar los tiempos en los cuales se quiere guardar algun resultado parcial.

restart            = 'N'; % Si no queremos arrancar la simulacion desde el principio sino que desde algun punto de partida 'Y' en caso contrario 'N'.
direccionRestart   = 'Resultados de corridas\ParentChild_Pedro\';
propiedadesRestart = 'resultadosFinISIP_1_ParentChild_Pedro.mat';

% Variables del post - procesado.
tiempoArea      = 1300; % Tiempo en el que se quiere visualizar la forma del area de fractura.
tiempoTensiones = 0; % Tiempo en el que se quiere visualizar las tensiones. Tiempo 0 equivale al final de los drainTimes.
keyPlots        = true; % Para plotear graficos intermedios. Separacion normal entre caras, presion de fractura y errores de convergencia.
%-------------------------------------------------------------------------%
%%                             PRE - PROCESO                             %%
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
%%%            LOAD MESH PROPERTIES Y PARAMETROS DE LA MALLA            %%%
%-------------------------------------------------------------------------%
marca
meshInfo = loadMesh(cargaDatos,archivoLectura); % Carga la malla y genera una estructura con los datos de la misma.

if keyPlots
    % Verificacion de malla.
    meshInfo = meshVerification(meshInfo);
    meshInfo.elements = meshInfo.elements(:,[2 6 7 3 1 5 8 4]);
    plotMeshColo3D(meshInfo.nodes,meshInfo.elements,meshInfo.cohesivos.elements,'on','off','w','r','k',1) % Se plotea la malla
    figure
    plotMeshColo3D(meshInfo.nodes,meshInfo.elements,meshInfo.cohesivos.elements,'off','on','w','r','k',1) % Se plotea la malla
end

%-------------------------------------------------------------------------%
%%%                         INPUTS y PROPERTIES                         %%%
%-------------------------------------------------------------------------%
physicalProperties   = setPhysicalProperties(cargaDatos,archivoLectura);             % Propiedades del medio y otras.          
temporalProperties   = setTemporalProperties3(cargaDatos,archivoLectura);             % Propiedades temporales. 
algorithmProperties  = setAlgorithmProperties(cargaDatos,archivoLectura);            % Propiedades del algoritmo de convergencia.                             
bombaProperties      = setBombaProperties3(meshInfo,'off',cargaDatos,archivoLectura); % Propiedades de la bomba.
produccionProperties = setProduccionProperties3(cargaDatos,archivoLectura);
[meshInfo,cohesivosProperties] = setCohesivosProperties(meshInfo,physicalProperties,temporalProperties,bombaProperties,'off',cargaDatos,archivoLectura);  % Propiedades de los elementos cohesivos. 
propanteProperties   = setPropanteProperties(cargaDatos,physicalProperties,meshInfo,archivoLectura);
SRVProperties        = setSRVProperties2(cargaDatos,'N',meshInfo,archivoLectura);
% monitoresProperties  = setMonitoresProperties(meshInfo,cargaDatos,archivoLectura,1);

if keyPlots
    % Verificacion SRV
    figure; hold on; title('SRV Plot');
    for iBomba = 1:bombaProperties.nBombas
        plotMeshColo3D(meshInfo.nodes,meshInfo.elements(SRVProperties.elementsIndex{iBomba},:),meshInfo.cohesivos.elements,'on','off','w','r','k',1) % Se plotea la malla
    end
end
    
%%
%-------------------------------------------------------------------------%
%%%                             PARAMETROS                              %%%
%-------------------------------------------------------------------------%
% -- Discretizacion de elementos.
paramDiscEle = getParamDiscEle(meshInfo,'H8'); % Obtencion de parametros de discretizacion de la malla.
meshInfo     = elementsBarreras(physicalProperties,meshInfo); % Se identifican los elementos que conforman las barreras.
% meshInfo     = nodesBarreras(physicalProperties,meshInfo); % Se identifican los nodos que conforman las barreras.

% -- Puntos de Gauss.
pGaussParam = getPGaussParam(); % Obtencion de puntos de gauss y pesos.

% -- Nodos de caras.
[nodosCara,cara] = getNodosCaras(meshInfo,paramDiscEle);

%-------------------------------------------------------------------------%
%%%                        CONDICIONES DE BORDE                         %%%
%-------------------------------------------------------------------------%
% -- Desplazamientos.
bc = sparse(paramDiscEle.nNod,paramDiscEle.nDofNod);                       % Pre alocacion de condiciones de borde.                                                                   % Identificacion de nodos overconstrained:
filterOverContrainedBorde   = false(paramDiscEle.nNod,1);                  % Hay que remover los nodos que van a estar overconstrained por culpa de
filterOverContrainedBorde(meshInfo.constraintsRelations(:,1)) = true;      % los contraints de borde en la fractura. Hay 2 sets de nodos de contraints que van a
nodesToRemove               = cara.oeste & filterOverContrainedBorde;      % quedar pegados a la fractura, entonces voy a estar pidiendo simetria y
cara.oeste(nodesToRemove)   = false;                                      % al mismo tiempo pidiendo contraints.
%nodes to remove es un vector de 0's porque esta malla no tiene simetria!

% Fijacion de las direcciones normales a cada cara.
bc(cara.este,1)     = true; 
bc(cara.oeste,1)    = true;  % La condicion de borde de simetria sigue siendo la misma.
bc(cara.norte,2)    = true; 
bc(cara.sur,2)      = true; 
bc(cara.superior,3) = true; 
bc(cara.inferior,3) = true; 


% % Todas las caras empotradas.
% bc(cara.este,:)     = true; 
% bc(cara.oeste,:)    = true;
% bc(cara.norte,:)    = true; 
% bc(cara.sur,:)      = true; 
% bc(cara.superior,:) = true; 
% bc(cara.inferior,:) = true; 
  

isFixed = logical(reshape(bc',[],1));                                      % Re orden de condiciones de borde y convercion a variable logica.

% -- Presiones.
bc_poral = logical(sparse(paramDiscEle.nDofTot_P,1));                      % Pre alocacion de variable.
                                                                                                    % Identificacion de nodos overconstrained:
nodosOverConstrained   = [nodosCara.este(ismember(nodosCara.este,meshInfo.CRFluidos(:,2:end)))      % Ahora debemos encontrar los nodos que han sido constraineados dos
                          nodosCara.oeste(ismember(nodosCara.oeste,meshInfo.CRFluidos(:,2:end)))
                          nodosCara.superior(ismember(nodosCara.superior,meshInfo.CRFluidos(:,2)))  % veces, por un lado por los contraints de fluidos y por el otro por
                          nodosCara.inferior(ismember(nodosCara.inferior,meshInfo.CRFluidos(:,2)))  % fijarle la presion en el borde Este. Para encontrarlos, sabemos que
                          nodosCara.norte(ismember(nodosCara.norte,meshInfo.CRFluidos(:,2)))        % estan en la caraEste,caraSuperior,caraInferior y decimos que los slaves(segunda fila de
                          nodosCara.sur(ismember(nodosCara.sur,meshInfo.CRFluidos(:,2)))];          % MSNodes) que esten ahi, seran descontraineados.

% Condiciones de presion poral con plano de simetria en cara oeste. Usar esta con malla chiquita de prueba que tiene simetria.
% bc_poral(cara.inferior | cara.superior | cara.este | cara.norte | cara.sur) = true;

% % % Todas las caras con presion poral definida. %usar esta con malla grande
bc_poral(cara.inferior | cara.superior | cara.este | cara.oeste| cara.norte | cara.sur) = true;

bc_poral(nodosOverConstrained)  = false;                                    % nodosOverConstrained = unique(nodosOverConstrained); No hace falta esta linea pero la dejo por las dudas.

%-------------------------------------------------------------------------%
%%%                               CARGAS                                %%%
%-------------------------------------------------------------------------%
% -- Propiedades geomecanicas de la malla.
[constitutivas,Biot] = eleProps(physicalProperties,meshInfo.nodes,meshInfo.elements,pGaussParam.upg,'on');

% Cargo directamente las externas, no las iniciales del solido.
initialSressExtS = [physicalProperties.cargasTectonicas.ShX
                    physicalProperties.cargasTectonicas.ShY
                    physicalProperties.cargasTectonicas.SvZ
                    physicalProperties.cargasTectonicas.TauXY
                    physicalProperties.cargasTectonicas.TauYZ
                    physicalProperties.cargasTectonicas.TauXZ];   
                
initialSressExtL = [physicalProperties.cargasTectonicas.ShXL
                    physicalProperties.cargasTectonicas.ShYL
                    physicalProperties.cargasTectonicas.SvZL
                    physicalProperties.cargasTectonicas.TauXYL
                    physicalProperties.cargasTectonicas.TauYZL
                    physicalProperties.cargasTectonicas.TauXZL];             
                    
initialPPoral   =  physicalProperties.poroelasticas.pPoral;
cargasRElementosBarreras
RP              = sparse(paramDiscEle.nDofTot_U,1); % Cargas del propante. Son las cargas que se aplican para mover el equilibrio y poder modelarlos como cohesivos rotos con rigidez a partir de un valor distinto de cero.

%%
%-------------------------------------------------------------------------%
%%%                         MATRICES Y TENSORES                         %%%
%-------------------------------------------------------------------------%

% -- Matriz de rigidez [K]. 
K = getStiffnessMatrix(paramDiscEle,pGaussParam,constitutivas,meshInfo);

% -- Tensor Poral [C].
C = getTensor(meshInfo,paramDiscEle,pGaussParam,1,Biot,1,'C');

% % -- Tensor de permeabilidad poral [KC].
Kperm = getMatrizPermeabilidad(physicalProperties,meshInfo,SRVProperties,'drain','N' );
KC    = getTensor(meshInfo,paramDiscEle,pGaussParam,1,1,Kperm,'KC');
KCP   = sparse(paramDiscEle.nDofTot_P,paramDiscEle.nDofTot_P); % Tensor de permeabilidad del propante.

% -- Tensor de storativity [S].
S = getTensor(meshInfo,paramDiscEle,pGaussParam,physicalProperties,1,1,'S');
SP = sparse(paramDiscEle.nDofTot_P,paramDiscEle.nDofTot_P); % Tensor de storativity del propante.

%-------------------------------------------------------------------------%
%%%                             CONSTRAINTS                             %%%
%-------------------------------------------------------------------------%
% -- Fluidos.
[CTFluidos,nCREqFluidos] = getCTFluidos(meshInfo.CRFluidos,physicalProperties.fluidoFracturante.preCondCTFluidos,paramDiscEle.nDofTot_P);

%-- Solidos. (Para borde de fractura con y sin interseccion). 
[ CTFrac ,nCREqFrac ] = getCTFrac(paramDiscEle.nodeDofs,meshInfo.constraintsRelations,algorithmProperties.precondCT,paramDiscEle.nDofTot_U);

%-- Juntado de Constraints.
zerosCTFluidosU = sparse(paramDiscEle.nDofTot_U,nCREqFluidos);
zerosCTFracP    = sparse(paramDiscEle.nDofTot_P,nCREqFrac);

allCT   = [zerosCTFluidosU' -temporalProperties.preCond*CTFluidos
           CTFrac           -temporalProperties.preCond*zerosCTFracP'
          ];

zerosCT = sparse(nCREqFluidos + nCREqFrac,nCREqFluidos + nCREqFrac);
nDofTotales = paramDiscEle.nDofTot_U + paramDiscEle.nDofTot_P + nCREqFluidos + nCREqFrac;

%-- Separacion de Dofs para resolucion de sistema de ecuaciones.
[dofsC,dofsX,dofsCU,dofsCP,dofsAT,dofsNoLineales,dofsXNoLineales] = getDofs(isFixed,bc_poral,nCREqFluidos,nCREqFrac,nDofTotales,paramDiscEle, meshInfo);

%%
%-------------------------------------------------------------------------%
%%%                         VECTORES AUXILIARES                         %%%
%-------------------------------------------------------------------------%
%-- Vectores de propagacion de fluido fracturante.
[intNodes,nodosMuertos,meshInfo,produccionDesplazamientosImpuestos,fracturing2ProductionFlag] = getPropagacionVecs(meshInfo,temporalProperties,cohesivosProperties);

%-- Vectores de converencia. (pre alocacion).
noConvergido = 1; convergido = 0; error = 1;

%%
%-------------------------------------------------------------------------%
%%%                         VARIABLES DE INTERES                        %%%
%-------------------------------------------------------------------------%
%Pre alocacion de variables.
dTimes  = zeros(nDofTotales,1);
QTimes  = zeros(paramDiscEle.nDofTot_P,1);
hhTimes = zeros(size(meshInfo.nodosFluidos.EB_Asociados,1),1);

iTime = 0;

iSaveParcial = 1;
flagSaveFrac = ones(bombaProperties.nBombas,1);
flagSaveISIP = ones(bombaProperties.nBombas,1);
flagSaveProduccion = ones(bombaProperties.nBombas,1);
restartKC    = 1; %ones(bombaProperties.nBombas,1);
productionKC = ones(bombaProperties.nBombas,1);

iDeadFlag = 1;
iFractura = 1;
iProp = ones(bombaProperties.nBombas,1);
oldPropantesVar = [];

contadorErrorConvergido = 0;
cantErrorConvergido     = 2;

if keyPlots == true
    han1 = figure('Name','Error');
    han2 = figure('Name','SeparacionPresion');
end
%-------------------------------------------------------------------------%
%%                                SOLVER                                 %%
%-------------------------------------------------------------------------%
% Como el problema tiene una componente no lineal que viene dado que la
% rigidez de los cohesivos depende de la deformacion de los mimsos para
% cada paso temporal se realizan una serie de iteraciones.
% 
% 
if strcmpi(restart,'Y') 
    variablesRestart = load([direccionRestart,propiedadesRestart],...
        'iTime','algorithmProperties','temporalProperties','dTimes','dNITER','QTimes','hhTimes','meshInfo',...
        'iFractura','propanteProperties','iProp','oldPropantesVar','SP');
    
    iTime   = variablesRestart.iTime;
    dTimes  = variablesRestart.dTimes;
    QTimes  = variablesRestart.QTimes;
    hhTimes = variablesRestart.hhTimes;
    dNITER  = variablesRestart.dNITER;
    
    algorithmProperties.elapsedTime = variablesRestart.algorithmProperties.elapsedTime;
    temporalProperties.deltaTs = variablesRestart.temporalProperties.deltaTs;
    meshInfo.cohesivos = variablesRestart.meshInfo.cohesivos;
    
    iFractura=variablesRestart.iFractura;
    iProp=variablesRestart.iProp;
    oldPropantesVar=variablesRestart.oldPropantesVar;
    SP = variablesRestart.SP;
    
    % fix para apertura final, chequear con pablo
    % Identificacion de cohesivos de fracturas que finalizaron.
    cohesivosVar                             = (1:size(meshInfo.cohesivos.elements,1))'; % Elementos a los cuales hay que cambiarles las propiedades.
    % Identificacion de cohesivos --> propantes.
    propantesVar    = cohesivosVar(all(meshInfo.cohesivos.deadFlag(cohesivosVar,:),2)); % Cohesivos que pasan a ser propantes.
    propantesVar(ismember(propantesVar,oldPropantesVar)) = []; %No vuelvo a contar los propantes que fueron creados en fracturas anteriores
    variablesRestart.propanteProperties.aperturaFinal(propantesVar,:) = propanteProperties.hP*meshInfo.cohesivos.dNCalculado(propantesVar,:);
    variablesRestart.propanteProperties.aperturaFinal(variablesRestart.propanteProperties.aperturaFinal<0) = 0;
    % fin fix chequear esto
    
    %propante: solo se permite cambiar hP y kappa
    aux_aperturaFinal = propanteProperties.hP*variablesRestart.propanteProperties.aperturaFinal/variablesRestart.propanteProperties.hP;
    KCP = KCP*propanteProperties.kappaP/variablesRestart.propanteProperties.kappaP;
    
    propanteProperties=variablesRestart.propanteProperties;
    propanteProperties.aperturaFinal = aux_aperturaFinal;
    deltaPropante = getDeltaForRPropante(propanteProperties,meshInfo,paramDiscEle,meshInfo.cohesivos);
    
    
%     meshInfo.cohesivos.dS1Times = variablesRestart.meshInfo.cohesivos.dS1Times;
%     meshInfo.cohesivos.dS2Times = variablesRestart.meshInfo.cohesivos.dS2Times;
%     meshInfo.cohesivos.dNTimes = variablesRestart.meshInfo.cohesivos.dNTimes;
%     meshInfo.cohesivos.KnTimes  = variablesRestart.meshInfo.cohesivos.KnTimes;
%     meshInfo.cohesivos.Ks1Times = variablesRestart.meshInfo.cohesivos.Ks1Times;
%     meshInfo.cohesivos.Ks2Times = variablesRestart.meshInfo.cohesivos.Ks2Times;
%     meshInfo.cohesivos.KnPrevTime = variablesRestart.meshInfo.cohesivos.KnPrevTime;
%     meshInfo.cohesivos.Ks1PrevTime = variablesRestart.meshInfo.cohesivos.Ks1PrevTime;
%     meshInfo.cohesivos.Ks2PrevTime  = variablesRestart.meshInfo.cohesivos.Ks2PrevTime;
%     meshInfo.cohesivos.biot = variablesRestart.meshInfo.cohesivos.biot;
%     meshInfo.cohesivos.elementsFluidosActivos  = variablesRestart.meshInfo.cohesivos.elementsFluidosActivos;
%     meshInfo.cohesivos.deadFlagTimes = variablesRestart.meshInfo.cohesivos.deadFlagTimes;
%     
%     meshInfo.cohesivos.positiveFlag     = variablesRestart.meshInfo.cohesivos.positiveFlag;
%     meshInfo.cohesivos.dN1              = variablesRestart.meshInfo.cohesivos.dN1;
%     meshInfo.cohesivos.damageFlagN      = variablesRestart.meshInfo.cohesivos.damageFlagN;
%     meshInfo.cohesivos.deadFlag         = variablesRestart.meshInfo.cohesivos.deadFlag;
%     meshInfo.cohesivos.KnIter           = variablesRestart.meshInfo.cohesivos.KnIter;
%     meshInfo.cohesivos.lastPositiveKn   = variablesRestart.meshInfo.cohesivos.lastPositiveKn;
%     meshInfo.cohesivos.dNMat            = variablesRestart.meshInfo.cohesivos.dNMat;
%     meshInfo.cohesivos.firstDmgFlagN    = variablesRestart.meshInfo.cohesivos.firstDmgFlagN;
%     
%     
%     meshInfo.cohesivos.dS1_1        = variablesRestart.meshInfo.cohesivos.dS1_1;
%     meshInfo.cohesivos.damageFlagS1 = variablesRestart.meshInfo.cohesivos.damageFlagS1;
%     meshInfo.cohesivos.Ks1Iter      = variablesRestart.meshInfo.cohesivos.Ks1Iter;
%     meshInfo.cohesivos.dS1Mat       = variablesRestart.meshInfo.cohesivos.dS1Mat;
%     
%     meshInfo.cohesivos.dS1_2        = variablesRestart.meshInfo.cohesivos.dS1_2;
%     meshInfo.cohesivos.damageFlagS2 = variablesRestart.meshInfo.cohesivos.damageFlagS2;
%     meshInfo.cohesivos.Ks2Iter      = variablesRestart.meshInfo.cohesivos.Ks2Iter;
%     meshInfo.cohesivos.dS2Mat       = variablesRestart.meshInfo.cohesivos.dS2Mat;
    
    meshInfo.elementsFisu.ALL.nodesInFisu = variablesRestart.meshInfo.elementsFisu.ALL.nodesInFisu;
    meshInfo.elementsFisu.fracturados = variablesRestart.meshInfo.elementsFisu.fracturados;
    meshInfo.elementsFluidos.activos = variablesRestart.meshInfo.elementsFluidos.activos; 
end

% clear
% close all
% clc
% 
% load('incorporacionPropante.mat')

% %% BORRAR
% load('fina_permM1_365.mat')
% if keyPlots == true
%     han1 = figure('Name','Error');
%     han2 = figure('Name','SeparacionPresion');
% end
%     
% propanteProperties.EP          = 10.4*1e6/145;
% propanteProperties.NuP         = 0.25;
% propanteProperties.hP          = 30/100;
% 
% propanteProperties.MP     = physicalProperties.storativity.M;
% propanteProperties.kappaP = 1.109;
% propanteProperties.KnP    = propanteProperties.EP/(3*(1-2*propanteProperties.NuP));
% propanteProperties.Ks0_1P = 0; % Sin rigidez transversal.
% propanteProperties.Ks0_2P = 0; % Sin rigidez transversal.
% 
% propanteProperties.biotP = 0.73592;
% 
% propanteProperties.propantesActivosTotales = [];
% propanteProperties.cierreFlag              = zeros(meshInfo.nCohesivos,4); %Pre alocacion de variable que luego sirve para la produccion.
% iProp = 1;
% restartKC = 0;
% KCP   = sparse(paramDiscEle.nDofTot_P,paramDiscEle.nDofTot_P); % Tensor de permeabilidad del propante.
% SP = sparse(paramDiscEle.nDofTot_P,paramDiscEle.nDofTot_P); % Tensor de storativity del propante.
% RP              = sparse(paramDiscEle.nDofTot_U,1); % Cargas del propante. Son las cargas que se aplican para mover el equilibrio y poder modelarlos como cohesivos rotos con rigidez a partir de un valor distinto de cero.
% cohesivosProperties.angDilatancy = 0;
% %%
% close all


while algorithmProperties.elapsedTime < temporalProperties.tiempoTotalCorrida
    %% Activacion de propantes luego de la fractura. 
    % Parte adaptada del codigo de multiples fracturas a este. Poreso
    % hay referencias a muchas fracturas y otros comentarios al
    % respecto. 
    if algorithmProperties.elapsedTime >= temporalProperties.tInicioISIP(iFractura) && iProp(iFractura) == 1 && strcmpi(propanteProperties.Key,'Y')
        iProp(iFractura) = 0;        
        % Identificacion de cohesivos de fracturas que finalizaron.
        cohesivosVar                             = (1:size(meshInfo.cohesivos.elements,1))'; % Elementos a los cuales hay que cambiarles las propiedades.
        % Como se ponen algunos propantes, se produce, y luego se vuelve a fracturar, ya no puedo rigidizar mas los cohesivos luego de terminada una fractura.
%         meshInfo.cohesivos.dN0(cohesivosVar,:)   = ones(numel(cohesivosVar),4); % Se cambia la separacion normal para que no se rompan mas cohesivos.
%         meshInfo.cohesivos.dN1(cohesivosVar,:)   = ones(numel(cohesivosVar),4); % Se cambia la separacion normal para que no se rompan mas cohesivos.
%         meshInfo.cohesivos.dS0_1(cohesivosVar,:) = ones(numel(cohesivosVar),4); % Se cambia la separacion normal para que no se rompan mas cohesivos.
%         meshInfo.cohesivos.dS1_1(cohesivosVar,:) = ones(numel(cohesivosVar),4); % Se cambia la separacion normal para que no se rompan mas cohesivos.
%         meshInfo.cohesivos.dS0_2(cohesivosVar,:) = ones(numel(cohesivosVar),4); % Se cambia la separacion normal para que no se rompan mas cohesivos.
%         meshInfo.cohesivos.dS1_2(cohesivosVar,:) = ones(numel(cohesivosVar),4); % Se cambia la separacion normal para que no se rompan mas cohesivos.
        
        % Identificacion de cohesivos --> propantes.
        propantesVar    = cohesivosVar(all(meshInfo.cohesivos.deadFlag(cohesivosVar,:),2)); % Cohesivos que pasan a ser propantes.
        propantesVar(ismember(propantesVar,oldPropantesVar)) = []; %No vuelvo a contar los propantes que fueron creados en fracturas anteriores
        oldPropantesVar = [oldPropantesVar;propantesVar]; %los propantes de la presente fractura, seran oldPropantes para la siguiente fractura
        propantesH8Var  = meshInfo.cohesivos.related8Nodes(propantesVar,:);
        %         propantesH8Var  = propantesH8Var(:,[8 5 6 7 4 1 2 3]);
        propantesH8Var  = propantesH8Var(:,[8 4 1 5 7 3 2 6]); % Cambia aca y en la funcion getNodosDesplazados2
        nPropantesVar   = numel(propantesVar);
        
        %KCGap - KCPropante
        displacements                      = reshape(dTimes(1:paramDiscEle.nDofTot_U,iTime),3,[])';
        [nodosDesplazados,aperturasNormal] = getNodosDesplazados2(meshInfo.nodes,propantesVar,meshInfo.cohesivos,propanteProperties,meshInfo.cohesivos.dNCalculado); % No usar separacion promedio.

       
        nodesEle = zeros(paramDiscEle.nNodEl,paramDiscEle.nDofNod,nPropantesVar);
        col      = cell(nPropantesVar,1);
        row      = cell(nPropantesVar,1);
   
        for iEle = 1:nPropantesVar
            col{iEle}          = repmat(propantesH8Var(iEle,:)',1,paramDiscEle.nNodEl);
            row{iEle}          = col{iEle}';
            nodesEle(:,:,iEle) = nodosDesplazados{iEle}; 
        end
        
        KpermP = repmat(propanteProperties.kappaP*eye(3,3),1,1,8);
        KCeP   = cell(nPropantesVar,1);
        for iEle = 1:nPropantesVar
            KCeP{iEle}  =  gradiente_poral(pGaussParam.npg,pGaussParam.upg,pGaussParam.wpg,nodesEle(:,:,iEle),paramDiscEle.nNodEl,KpermP);
            if any(diag(KCeP{iEle}) < 0)
                warning(['Valor de la diagonal en el KCeP negativo del elemento: ',num2str(iEle)])
            end
        end
        KCPVar = sparse(vertcat(row{:}),vertcat(col{:}),vertcat(KCeP{:}),paramDiscEle.nDofTot_P,paramDiscEle.nDofTot_P);       
        KCP    = KCP + KCPVar;
        
        SeP = cell(nPropantesVar,1);
        for iEle = 1:nPropantesVar
            SeP{iEle} = poral_temporal(pGaussParam.npg,pGaussParam.upg,pGaussParam.wpg,nodesEle(:,:,iEle),paramDiscEle.nNodEl,physicalProperties.storativity.M);
        end
        SPVar = sparse(vertcat(row{:}),vertcat(col{:}),vertcat(SeP{:}),paramDiscEle.nDofTot_P,paramDiscEle.nDofTot_P);      
        SP = SP + SPVar;
        
        % Actualizacion de valores totales.
        propanteProperties.propantesActivosTotales = [propanteProperties.propantesActivosTotales; propantesVar];
        propanteProperties.nPropantes              = numel(propanteProperties.propantesActivosTotales);
        
        propanteProperties.elements.Q4(propantesVar,:)   = meshInfo.cohesivos.elements(propantesVar,:);
        propanteProperties.elements.H8(propantesVar,:)   = meshInfo.cohesivos.related8Nodes(propantesVar,:);
        propanteProperties.aperturaFinal(propantesVar,:) = propanteProperties.hP*meshInfo.cohesivos.dNCalculado(propantesVar,:);
        propanteProperties.aperturaFinal(propanteProperties.aperturaFinal<0) = 0;
        deltaPropante = getDeltaForRPropante(propanteProperties,meshInfo,paramDiscEle,meshInfo.cohesivos);
    end   
    
    
    %% ACTUALIZO VARIABLES DEL TIEMPO ANTERIOR %
    iTime = iTime+1;
    if keyPlots
        drawnow
    end
    if iTime == 1                                                                                                           
        % Si es el inicio de la operacion. Variable de iniciacion de iteraciones de vector solucion.                      % d0
        dPrev   = [ sparse(paramDiscEle.nDofTot_U,1)                                                                      % desplazamientos
                    physicalProperties.poroelasticas.pPoral / temporalProperties.preCond * ones(paramDiscEle.nDofTot_P,1) % presiones
                    sparse(nCREqFluidos,1)                                                                                % lambdaCT: contraints desplazamiento 
                    sparse(nCREqFrac,1)                                                                                   % lambdaCTFrac: constraints presiones
                    ];                                                                             % lambdaCTWinkler: constraints winklers
        
        hhPrev  = zeros(size(unique(meshInfo.cohesivos.elements))); % hh0
        dNPrev  = zeros(size(unique(meshInfo.cohesivos.elements))); % gap0. Desplazamiento normal.
        %dS1Prev = zeros(meshInfo.nElEB,1); % gap0. Desplazamiento tangencial.
        %dS2Prev = zeros(meshInfo.nElEB,1); % gap0. Desplazamiento tangencial 2.
    else
        dPrev   = dTimes(:,iTime-1);
        hhPrev  = hhTimes(:,iTime - 1);
        dNPrev  = dNITER;
        %dS1Prev = zeros(meshInfo.nElEB,1);
        %dS2Prev = zeros(meshInfo.nElEB,1);
    end
    
    %% CONDICIONES QUE CAMBIAN CON EL TIEMPO %%
    % Cambian con el tiempo pero permanecen constantes con las iteraciones.
    if iTime > temporalProperties.drainTimes
        deltaT = temporalProperties.deltaTs(iTime);
    else
        deltaT = temporalProperties.deltaTdrainTimes;
    end
    display(iTime);
 
    %% Cambio de KC.
    if restartKC==1 && iTime>temporalProperties.drainTimes
        Kperm     = getMatrizPermeabilidad(physicalProperties,meshInfo,SRVProperties,'frac','Y' );                                                                                   % Luego de terminada una produccion (con permeabilidad de SRV), se vuelve a poner la permeabilidad (baja) de matriz.
        KC        = getTensor(meshInfo,paramDiscEle,pGaussParam,1,1,Kperm,'KC');
        restartKC= 0;
    elseif strcmpi(SRVProperties.key,'Y') && productionKC(iFractura) == 1 && algorithmProperties.elapsedTime >= temporalProperties.tInicioProduccion(iFractura) % Se establece el valor de permeabilidad mas elevado para el SRV que se activa durante la produccion. 
        auxSRV.elementsIndex=SRVProperties.elementsIndex{iFractura};
        Kperm        = getMatrizPermeabilidad(physicalProperties,meshInfo,auxSRV,'produccion','Y' );
        KC           = getTensor(meshInfo,paramDiscEle,pGaussParam,1,1,Kperm,'KC');
        productionKC(iFractura) = 0;
    end

%     if restartKC(iFractura) == 1 && iTime>temporalProperties.drainTimes && (iFractura==1 || (algorithmProperties.elapsedTime >= temporalProperties.tFinalProduccion(iFractura-1))) % Durante los drain times la permeabilidad esta alta para acelerar el estado estacionario. Aca se establecen los valores correctos para shale y barreras.
%         Kperm     = getMatrizPermeabilidad(physicalProperties,meshInfo,SRVProperties,'frac','Y' );                                                                                   % Luego de terminada una produccion (con permeabilidad de SRV), se vuelve a poner la permeabilidad (baja) de matriz.
%         KC        = getTensor(meshInfo,paramDiscEle,pGaussParam,1,1,Kperm,'KC');
%         restartKC(iFractura) = 0;
%     elseif strcmpi(SRVProperties.key,'Y') && productionKC(iFractura) == 1 && algorithmProperties.elapsedTime >= temporalProperties.tInicioProduccion(iFractura) % Se establece el valor de permeabilidad mas elevado para el SRV que se activa durante la produccion. 
%         Kperm        = getMatrizPermeabilidad(physicalProperties,meshInfo,SRVProperties,'produccion','Y' );
%         KC           = getTensor(meshInfo,paramDiscEle,pGaussParam,1,1,Kperm,'KC');
%         productionKC(iFractura) = 0;
%     end

    %% ITERACIONES DE FRACUTRA %%
    % Variables que cambian con cada iteracion. Se definen las variables de
    % la iteracion anterior.
    dPrevITER       = dPrev;
    hhIter          = hhPrev;
    dNPrevITER      = dNPrev;
    %dS1             = dS1Prev;
    %dS2             = dS2Prev;
    error           = noConvergido;
    nIter           = 0;
    %% FLUSH d %%
    dITER = zeros(nDofTotales,1);
    dR_dofsTotales = sparse(nDofTotales,1);
    
    %% CONDICIONES DE BORDE  %%
    %%% Qbomba %%%
    if iTime <= temporalProperties.drainTimes
        Q = sparse(paramDiscEle.nDofTot_P,1); 
        if iTime==1
            meshInfo.cohesivos.deadFlag=meshInfo.cohesivos.deadFlag*0; %durante los drainTimes no quiero ningun nodo roto
        end
    else
        if iDeadFlag==1 %al terminar los drainTimes, rompo todos los nodos de los 4 elementos que rodean al nodo bomba.
            elementsARomper = any(meshInfo.cohesivos.elements==bombaProperties.nodoBomba(iFractura),2); %para encontrar los 4 elements que tocan al nodo bomba de la fractura i
            meshInfo.cohesivos.deadFlag(elementsARomper,:)=1; %rompo los 4 nodos de esos 4 elements. En el plot, se veran 9 nodos rotos (4 elements rotos)
            iDeadFlag=0;
        end
        if algorithmProperties.elapsedTime < temporalProperties.tInicioISIP(iFractura) % Estamos fracturando y antes del ISIP.
            tFrac = algorithmProperties.elapsedTime - temporalProperties.tInicioFrac(iFractura);
            %Qbomba = zeros(bombaProperties.nBombas,1);
            for i=iFractura %1:bombaProperties.nBombas
                Qbomba = getInterpValue(bombaProperties.tbombas(i,:),bombaProperties.Qbombas(i,:),tFrac);
            end
            Q = sparse(bombaProperties.nodoBomba(iFractura),1,Qbomba,paramDiscEle.nDofTot_P,1); % Solo caudal en la fractura actual.
            
        elseif algorithmProperties.elapsedTime < temporalProperties.tInicioProduccion(iFractura) % Terminamos de fracturar y estamos en el ISIP de la fractura nro i, antes de la produccion.
            Q = sparse(paramDiscEle.nDofTot_P,1); % Durante el ISIP valor cero en los caudales.
            
        else % Empezamos la produccion.
            if strcmpi(produccionProperties.modoProduc,'p') % Si fijamos una contrapresion para producir.
                Q       = sparse(paramDiscEle.nDofTot_P,1); % Solo se pre aloca el vector porque no se conoce. El solver lo determina en funcion a la contrapresion de produccion.
            elseif strcmpi(produccionProperties.modoProduc,'q') % Si fijamos un caudal cte de produccion.
                tProduc = algorithmProperties.elapsedTime - temporalProperties.tFinalISIP(iFractura);
                %QProduc = zeros(bombaProperties.nProduccion,1);
                for i = iFractura %1:bombaProperties.nProduccion %para cada nodo produccion:
                    QProduc = getInterpValue(produccionProperties.tColumna(i,:),produccionProperties.QProduc(i,:),tProduc);
                end
                Q       = sparse(bombaProperties.nodoBomba(iFractura),1,QProduc,paramDiscEle.nDofTot_P,1);
            end
        end
    end
    
    %% GRADOS DE LIBERTAD CONOCIDOS %%
    if iTime <= temporalProperties.drainTimes
        dITER(dofsCP) = physicalProperties.poroelasticas.pPoral/temporalProperties.preCond;
    else
        if strcmpi(produccionProperties.frontImperm ,'Y') % Pasados los drain times se vuelve impermeable la frontera.
            dofsCP(:) = false;
            dofsC     = dofsCP | dofsCU;
            dofsX     = ~dofsC;
        end
        
        dITER(dofsCP) = physicalProperties.poroelasticas.pPoral/temporalProperties.preCond; % A todos los dofs conocidos de presion le ponemos la poral inicial. Esa es la condicion de borde en los extremos. Para los nodos produccion activos lo reescribimos despues.
        
        if algorithmProperties.elapsedTime >= temporalProperties.tInicioProduccion(iFractura) && strcmpi(produccionProperties.modoProduc,'p') % Si estamos en produccion y conocemos la contrapresion en los nodos bomba hay que fijarlos a dicha contra presion.
            tProduc = algorithmProperties.elapsedTime - temporalProperties.tFinalISIP(iFractura);
            %pCol = zeros(bombaProperties.nProduccion,1);
            for i=iFractura %1:bombaProperties.nProduccion
                dofsCP(paramDiscEle.nDofTot_U+bombaProperties.nodoBomba(iFractura)) = false; %a menos que entre en el if de abajo, no conozco la presion del nodo
                pCol = getInterpValue(produccionProperties.tColumna(i,:),produccionProperties.pColumna(i,:),tProduc);
                if pCol>0 %si ese nodo aun no esta produciendo o ya termino de producir, pCol=0 (hace de flag) y tengo Q=0 y no conozco la presion. Si sí esta produciendo, pCol>0 y entro en el if
                    dofsCP(paramDiscEle.nDofTot_U+bombaProperties.nodoBomba(iFractura)) = true; % Se modifica el vector logico para indicar que se conoce la presion en el nodo de produccion de la fractura i.
                    dITER(paramDiscEle.nDofTot_U+bombaProperties.nodoBomba(iFractura)) = pCol;  %se asigna la presion de produccion calculada a ese nodo de produccion
                end
            end
            minP = dPrev(paramDiscEle.nDofTot_U+bombaProperties.nodoBomba(iFractura));  % Cuidado que solo nos fijamos en aquellas fracturas que fueron activadas en un principio.
            %minP = min(dPrev(paramDiscEle.nDofTot_U+bombaProperties.nodoProduccion)); %tenia un "min" de cuando producia por varios nodos a la vez
            if minP < min(pCol)
                warning 'Contrapresion mas elevada que presion en el reservorio. Achicar valor de contrapresion inicial'; %Esto sirve para el primer timestep de produccion (despues esta de más), para ver que la contrapresion de produccion no sea mayor a la presion que habia antes
                assert(minP >= pCol);
            end
            dofsC = dofsCP | dofsCU;
            dofsX = ~dofsC;
        end
    end
    dITER(dofsCU) = 0; % Siempre cero al menos que impongamos desplazamientos como condiciones de borde.
    
    %% SOLVE FOR d CONVERGENCE (ITERACIONES DE PICARD) %%
    tic
    while error == noConvergido  
        %% CALCULO [KCohesivos] DEPENDIENTE DE d %% (Razon de la alinealidad del problema)
        [row, col,~] = getMapping(paramDiscEle.nDofElCohesivos,meshInfo.nCohesivos,8,3,paramDiscEle.nodeDofs,meshInfo.cohesivos.related8Nodes,meshInfo.nodes,'Kch');
        rowAux       = cell(meshInfo.nCohesivos,1); colAux = cell(meshInfo.nCohesivos,1);
        
        KCohesivosE         = cell(meshInfo.nCohesivos,1);
        KCohesivosEPropante = cell(meshInfo.nCohesivos,1);
        KTanCohesivosE      = cell(meshInfo.nCohesivos,1);
        Cce                 = cell(meshInfo.nCohesivos,1);
        
        for iEle = 1:meshInfo.nCohesivos % Aca se cambia la forma de calcular la rigidez de los cohesivos ya rotos. Tengo que decirle que solo se fije en la fractura pertinente.
            if any(iEle == propanteProperties.propantesActivosTotales)
                [KCohesivosE{iEle}, KTanCohesivosE{iEle},KnIter, Ks1Iter,Ks2Iter,dD,meshInfo.cohesivos,Cce{iEle},propanteProperties ] = interfaceElementsPropantes( iEle,meshInfo.nodes , paramDiscEle.nDofEl ,meshInfo.cohesivos,iTime,dPrevITER,dPrev,propanteProperties);
                KCohesivosEPropante{iEle} = KCohesivosE{iEle};
            else
                [KCohesivosE{iEle}, KTanCohesivosE{iEle},KnIter, Ks1Iter,Ks2Iter,dD,meshInfo.cohesivos,Cce{iEle} ] = interfaceElements3D( iEle,meshInfo.nodes , paramDiscEle.nDofEl ,meshInfo.cohesivos,iTime,dPrevITER,dPrev,cohesivosProperties);
                KCohesivosEPropante{iEle} = sparse(24,24);
            end
            poralDofs = meshInfo.cohesivos.related8Nodes(iEle,1:4);
            rowAux{iEle} = repmat(poralDofs,paramDiscEle.nDofEl,1);
            colAux{iEle} = col{iEle}(:,1:4);
        end
        
        KCohesivos    = sparse(vertcat(row{:}),vertcat(col{:}),vertcat(KCohesivosE{:}),paramDiscEle.nDofTot_U,paramDiscEle.nDofTot_U);
        KTanCohesivos = sparse(vertcat(row{:}),vertcat(col{:}),vertcat(KTanCohesivosE{:}),paramDiscEle.nDofTot_U,paramDiscEle.nDofTot_U);
        Cc = sparse(vertcat(colAux{:}),vertcat(rowAux{:}),vertcat(Cce{:}),paramDiscEle.nDofTot_U,paramDiscEle.nDofTot_P);
        RPresiones    = (C'+Cc')*dPrev(1:paramDiscEle.nDofTot_U) + (S+SP)*dPrev(paramDiscEle.nDofTot_U+1:paramDiscEle.nDofTot_U+paramDiscEle.nDofTot_P)*temporalProperties.preCond;
            
        if any(propanteProperties.propantesActivosTotales)
            KCohesivosPropante = sparse(vertcat(row{:}),vertcat(col{:}),vertcat(KCohesivosEPropante{:}),paramDiscEle.nDofTot_U,paramDiscEle.nDofTot_U);
            RP                 = KCohesivosPropante*deltaPropante;
        end     
                
        %% MATRIZ CONDUCTIVIDAD FLUIDOS FRACTURA [H] %%%
        % ACOPLE  H A KPORAL
        masterDofs = meshInfo.elementsFluidos.elements(meshInfo.elementsFluidos.activos',:)';
        [row, col] = getMap(masterDofs);
        
        He = cell(sum(meshInfo.elementsFluidos.activos),1);
        aux = 1:meshInfo.nFluidos; aux2 = 1;
        
        for iEle = aux(meshInfo.elementsFluidos.activos)
            if any(iEle == propanteProperties.propantesActivosTotales)
                He{aux2} = zeros(4,4);
                aux2     = aux2+1;
            else
                He{aux2} = HFluidos2D(meshInfo.elementsFluidos,iEle,hhIter(meshInfo.nodosFluidos.EB_Asociados,1),physicalProperties.fluidoFracturante.MU,meshInfo.cohesivos,meshInfo.nodes,cohesivosProperties.angDilatancy);
                aux2     = aux2+1;
            end
        end
        H = sparse(vertcat(row{:}),vertcat(col{:}),vertcat(He{:}),paramDiscEle.nDofTot_P,paramDiscEle.nDofTot_P);
        
        %% ARMO LA [KGLOBAL] %%
        mainSYSTEM = [ (K + KCohesivos)                             -temporalProperties.preCond*(C+Cc)
                       -temporalProperties.preCond*(C'+Cc')         -(temporalProperties.preCond^2)*(S+ SP + (temporalProperties.tita*deltaT*(KC+KCP+H)))];
        
        KGLOBAL    = [mainSYSTEM    allCT'
                      allCT         zerosCT];
        
        %% ARMO LA MATRIZ TANGENTE G %%
        mainSYSTEMG       = [(K + KTanCohesivos)                      -temporalProperties.preCond*(C+Cc)
                              -temporalProperties.preCond*(C'+Cc')    -(temporalProperties.preCond^2)*(S+ SP + (temporalProperties.tita*deltaT*(KC+KCP+H)))];
        
        G                 = [mainSYSTEMG    allCT'
                             allCT          zerosCT];
        
        %% SOLVE FOR dITER %%
        % Se resuelve todas las variables (desplazamientos, presiones y
        % constraints) en un mismo vector d.
        
        FITER = [  R + RP
                 -(deltaT*Q  + RPresiones)*temporalProperties.preCond
                 -sparse(nCREqFluidos,1)
                  sparse(nCREqFrac,1)];
        
             
        dR_X = ((KGLOBAL(dofsX,dofsX) *dPrevITER(dofsX)) + (KGLOBAL(dofsX,dofsC) *dPrevITER(dofsC))  - FITER(dofsX));
             
        deltaClassic = G(dofsX,dofsX)\ dR_X;
        dITER(dofsX) = dPrevITER(dofsX) - deltaClassic;
        fITER        = KGLOBAL*dITER;
        QITER        = ((fITER(paramDiscEle.nDofTot_U+1:paramDiscEle.nDofTot_U+paramDiscEle.nDofTot_P)*-1)-RPresiones)/deltaT/0.00264979 / (1000)^3;
     
        %% ACTUALIZACION PARA LA SIGUIENTE ITERACION %%
        %%% MODIFICACION DE LA RELAJACION %%%
        nIter = nIter + 1;
        auxRemake = reshape(meshInfo.cohesivos.relatedEB,[],1);
        dNITER = gapCalculator3(meshInfo.nodes,meshInfo.cohesivos,dITER);
        
        dPrevITER_Error  = dPrevITER; % Esta linea guarda el valor de la iteracion previa para usarla en el error.
        dPrevITER        = dITER;
        dNPrevITER_Error = dNPrevITER;
        dNPrevITER       = dNITER;
        
        %dS1 = reshape(meshInfo.cohesivos.dS1Calculado, [],1); %dS1,2 no se usan nunca para nada!
        %dS2 = reshape(meshInfo.cohesivos.dS2Calculado, [],1); %dS1,2Prev nunca se actualizan, siempre valen 0
        hhIter                  = dNITER;
        hhIter(hhIter<0)        = 0;
        
        %% COMPUTACION DEL ERROR %%
        if strcmp(algorithmProperties.criterio,'VARIABLES')
            uITER = dITER(1:paramDiscEle.nDofTot_U);
            pITER = dITER(paramDiscEle.nDofTot_U+1:paramDiscEle.nDofTot_U+paramDiscEle.nDofTot_P)*temporalProperties.preCond;
            
            uPrevITER = dPrevITER_Error(1:paramDiscEle.nDofTot_U);
            pPrevITER = dPrevITER_Error(paramDiscEle.nDofTot_U+1:paramDiscEle.nDofTot_U+paramDiscEle.nDofTot_P)*temporalProperties.preCond;
            
            errorRelU{iTime}(1,nIter) = norm(uITER - uPrevITER ) / norm(uITER); % Antes del 12/4/2022 se normalizaba segun variables dPrevITER. 
            errorRelP{iTime}(1,nIter) = norm(pITER - pPrevITER ) / norm(pITER);
            errorRelCohesivos{iTime}(1,nIter) = norm(dNITER - dNPrevITER_Error) / norm(dNITER);

%             errorRelU{iTime}(1,nIter) = norm(uITER - uPrevITER );
%             errorRelP{iTime}(1,nIter) = norm(pITER - pPrevITER );
%             errorRelCohesivos{iTime}(1,nIter) = norm(dN - dNPrevITER_Error);

            if keyPlots == true
                figure(han1)
                set(han1,'Position',[1 41 768 748.8]);
                plotError
                figure(han2)
                
            end
            if errorRelU{iTime}(1,nIter) <= algorithmProperties.toleranciaU && errorRelP{iTime}(1,nIter) <= algorithmProperties.toleranciaP && errorRelCohesivos{iTime}(1,nIter) <= algorithmProperties.toleranciaCohesivos
                contadorErrorConvergido = contadorErrorConvergido + 1;
                if contadorErrorConvergido >= cantErrorConvergido
                    error = convergido;
                    contadorErrorConvergido = 0;
                end
            end
        end
        if nIter > algorithmProperties.nIterDiv
            dPrevITER       = dPrev;
            hhIter          = hhPrev;
            dNPrevITER      = dNPrev;
            %dS1             = dS1Prev;
            %dS2             = dS2Prev;
            error           = noConvergido;
            nIter           = 0;
            disp(['Paso las ',num2str(algorithmProperties.nIterDiv),' iteraciones, divirgió, se reduce el timestep a la mitad y se comienza nuevamente'])
            deltaT          = deltaT/2;
            if deltaT <= 1e-9
                warning 'Error: deltaT <= 1e-9. Posible divergencia eterna. Revisar parametros.';
                assert(deltaT > 1e-9)
            end
            temporalProperties.deltaTs(iTime) = deltaT;
            display(deltaT);
            algorithmProperties.flagDiv  = 1;
            
            errorRelU{iTime} = [];
            errorRelP{iTime} = [];
            errorRelCohesivos{iTime} = [];
            
        end
    end
    tTimestep=toc;
    disp(['Tiempo computacional del timestep: ' num2str(tTimestep) ' seg']);
    %% ALGORITMO DE TIMESTEPS %%
    auxx = sprintf('Convirgio en %d iteraciones',nIter);
    disp(auxx)
    
    if iTime > temporalProperties.drainTimes
        algorithmProperties.elapsedTime = algorithmProperties.elapsedTime + deltaT;
    end
    
    if algorithmProperties.elapsedTime <= temporalProperties.tInicioISIP(iFractura)
        fprintf(['Fractura N: ',num2str(iFractura),'\n'])
        auxx = sprintf('Tiempo de fractura: %d s de %d s',algorithmProperties.elapsedTime - temporalProperties.tInicioFrac(iFractura),temporalProperties.tFinalFrac(iFractura)-temporalProperties.tInicioFrac(iFractura));
        disp(auxx)
    elseif algorithmProperties.elapsedTime <= temporalProperties.tFinalISIP(iFractura)
        fprintf('ISIP\n')
        auxx = sprintf('Tiempo de ISIP: %d s de %d s',algorithmProperties.elapsedTime - temporalProperties.tInicioISIP(iFractura), temporalProperties.tFinalISIP(iFractura)-temporalProperties.tInicioISIP(iFractura));
        disp(auxx)
    else
        fprintf(['Produccion a ','p',' cte\n'])
        auxx = sprintf('Tiempo de Produccion: %d s de %d s',algorithmProperties.elapsedTime - temporalProperties.tInicioProduccion(iFractura),temporalProperties.tFinalProduccion(iFractura)-temporalProperties.tInicioProduccion(iFractura));
        disp(auxx)
    end
    fprintf(['Tiempo total de corrida: ',num2str(algorithmProperties.elapsedTime ),' de ',num2str(temporalProperties.tiempoTotalCorrida),'\n'])
    
    if iTime > (temporalProperties.drainTimes + temporalProperties.initTimes) %los initTimes no los termino de entender.
        if algorithmProperties.elapsedTime >= temporalProperties.tInicioISIP(iFractura) && algorithmProperties.elapsedTime < temporalProperties.tFinalISIP(iFractura)
            temporalProperties.deltaTs(iTime + 1) = temporalProperties.deltaTISIP;
        else
            if algorithmProperties.elapsedTime >= temporalProperties.tFinalISIP(iFractura)
                temporalProperties.deltaTMax = temporalProperties.deltaTProduccionMax; % Actualiza el maximo del timestep para la produccion.
            end
                if nIter < algorithmProperties.nIterFast && algorithmProperties.flagDiv == 0
                    disp('Convergencia rapida, deltaT = deltaT*2')
                    temporalProperties.deltaTs(iTime + 1) = deltaT*10;
                else
                    if nIter>= algorithmProperties.nIterSlow
                        disp('Convergencia lenta, deltaT = deltaT/2')
                        temporalProperties.deltaTs(iTime + 1) = deltaT/2;
                    else
                        disp('Convergencia regular deltaT se mantiene')
                        temporalProperties.deltaTs(iTime + 1) = deltaT;
                    end
                end
                if deltaT*2 > temporalProperties.deltaTMax
                    temporalProperties.deltaTs(iTime + 1) = temporalProperties.deltaTMax; % Si converge rapido pero el proximo deltaT es mayor al maximo, se deja el maximo.
                    disp('deltaT del proximo timestep mayor a deltaTMax, se continua con el maximo')
                end
        end
        %Si con el proximo deltaT se pasa del tiempo de fractura, se elige un deltaT tal que cumpla justo con el tiempo de fractura
        if algorithmProperties.elapsedTime + temporalProperties.deltaTs(iTime + 1) > temporalProperties.tInicioISIP(iFractura) && algorithmProperties.elapsedTime < temporalProperties.tInicioISIP(iFractura)
            temporalProperties.deltaTs(iTime + 1) = temporalProperties.tInicioISIP(iFractura) - algorithmProperties.elapsedTime;
        end
        
        %Si con el proximo deltaT se pasa del tiempo de ISIP, se elige un deltaT tal que cumpla justo con el tiempo de ISIP
        if algorithmProperties.elapsedTime + temporalProperties.deltaTs(iTime + 1) > temporalProperties.tInicioProduccion(iFractura) && algorithmProperties.elapsedTime < temporalProperties.tInicioProduccion(iFractura)
            temporalProperties.deltaTs(iTime + 1) = temporalProperties.tInicioProduccion(iFractura) - algorithmProperties.elapsedTime;
        end
        
        %Si con el proximo deltaT se pasa del tiempo de produccion, se elige un deltaT tal que cumpla justo con el tiempo de produccion
        if algorithmProperties.elapsedTime + temporalProperties.deltaTs(iTime + 1) > temporalProperties.tFinalProduccion(iFractura) && algorithmProperties.elapsedTime < temporalProperties.tFinalProduccion(iFractura)
            temporalProperties.deltaTs(iTime + 1) = temporalProperties.tFinalProduccion(iFractura) - algorithmProperties.elapsedTime;
        end
        
        %Si llegue al final de produccion, en el proximo timestep comienza una fractua. Usamos deltaT pequeño de fractura.
        if algorithmProperties.elapsedTime == temporalProperties.tFinalProduccion(iFractura)
            temporalProperties.deltaTs(iTime + 1) = temporalProperties.deltaT; %el mismo que se usa en initTimes, ni bien terminan los drainTimes
        end

    end
        
    algorithmProperties.flagDiv = 0;
    disp('siguiente deltaT = ')
    disp(temporalProperties.deltaTs(iTime+1))
    %% ACTUALIZO CON LOS VALORES CONVERGIDOS %%
    dTimes(:,iTime)                 = dITER;
    QTimes(:,iTime)                 = QITER;
    hhTimes(:,iTime) = hhIter; %este es dNITER.*(dNITER>0) !!!
    meshInfo.cohesivos = gapCalculator4(meshInfo.nodes,meshInfo.cohesivos,dITER);
    meshInfo.cohesivos.dS1Times(:,:,iTime)   = meshInfo.cohesivos.dS1Calculado; %valor en los GP, fuera del while() de convergencia, no lo cambio.
    meshInfo.cohesivos.dS2Times(:,:,iTime)   = meshInfo.cohesivos.dS2Calculado;
    meshInfo.cohesivos.dNTimes(:,:,iTime)    = meshInfo.cohesivos.dNCalculado;
    
    %% ACTUALIZACION DE LOS FLAGS DE LOS COHESIVOS Y SUS VARIABLES %%
    for iCohesivos = 1:meshInfo.nCohesivos
        for iPg = 1:4
            [meshInfo.cohesivos] = updateCohesivoNorm2(meshInfo.cohesivos,meshInfo.cohesivos.dNCalculado(iCohesivos,iPg),meshInfo.cohesivos.dNCalculadoPrev(iCohesivos,iPg),iCohesivos,iTime,iPg);
            [meshInfo.cohesivos] = updateCohesivoShearKsi(meshInfo.cohesivos,meshInfo.cohesivos.dS1Calculado(iCohesivos,iPg),meshInfo.cohesivos.dS1CalculadoPrev(iCohesivos,iPg),iCohesivos,iTime,iPg);
            [meshInfo.cohesivos] = updateCohesivoShearEta(meshInfo.cohesivos,meshInfo.cohesivos.dS2Calculado(iCohesivos,iPg),meshInfo.cohesivos.dS2CalculadoPrev(iCohesivos,iPg),iCohesivos,iTime,iPg);
        end
    end
    
    meshInfo.cohesivos.KnTimes(:,:,iTime)  = meshInfo.cohesivos.KnIter;
    meshInfo.cohesivos.Ks1Times(:,:,iTime) = meshInfo.cohesivos.Ks1Iter;
    meshInfo.cohesivos.Ks2Times(:,:,iTime) = meshInfo.cohesivos.Ks2Iter;
    
    meshInfo.cohesivos.KnPrevTime          = meshInfo.cohesivos.KnIter;
    meshInfo.cohesivos.Ks1PrevTime         = meshInfo.cohesivos.Ks1Iter;
    meshInfo.cohesivos.Ks2PrevTime         = meshInfo.cohesivos.Ks2Iter;
    
    %% ACTUALIZACION DE VECTORES DE PROPAGACIÓN %%
    
    nodosMuertos             = reshape(meshInfo.elementsBarra.ALL(unique(meshInfo.cohesivos.relatedEB(logical(meshInfo.cohesivos.deadFlag))),:),[],1);
    deadIntNodes             = ismember(intNodes,nodosMuertos);
    
    if any(deadIntNodes)
        deadIntNodesIndex    = intNodes(deadIntNodes);
        nodesToAdd           = nonzeros(unique(reshape(meshInfo.CRFluidos(sum(ismember(meshInfo.CRFluidos,deadIntNodesIndex),2)>0,:),[],1)));
        nodosMuertos         = unique([nodosMuertos
                                       nodesToAdd ]);
    end
    
    meshInfo.elementsFisu.ALL.nodesInFisu = zeros(size(meshInfo.elementsFisu.ALL.nodes));
    auxElements                           = meshInfo.elements(meshInfo.elementsFisu.ALL.index,:);
    meshInfo.elementsFisu.ALL.nodesInFisu(meshInfo.elementsFisu.ALL.nodes) = auxElements(meshInfo.elementsFisu.ALL.nodes);
    
    meshInfo.elementsFisu.fracturados                           = sum(ismember(meshInfo.elementsFisu.ALL.nodesInFisu,nodosMuertos),2) > 0;    % Este vector indica, segun como esten ordenados los elementsFisu, quienes de ellos
    % se comportan como parte de la fractura.
    meshInfo.elementsFluidos.activos                            = sum(ismember(meshInfo.elementsFluidos.elements,nodosMuertos),2) > 0;        % Este vector indica, segun como esten ordenados los elementsFluidos, quienes estan activos.
    meshInfo.cohesivos.biot(meshInfo.elementsFluidos.activos,:) = 1;
    meshInfo.cohesivos.elementsFluidosActivos                   = meshInfo.elementsFluidos.activos;
    meshInfo.cohesivos.deadFlagTimes(:,:,iTime+1)               = meshInfo.cohesivos.deadFlag;    
    
%     assert(~any(ismember(meshInfo.cohesivos.elements(meshInfo.cohesivos.deadFlag),meshInfo.nodosGendarmes)),['Fractura excede limites. Tiempo de corrida = ',num2str(algorithmProperties.elapsedTime),'s'])
    
    if keyPlots == true
        figure(han2)
        set(han2,'Position',[769.8 41.8 766.4 740.8]);
        clf
        subplot(1,2,1)
        bandplot(meshInfo.cohesivos.elements,meshInfo.nodes,meshInfo.cohesivos.dNTimes(:,:,iTime))
        axis square
        view(-45,20)
        daspect([1 1 1])
        hold on
%         scatter3(meshInfo.nodes(reshape(meshInfo.elementsBarra.ALL(unique(meshInfo.cohesivos.relatedEB(logical(meshInfo.cohesivos.deadFlagTimes(:,:,iTime)))),:),[],1),1),meshInfo.nodes(reshape(meshInfo.elementsBarra.ALL(unique(meshInfo.cohesivos.relatedEB(logical(meshInfo.cohesivos.deadFlagTimes(:,:,iTime)))),:),[],1),2),meshInfo.nodes(reshape(meshInfo.elementsBarra.ALL(unique(meshInfo.cohesivos.relatedEB(logical(meshInfo.cohesivos.deadFlagTimes(:,:,iTime)))),:),[],1),3),'r')
        scatter3(meshInfo.nodes(nodosMuertos,1),meshInfo.nodes(nodosMuertos,2),meshInfo.nodes(nodosMuertos,3),'r')        
        title(['iTime: ',num2str(iTime)])

        subplot(1,2,2)
        presion = dTimes(paramDiscEle.nDofTot_U+1:paramDiscEle.nDofTot_U+paramDiscEle.nDofTot_P,iTime)*temporalProperties.preCond;
        plotColo(meshInfo.nodes,meshInfo.elementsFluidos.elements,presion)
        axis square
        view(-45,20)
        daspect([1 1 1])
        title(['iTime: ',num2str(iTime)])
        drawnow
% subplot(1,3,1)
%         bandplot(meshInfo.cohesivos.elements,meshInfo.nodes,meshInfo.cohesivos.dNTimes(:,:,iTime))
%         axis square
%         view(-45,20)
%         daspect([1 1 1])
%         hold on
%         scatter3(meshInfo.nodes(nodosMuertos,1),meshInfo.nodes(nodosMuertos,2),meshInfo.nodes(nodosMuertos,3),'r')
%         title(['iTime: ',num2str(iTime)])
% 
% 
%         subplot(1,3,2)
%         bandplot(meshInfo.cohesivos.elements,meshInfo.nodes,meshInfo.cohesivos.dS1Times(:,:,iTime))
%         axis square
%         view(-45,20)
%         daspect([1 1 1])
%         hold on
%         scatter3(meshInfo.nodes(nodosMuertos,1),meshInfo.nodes(nodosMuertos,2),meshInfo.nodes(nodosMuertos,3),'r')
%         title(['iTime: ',num2str(iTime)])
%   
% 
%         subplot(1,3,3)
%         bandplot(meshInfo.cohesivos.elements,meshInfo.nodes,meshInfo.cohesivos.dS2Times(:,:,iTime))
%         axis square
%         view(-45,20)
%         daspect([1 1 1])
%         hold on
%         scatter3(meshInfo.nodes(nodosMuertos,1),meshInfo.nodes(nodosMuertos,2),meshInfo.nodes(nodosMuertos,3),'r')
%         title(['iTime: ',num2str(iTime)])
%         drawnow
%         
%         figure
%         nodosDesplazados = meshInfo.nodes + reshape(dTimes(1:paramDiscEle.nDofTot_U,1),3,[])'*1000;
%         plotMeshColo3D(meshInfo.nodes,meshInfo.elements,meshInfo.cohesivos.elements,'off','on','w',[.95 .95 .95],[.95 .95 .95],0.2)
%         plotMeshColo3D(nodosDesplazados,meshInfo.elements,meshInfo.cohesivos.elements,'off','on','w','r','k',0.2)
        
        
        
        
    end
    % Indica el final de la operacion.
    if algorithmProperties.elapsedTime >= temporalProperties.tiempoTotalCorrida %deberia ser un ==, el >= esta por las dudas
        display(algorithmProperties.elapsedTime)
        disp('FIN DE LA CORRIDA, SE LLEGO AL TIEMPO TOTAL')
        temporalProperties.nTimes = iTime;
    end
    
    %% Guardados parciales.
    if ~isempty(tSaveParcial) && iSaveParcial <= numel(tSaveParcial) && strcmpi(guardarCorrida,'Y')
        if algorithmProperties.elapsedTime >= tSaveParcial(iSaveParcial)
            iSaveParcial = iSaveParcial + 1;
            temporalProperties.tFinalISIPLocal = iTime;
            save(['resultadosPARCIALESCorrida_',nombreCorrida,'_numero_',num2str(iSaveParcial),'.mat']);    % Se guarda la informacion obtenida.
        end
    end
    if algorithmProperties.elapsedTime >= temporalProperties.tFinalFrac(iFractura) && flagSaveFrac(iFractura) == 1
        if strcmpi(guardarCorrida,'Y')
            flagSaveFrac(iFractura) = 0;
            save(['resultadosFinFractura_',num2str(iFractura),'_',nombreCorrida]); % Se guardan los resultados parciales al final de proceso de fractura.
        end
    elseif algorithmProperties.elapsedTime >= temporalProperties.tFinalISIP(iFractura) && flagSaveISIP(iFractura) == 1 &&  strcmpi(guardarCorrida,'Y')
        flagSaveISIP(iFractura) = 0;
        save(['resultadosFinISIP_',num2str(iFractura),'_',nombreCorrida]); % Se guardan los resultados parciales al final del ISIP.
    elseif algorithmProperties.elapsedTime >= temporalProperties.tFinalProduccion(iFractura) && flagSaveProduccion(iFractura) == 1 &&  strcmpi(guardarCorrida,'Y')
        flagSaveProduccion(iFractura) = 0;
        save(['resultadosFinProduccion_',num2str(iFractura),'_',nombreCorrida]); % Se guardan los resultados parciales al final del ISIP.
    end
    
    %Si llego a tFinalProduccion(iFractura), significa que termino con la frac+isip+prod nro i. Pasa a la fractura siguiente.
    if algorithmProperties.elapsedTime >= temporalProperties.tFinalProduccion(iFractura) %en realidad es un ==, pongo >= por las dudas.
        iFractura=iFractura+1;
        iDeadFlag=1;
    end
end
%%
%indices temporales utiles
indiceTiempo = temporalProperties.drainTimes+1:temporalProperties.nTimes;
tiempo = cumsum(temporalProperties.deltaTs(indiceTiempo));
for i=1:bombaProperties.nBombas
    iTimeInicioFrac(i)=temporalProperties.drainTimes+find(tiempo>=temporalProperties.tInicioFrac(i),1);
    iTimeInicioISIP(i)=temporalProperties.drainTimes+find(tiempo>=temporalProperties.tInicioISIP(i),1);
    iTimeInicioProd(i)=temporalProperties.drainTimes+find(tiempo>=temporalProperties.tInicioProduccion(i),1);
end
%-------------------------------------------------------------------------%
%%                       GUARDADO DE INFORMACION                         %%
%-------------------------------------------------------------------------%
if strcmpi(guardarCorrida,'Y')
    clear han1 han2
    mkdir('Resultados de corridas',nombreCorrida); % Crea una subcarpeta en Resultado de corridas donde se guardara la informacion obtenida.
    save(['resultadosCorrida_',nombreCorrida,'.mat']);    % Se guarda la informacion obtenida.
    guardarPropiedades(archivoLectura,nombreCorrida)
    guardarTXT
    fclose('all');
    
    movefile(['resultadosCorrida_',nombreCorrida,'.mat'],[direccionGuardado,nombreCorrida]); % Se mueve la informacion obtenida a la carpeta creada para guardarla.
    movefile(['propiedades_',nombreCorrida,'.txt'],[direccionGuardado,nombreCorrida]);
    movefile(['tiempo_',nombreCorrida,'.txt'],[direccionGuardado,nombreCorrida]);
    movefile(['presion_',nombreCorrida,'.txt'],[direccionGuardado,nombreCorrida]);
    if isfield(meshInfo,'nodosSample')
        movefile(['presion_nodos_sample_',nombreCorrida,'.txt'],[direccionGuardado,nombreCorrida]);
    end
    movefile(['Q_',nombreCorrida,'.txt'],[direccionGuardado,nombreCorrida]);
    
    for i=1:bombaProperties.nBombas
        if exist(['resultadosFinFractura_',num2str(i),'_',nombreCorrida,'.mat'],'file') == 2
           movefile(['resultadosFinFractura_',num2str(i),'_',nombreCorrida,'.mat'],[direccionGuardado,nombreCorrida]);
        end
        if exist(['resultadosFinISIP_',num2str(i),'_',nombreCorrida,'.mat'],'file') == 2
           movefile(['resultadosFinISIP_',num2str(i),'_',nombreCorrida,'.mat'],[direccionGuardado,nombreCorrida]);
        end
        if exist(['resultadosFinProduccion_',num2str(i),'_',nombreCorrida,'.mat'],'file') == 2
           movefile(['resultadosFinProduccion_',num2str(i),'_',nombreCorrida,'.mat'],[direccionGuardado,nombreCorrida]);
        end
    end

    if ~isempty(tSaveParcial)
        for i = 1:numel(tSaveParcial)
            movefile(['resultadosPARCIALESCorrida_',nombreCorrida,'_numero_',num2str(i),'.mat'],[direccionGuardado,nombreCorrida]);
        end
    end
end

tCorridaEnSeg=toc(tStart);
disp(['Tiempo computacional total de corrida: ' num2str(tCorridaEnSeg) ' seg']);
disp(['(son ' num2str(tCorridaEnSeg/60) ' min, o ' num2str(tCorridaEnSeg/3600) ' hs)']);
%-------------------------------------------------------------------------%
%%                            POST - PROCESO                             %%
%-------------------------------------------------------------------------%
% Presion nodo bomba vs tiempo:
plotPresionCaudal

% Area de fractura vs tiempo:
% setear "tiempoArea" para ver la fractura en el t necesario.
plotAreaVolTripleT  

% Perfil de fractura
plotPerfilDeFractura

% Tensiones para un iTime en particular:
% setear "tiempoTensiones" para ver las tensiones en el t necesario.
tiempoTensiones = tiempo(end);
plotTensionesSinPromediar

%% Alarma de finalizacion.
%- Alarma sonora de fin de corrida.
% load gong
% sound(y,Fs)  


