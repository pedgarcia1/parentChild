function [meshInfo,cohesivosProperties] = setCohesivosProperties( meshInfo,physicalProperties,temporalProperties,bombaProperties,key,key2,varargin )
% setCohesivosProperties es una funcion que sirve para setear las
% propiedades de los elementos cohesivos.
% Se puede elegir establecer dichas propiedades (a mano), continuar 
% trabajando con las utlimas que se utilizaron, utilizar las propiedades de
% la corrida de verificacion o cargar las propeidades de un archivo ya 
% escrito. Para cambiar las propiedades fisicas del problema ingresar como 
% key.

% key: "change" "default" "test" "load"

% Para plotear la curva de esfuerzo vs deformacion de los elementos
% cohesivos ingresar como key2.

% key2: "on" "off"

% Las propiedades se guardan en la estrcutura "cohesivosProperties" con los
% siguientes campos:
% cohesivosProperties: 
%               npiCohesivos: cantidad de puntos de integracion. 
%      tensionRoturaCohesivo: valor de tension de rotura del cohesivo 
%                             normal.
%                        K1c: 
%     tensionRoturaCohesivoS: valor de tension de rotura del cohesivo 
%                             transversal.
%                  fractureG: 
%                        Kn0: 
%                      Ks0_1: 
%                      Ks0_2: 
%                      dS0_1: 
%                      dS0_2: 
%                        dN0: 
%                      TS0_1: 
%                      TS0_2: 
%                        TN0: 
%                        dN1: 
%                      dS1_1: 
%                      dS1_2: 
%%
if strcmpi(key2,'default')
    load('cohesivosProperties')
