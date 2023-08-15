function [ propanteProperties ] = setPropanteProperties(key,physicalProperties,meshInfo,varargin)
% setPropanteProperties es una funcion que sirve para setear las
% propiedades FISICAS del propante.
% Se puede elegir establecer dichas propiedades (a mano), continuar 
% trabajando con las utlimas que se utilizaron, utilizar las propiedades de
% la corrida de verificacion o cargar las propeidades de un archivo ya 
% escrito. Para cambiar las propiedades como key.

% key: "change" "default" "test" "load"
%%
if strcmpi(key,'default')
    load('propanteProperties')
elseif strcmpi(key,'change')
else
    if strcmpi(key,'load')
        if nargin<2
            fprintf('---------------------------------------------------------\n');
            archivo = input('Ingrese nombre del archivo a correr: ');
            clc
        else
            archivo = varargin{1};
        end
    elseif strcmpi(key,'test')
        archivo = 'corridaVerificacion.txt';
    end
    Mpsi2MPa = 1e6/145;
    mDarcy2M2 = 9.87e-16;
    mm2m      = 1000;
    propiedades                    = getProperties(archivo);
    
    propanteProperties.Key         = varName('propanteKey', propiedades);
    propanteProperties.EP          = varName('EPropante', propiedades)*Mpsi2MPa;
    propanteProperties.NuP         = varName('NuPropante', propiedades);
    propanteProperties.kappa_int_P = varName('kappaPropante', propiedades)*mDarcy2M2*(mm2m)^2;
    propanteProperties.hP          = varName('hPropantePorcentaje', propiedades)/100;
    
    propanteProperties.MP     = physicalProperties.storativity.M;
    propanteProperties.kappaP = propanteProperties.kappa_int_P/physicalProperties.fluidoPoral.mu_dinamico;
    propanteProperties.KnP    = propanteProperties.EP/(3*(1-2*propanteProperties.NuP));  
    propanteProperties.Ks0_1P = 0; % Sin rigidez transversal.
    propanteProperties.Ks0_2P = 0; % Sin rigidez transversal.
    
    C    = constitutiveMatrix(physicalProperties.constitutive.Ev(1),physicalProperties.constitutive.Eh(1),physicalProperties.constitutive.NUv(1),physicalProperties.constitutive.NUh(1));
    biot = (physicalProperties.poroelasticas.m - C*physicalProperties.poroelasticas.m/3/physicalProperties.poroelasticas.Ks );
    propanteProperties.biotP = biot(1);
    
    propanteProperties.propantesActivosTotales = [];
    propanteProperties.cierreFlag              = zeros(meshInfo.nCohesivos,4); %Pre alocacion de variable que luego sirve para la produccion.
    
    save('propanteProperties','propanteProperties')
end

fprintf('---------------------------------------------------------\n');
fprintf('Las <strong>propiedades del propante</strong> a utilizar son: \n');
disp(propanteProperties);
end