elseif strcmpi(key2,'change')
else
    if strcmpi(key2,'load')
        if nargin<7
            fprintf('---------------------------------------------------------\n');
            archivo = input('Ingrese nombre del archivo a correr: ');
            clc
        else
            archivo = varargin{1};
        end
    elseif strcmpi(key2,'test')
        archivo = 'corridaVerificacion.txt';
    end
    propiedades = getProperties(archivo);
   
    in2m     = 254/1e4;
    in2mm    = 254/10;
    Mpsi2MPa = 1e6/145;
    MPa2psi  = 145;
    psi2MPa  = 1/145;
    
    %% Shale Properties
    cohesivosProperties.npiCohesivos          = varName('npiCohesivos', propiedades);
    cohesivosProperties.angDilatancy          = varName('anguloDilatancia', propiedades);
    cohesivosProperties.tensionRoturaCohesivo = varName('tensionRoturaCohesivo', propiedades);
    cohesivosProperties.K1c                   = varName('K1c', propiedades);
    
    %----------------------------------------------------------------------
    cohesivosProperties.tensionRoturaCohesivoS = cohesivosProperties.tensionRoturaCohesivo;       % psi
    cohesivosProperties.fractureGM1            = (cohesivosProperties.K1c^2)/((physicalProperties.constitutive.Eh(1) * MPa2psi)/(1-physicalProperties.constitutive.NUh(1)^2));  % psi in
    cohesivosProperties.K2c                    = cohesivosProperties.K1c/3; 
    cohesivosProperties.fractureGM2            = (cohesivosProperties.K2c^2)/((physicalProperties.constitutive.Eh(1) * MPa2psi)/(1-physicalProperties.constitutive.NUh(1)^2));
    
    cohesivosProperties.Kn0   = physicalProperties.constitutive.Eh(1)/1.5;
    cohesivosProperties.Ks0_1 = cohesivosProperties.Kn0;
    cohesivosProperties.Ks0_2 = cohesivosProperties.Ks0_1;
    cohesivosProperties.dS0_1 = (cohesivosProperties.fractureGM2) / cohesivosProperties.tensionRoturaCohesivoS * in2mm;           % Antiguamente despRot - NORMAL
    cohesivosProperties.dS0_2 = cohesivosProperties.dS0_1;
    cohesivosProperties.dN0   = 2 * cohesivosProperties.fractureGM1 / cohesivosProperties.tensionRoturaCohesivo * in2mm ;           % despRot - TANGENTE
    cohesivosProperties.TS0_1 = cohesivosProperties.tensionRoturaCohesivoS* psi2MPa;
    cohesivosProperties.TS0_2 = cohesivosProperties.TS0_1;
    cohesivosProperties.TN0   = cohesivosProperties.tensionRoturaCohesivo* psi2MPa;
    cohesivosProperties.dN1   = cohesivosProperties.TN0 / (cohesivosProperties.Kn0);       % desp1   - NORMAL
    cohesivosProperties.dS1_1 = cohesivosProperties.TS0_1 / (cohesivosProperties.Ks0_1);
    cohesivosProperties.dS1_2 = cohesivosProperties.dS1_1;
    
    while cohesivosProperties.dN0*10/100 < cohesivosProperties.dN1 % Uno es al menos el 10% del otro. 
        warning('Se aumenta la rigidez del cohesivo SHALE normal para respestar la forma')
        cohesivosProperties.Kn0 = cohesivosProperties.Kn0*1.1; % Aumenta el 10% cada iteracion la pendiente inicial hasta verificar la condicion.
        cohesivosProperties.dN1   = cohesivosProperties.TN0 / (cohesivosProperties.Kn0);           
    end
    while cohesivosProperties.dS0_1*10/100 < cohesivosProperties.dS1_1 % En corte comparo solo el modo 1 porque el 2 es igual.   
        warning('Se aumenta la rigidez del cohesivo SHALE a corte para respestar la forma')
        cohesivosProperties.Ks0_1 = cohesivosProperties.Ks0_1*1.1;
        cohesivosProperties.Ks0_2 = cohesivosProperties.Ks0_1;
        cohesivosProperties.dS1_1 = cohesivosProperties.TS0_1 / (cohesivosProperties.Ks0_1);
        cohesivosProperties.dS1_2 = cohesivosProperties.dS1_1;
    end
    
    %% Limestone Properties
    cohesivosProperties.tensionRoturaCohesivoL = varName('tensionRoturaCohesivoL', propiedades);
    cohesivosProperties.K1cL                   = varName('K1cL', propiedades);
    
    %----------------------------------------------------------------------
    if ~isempty(cohesivosProperties.tensionRoturaCohesivoL)
        cohesivosProperties.tensionRoturaCohesivoSL = cohesivosProperties.tensionRoturaCohesivoL;       % psi
        cohesivosProperties.fractureGM1L            = (cohesivosProperties.K1cL^2)/((physicalProperties.constitutive.EhL(1) * MPa2psi)/(1-physicalProperties.constitutive.NUhL(1)^2));  % psi in
        cohesivosProperties.K2cL                    = cohesivosProperties.K1cL/3;
        cohesivosProperties.fractureGM2L            = (cohesivosProperties.K2cL^2)/((physicalProperties.constitutive.EhL(1) * MPa2psi)/(1-physicalProperties.constitutive.NUhL(1)^2));  % psi in
        
        cohesivosProperties.Kn0L   = physicalProperties.constitutive.EhL(1)/1.5;
        cohesivosProperties.Ks0_1L = cohesivosProperties.Kn0L;
        cohesivosProperties.Ks0_2L = cohesivosProperties.Ks0_1L;
        cohesivosProperties.dS0_1L = (cohesivosProperties.fractureGM2L) / cohesivosProperties.tensionRoturaCohesivoSL * in2mm;           % Antiguamente despRot - NORMAL
        cohesivosProperties.dS0_2L = cohesivosProperties.dS0_1L;
        cohesivosProperties.dN0L   = 2 * cohesivosProperties.fractureGM1L / cohesivosProperties.tensionRoturaCohesivoL * in2mm;           % despRot - TANGENTE
        cohesivosProperties.TS0_1L = cohesivosProperties.tensionRoturaCohesivoSL * psi2MPa;
        cohesivosProperties.TS0_2L = cohesivosProperties.TS0_1L;
        cohesivosProperties.TN0L   = cohesivosProperties.tensionRoturaCohesivoL * psi2MPa;
        cohesivosProperties.dN1L   = cohesivosProperties.TN0L / (cohesivosProperties.Kn0L);       % desp1   - NORMAL
        cohesivosProperties.dS1_1L = cohesivosProperties.TS0_1L / (cohesivosProperties.Ks0_1L);
        cohesivosProperties.dS1_2L = cohesivosProperties.dS1_1L;
        
        while cohesivosProperties.dN0L*10/100 < cohesivosProperties.dN1L % Uno es al menos el 10% del otro. 
            warning('Se aumenta la rigidez del cohesivo LIMESTONE normal para respetar la forma')
            cohesivosProperties.Kn0L = cohesivosProperties.Kn0L*1.1; % Aumenta el 10% cada iteracion la pendiente inicial hasta verificar la condicion.
            cohesivosProperties.dN1L   = cohesivosProperties.TN0L / (cohesivosProperties.Kn0L);      
        end
        while cohesivosProperties.dS0_1L*10/100 < cohesivosProperties.dS1_1L
            warning('Se aumenta la rigidez del cohesivo LIMESTONE a corte para respetar la forma')
            cohesivosProperties.Ks0_1L = cohesivosProperties.Ks0_1L*1.1;
            cohesivosProperties.Ks0_2L = cohesivosProperties.Ks0_1L;
            cohesivosProperties.dS1_1L = cohesivosProperties.TS0_1L / (cohesivosProperties.Ks0_1L);
            cohesivosProperties.dS1_2L = cohesivosProperties.dS1_1L;
        end 
    end
    %% Interface Properties
    cohesivosProperties.tensionRoturaCohesivoInter = varName('tensionRoturaCohesivoInter', propiedades);
    cohesivosProperties.K1cInter                   = varName('K1cI', propiedades);
    cohesivosProperties.EvInter                    = varName('EvI', propiedades)*Mpsi2MPa;
    cohesivosProperties.NUvInter                   = varName('NUI', propiedades);
   
    if ~isempty(cohesivosProperties.tensionRoturaCohesivoL)
        %----------------------------------------------------------------------        
        cohesivosProperties.tensionRoturaCohesivoSInter  = cohesivosProperties.tensionRoturaCohesivoInter;       % psi
        cohesivosProperties.fractureGM1Inter             = (cohesivosProperties.K1cInter^2)/((cohesivosProperties.EvInter * MPa2psi)/(1-cohesivosProperties.NUvInter^2));  % psi in
        cohesivosProperties.K2cInter                     = cohesivosProperties.K1cInter/3;
        cohesivosProperties.fractureGM2Inter             = (cohesivosProperties.K2cInter^2)/((cohesivosProperties.EvInter * MPa2psi)/(1-cohesivosProperties.NUvInter^2));  % psi in
        
        cohesivosProperties.Kn0Inter   = cohesivosProperties.EvInter/1.5;
        cohesivosProperties.Ks0_1Inter = cohesivosProperties.Kn0Inter;
        cohesivosProperties.Ks0_2Inter = cohesivosProperties.Ks0_1Inter;
        cohesivosProperties.dS0_1Inter = (cohesivosProperties.fractureGM2Inter) / cohesivosProperties.tensionRoturaCohesivoSInter * in2mm;           % Antiguamente despRot - NORMAL
        cohesivosProperties.dS0_2Inter = cohesivosProperties.dS0_1Inter;
        cohesivosProperties.dN0Inter   = 2 * cohesivosProperties.fractureGM1Inter / cohesivosProperties.tensionRoturaCohesivoInter * in2mm ;           % despRot - TANGENTE
        cohesivosProperties.TS0_1Inter = cohesivosProperties.tensionRoturaCohesivoSInter * psi2MPa;
        cohesivosProperties.TS0_2Inter = cohesivosProperties.TS0_1Inter;
        cohesivosProperties.TN0Inter   = cohesivosProperties.tensionRoturaCohesivoInter * psi2MPa;
        cohesivosProperties.dN1Inter   = cohesivosProperties.TN0Inter / (cohesivosProperties.Kn0Inter);       % desp1   - NORMAL
        cohesivosProperties.dS1_1Inter = cohesivosProperties.TS0_1Inter / (cohesivosProperties.Ks0_1Inter);
        cohesivosProperties.dS1_2Inter = cohesivosProperties.dS1_1Inter;
        
        while cohesivosProperties.dN0Inter*10/100 < cohesivosProperties.dN1Inter % Uno es al menos el 10% del otro. 
            warning('Se aumenta la rigidez del cohesivo INTERFACE normal para respetar la forma')
            cohesivosProperties.Kn0Inter = cohesivosProperties.Kn0Inter*1.1; % Aumenta el 10% cada iteracion la pendiente inicial hasta verificar la condicion.
            cohesivosProperties.dN1Inter = cohesivosProperties.TN0Inter / (cohesivosProperties.Kn0Inter);     
        end
        while cohesivosProperties.dS0_1Inter*10/100 < cohesivosProperties.dS1_1Inter
            warning('Se aumenta la rigidez del cohesivo INTERFACE a corte para respetar la forma')
            cohesivosProperties.Ks0_1Inter = cohesivosProperties.Ks0_1Inter*1.1;
            cohesivosProperties.Ks0_2Inter = cohesivosProperties.Ks0_1Inter;
            cohesivosProperties.dS1_1Inter = cohesivosProperties.TS0_1Inter / (cohesivosProperties.Ks0_1Inter);
            cohesivosProperties.dS1_2Inter = cohesivosProperties.dS1_1Inter;
        end
    end
    
    save('cohesivosProperties','cohesivosProperties')
end

%% Formacion de variables de interes.
cohesivos  = meshInfo.cohesivos;
nCohesivos = meshInfo.nCohesivos;
npiCohesivos = cohesivosProperties.npiCohesivos;
% nTimes = temporalProperties.nTimes;

cohesivos.damageFlagN   = zeros(nCohesivos,npiCohesivos);      
cohesivos.damageFlagS1  = zeros(nCohesivos,npiCohesivos);
cohesivos.damageFlagS2  = zeros(nCohesivos,npiCohesivos);

cohesivos.deadFlag      = false(nCohesivos,npiCohesivos);
cohesivos.highEFlag     = zeros(nCohesivos,npiCohesivos);
cohesivos.positiveFlag  = ones(nCohesivos,npiCohesivos);

cohesivos.discrepFlag   = zeros(nCohesivos,npiCohesivos,1);
cohesivos.firstDmgFlagN = zeros(nCohesivos,npiCohesivos);
cohesivos.firstDmgFlagS1= zeros(nCohesivos,npiCohesivos);
cohesivos.firstDmgFlagS2= zeros(nCohesivos,npiCohesivos);

cohesivos.damage        = zeros(nCohesivos,npiCohesivos);

cohesivos.Ks1Times      = zeros(nCohesivos,npiCohesivos,1);
cohesivos.Ks2Times      = zeros(nCohesivos,npiCohesivos,1);
cohesivos.KnTimes       = zeros(nCohesivos,npiCohesivos,1);

cohesivos.Ts1Times      = zeros(nCohesivos,npiCohesivos,1);
cohesivos.Ts2Times      = zeros(nCohesivos,npiCohesivos,1);
cohesivos.TnTimes       = zeros(nCohesivos,npiCohesivos,1);

cohesivos.dS1Times      = zeros(nCohesivos,npiCohesivos,1);
cohesivos.dS2Times      = zeros(nCohesivos,npiCohesivos,1);
cohesivos.dNTimes       = zeros(nCohesivos,npiCohesivos,1);  

cohesivos.lastPositiveKn = cohesivosProperties.Kn0*ones(nCohesivos,npiCohesivos);

cohesivos.dN1           = cohesivosProperties.dN1*ones(nCohesivos,npiCohesivos);
cohesivos.dN10          = cohesivosProperties.dN1*ones(nCohesivos,npiCohesivos);
cohesivos.Kn0           = cohesivosProperties.Kn0*ones(nCohesivos,npiCohesivos);
cohesivos.KnPropante    = 1e2*cohesivosProperties.Kn0*ones(nCohesivos,npiCohesivos);
cohesivos.Ks0_1         = cohesivosProperties.Ks0_1*ones(nCohesivos,npiCohesivos);
cohesivos.Ks0_2         = cohesivosProperties.Ks0_2*ones(nCohesivos,npiCohesivos);

cohesivos.dS1_1         = cohesivosProperties.dS1_1*ones(nCohesivos,npiCohesivos);
cohesivos.dS1_2         = cohesivosProperties.dS1_2*ones(nCohesivos,npiCohesivos);

cohesivos.dS10_1        = cohesivosProperties.dS1_1*ones(nCohesivos,npiCohesivos);
cohesivos.dS10_2        = cohesivosProperties.dS1_2*ones(nCohesivos,npiCohesivos);

cohesivos.dN0           = cohesivosProperties.dN0*ones(nCohesivos,npiCohesivos);
cohesivos.dS0_1         = cohesivosProperties.dS0_1*ones(nCohesivos,npiCohesivos);
cohesivos.dS0_2         = cohesivosProperties.dS0_2*ones(nCohesivos,npiCohesivos);

cohesivos.TN0           = cohesivosProperties.TN0*ones(nCohesivos,npiCohesivos);
cohesivos.TS0_1         = cohesivosProperties.TS0_1*ones(nCohesivos,npiCohesivos);
cohesivos.TS0_2         = cohesivosProperties.TS0_2*ones(nCohesivos,npiCohesivos);

%% 
% Esta 2 lineas deberia irse
C = constitutiveMatrix(physicalProperties.constitutive.Ev(1),physicalProperties.constitutive.Eh(1),physicalProperties.constitutive.NUv(1),physicalProperties.constitutive.NUh(1));
Biot  = (physicalProperties.poroelasticas.m - C*physicalProperties.poroelasticas.m/3/physicalProperties.poroelasticas.Ks );
cohesivos.biot          = Biot(1)*ones(nCohesivos,npiCohesivos);

%% Pre-alocacion de variables.
cohesivos.dNCalculado   = zeros(nCohesivos,npiCohesivos);
cohesivos.dSCalculado_1 = zeros(nCohesivos,npiCohesivos);
cohesivos.dSCalculado_2 = zeros(nCohesivos,npiCohesivos);

cohesivos.KnIter        = zeros(nCohesivos,npiCohesivos);
cohesivos.Ks1Iter       = zeros(nCohesivos,npiCohesivos);
cohesivos.Ks2Iter       = zeros(nCohesivos,npiCohesivos);

cohesivos.KnPrevTime    = zeros(nCohesivos,npiCohesivos);
cohesivos.Ks1PrevTime   = zeros(nCohesivos,npiCohesivos);
cohesivos.Ks2PrevTime   = zeros(nCohesivos,npiCohesivos);


cohesivos.dNMat          = zeros(nCohesivos,npiCohesivos);
cohesivos.dS1Mat         = zeros(nCohesivos,npiCohesivos);
cohesivos.dS2Mat         = zeros(nCohesivos,npiCohesivos);

cohesivos.LIndex = [];

for iCohesivo = 1:nCohesivos
    
    nodesEle8   = meshInfo.nodes(cohesivos.related8Nodes(iCohesivo,:),:);
    nodesEleCohesivo    = meshInfo.nodes(cohesivos.elements(iCohesivo,:),:);
    zCoord = nodesEleCohesivo(:,3);
    %     max(zCoord)
    % Orientamos el cohesivo
    
    v12 = nodesEle8(2,:)-nodesEle8(1,:);
    v14 = nodesEle8(4,:)-nodesEle8(1,:);
    vnorm = cross(v12,v14);
    
    norma12 = sqrt(v12(1)^2 + v12(2)^2 + v12(3)^2);
    norma14 = sqrt(v14(1)^2 + v14(2)^2 + v14(3)^2);
    
    v12 = v12/norma12;
    v14 = v14/norma14;
    vnorm = vnorm/norm(vnorm);  
    
    if all(vnorm == [0 0 1]) % A los cohesivos horizontales les setea las propiedades correspondientes a la Interfase.
        % Interfase
        Kn0i   = cohesivosProperties.Kn0Inter;
        Ks0_1i = cohesivosProperties.Ks0_1Inter;
        Ks0_2i = cohesivosProperties.Ks0_2Inter;
        dN1i   = cohesivosProperties.dN1Inter;
        dS1_1i = cohesivosProperties.dS1_1Inter;
        dS1_2i = cohesivosProperties.dS1_2Inter;
        dN0i   = cohesivosProperties.dN0Inter;
        dS0_1i = cohesivosProperties.dS0_1Inter;
        dS0_2i = cohesivosProperties.dS0_2Inter;
        
        TN0i   = cohesivosProperties.TN0Inter;
        TS0_1i = cohesivosProperties.TS0_1Inter;
        TS0_2i = cohesivosProperties.TS0_2Inter;
        
        dN10i    = cohesivosProperties.dN1Inter;
        dS10_1i  = cohesivosProperties.dS1_1Inter;
        dS10_2i  = cohesivosProperties.dS1_2Inter;
        
    elseif any(abs(min(zCoord)- physicalProperties.constitutive.depthL) <= 1)  % A los cohesivos verticales les setea las propiedades correspondientes al Limestone.
        % Limestone
        cohesivos.LIndex = [cohesivos.LIndex;iCohesivo];
        Kn0i   = cohesivosProperties.Kn0L;
        Ks0_1i = cohesivosProperties.Ks0_1L;
        Ks0_2i = cohesivosProperties.Ks0_2L;
        dN1i   = cohesivosProperties.dN1L;
        dS1_1i = cohesivosProperties.dS1_1L;
        dS1_2i = cohesivosProperties.dS1_2L;
        dN0i   = cohesivosProperties.dN0L;
        dS0_1i = cohesivosProperties.dS0_1L;
        dS0_2i = cohesivosProperties.dS0_2L;
        
        TN0i   = cohesivosProperties.TN0L;
        TS0_1i = cohesivosProperties.TS0_1L;
        TS0_2i = cohesivosProperties.TS0_2L;
        
        dN10i          = cohesivosProperties.dN1L;
        dS10_1i        = cohesivosProperties.dS1_1L;
        dS10_2i        = cohesivosProperties.dS1_2L;
    else
        % Shale
        Kn0i   = cohesivosProperties.Kn0;
        Ks0_1i = cohesivosProperties.Ks0_1;
        Ks0_2i = cohesivosProperties.Ks0_2;
        dN1i   = cohesivosProperties.dN1;
        dS1_1i = cohesivosProperties.dS1_1;
        dS1_2i = cohesivosProperties.dS1_2;
        dN0i   = cohesivosProperties.dN0;
        dS0_1i = cohesivosProperties.dS0_1;
        dS0_2i = cohesivosProperties.dS0_2;
        
        TN0i   = cohesivosProperties.TN0;
        TS0_1i = cohesivosProperties.TS0_1;
        TS0_2i = cohesivosProperties.TS0_2;
        
        dN10i          = cohesivosProperties.dN1;
        dS10_1i        = cohesivosProperties.dS1_1;
        dS10_2i        = cohesivosProperties.dS1_2;
    end
    
    cohesivos.Kn0(iCohesivo,:)    = Kn0i;
    
    cohesivos.Ks0_1(iCohesivo,:)  = Ks0_1i;
    cohesivos.Ks0_2(iCohesivo,:)  = Ks0_2i;
    
    cohesivos.dN1(iCohesivo,:)    = dN1i;
    cohesivos.dS1_1(iCohesivo,:)  = dS1_1i;
    cohesivos.dS1_2(iCohesivo,:)  = dS1_2i;
    
    cohesivos.dN0(iCohesivo,:)    = dN0i;
    cohesivos.dS0_1(iCohesivo,:)  = dS0_1i;
    cohesivos.dS0_2(iCohesivo,:)  = dS0_2i;
    
    cohesivos.TN0(iCohesivo,:)    = TN0i;
    cohesivos.TS0_1(iCohesivo,:)  = TS0_1i;
    cohesivos.TS0_2(iCohesivo,:)  = TS0_2i;
    
    cohesivos.dN10(iCohesivo,:)   = dN10i;
    cohesivos.dS10_1(iCohesivo,:) = dS10_1i;
    cohesivos.dS10_2(iCohesivo,:) = dS10_2i;
end

cohesivos.produccionFlag = false;


cohesivos.deadCohesivos = bombaProperties.nodoBomba;

meshInfo.cohesivos = cohesivos;


%% Figuras.

if strcmpi(key,'on')
    figure
    plot([0 cohesivosProperties.dN1 cohesivosProperties.dN0],[0 cohesivosProperties.TN0 0]);
    xlabel('Gap o Displacement Jump [mm]')
    ylabel('Tension [MPa]')
    title('Ley Cohesiva TRACCION')
    grid on
    
    figure
    plot([-cohesivosProperties.dS0_1 -cohesivosProperties.dS1_1 0 cohesivosProperties.dS1_1 cohesivosProperties.dS0_1],[0,-cohesivosProperties.TS0_1,0,cohesivosProperties.TS0_1,0]);
    hold on
    plot([-cohesivosProperties.dS0_1 -cohesivosProperties.dS1_1 0 cohesivosProperties.dS1_1 cohesivosProperties.dS0_1],[0,-cohesivosProperties.TS0_1,0,cohesivosProperties.TS0_1,0]);
    xlabel('Gap o Displacement Jump [mm]')
    ylabel('Tension [MPa]')
    title('Ley Cohesiva CORTE')
    grid on
end
fprintf('---------------------------------------------------------\n');
fprintf('Las <strong>propiedades de los elementos cohesivos</strong> a utilizar son: \n');
fprintf('(Unidades en MPa, mm y s) \n\n');
disp(cohesivosProperties);



% Propiedades que hay que reescribir en funcion a la prof.
% cohesivosProperties.fractureG  = (cohesivosProperties.K1c^2)/((physicalPropierties.constitutive.Eh * 1e6 / 6894.76)/(1-physicalPropierties.constitutive.NUh^2))*0.5;  % psi in
% cohesivosProperties.Kn0     = physicalPropierties.constitutive.Eh/2;
% cohesivos.biot          = Biot(1)*ones(nCohesivos,npiCohesivos);



end

