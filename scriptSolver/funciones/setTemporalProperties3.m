function [ temporalProperties] = setTemporalProperties3( key,varargin )
% setTemporalProperties es una funcion que sirve para setear las
% propiedades temporales para la resolucion del problema (solver).
% Se puede elegir establecer dichas propiedades (a mano), continuar 
% trabajando con las utlimas que se utilizaron, utilizar las propiedades de
% la corrida de verificacion o cargar las propeidades de un archivo ya 
% escrito. Para cambiar las propiedades fisicas del problema ingresar como 
% key.

% key: "change" "default" "test" "load"

% Las propiedades se guardan en la estrcutura "TemporalProperties" con los
% siguientes campos:
% temporalProperties: 
%             drainTimes: numero de tiempos para el equilibrio establecer
%             el equilibrio inicial.
%              initTimes: numero de tiempos para que actue el algoritmo de
%              time step.
%       deltaTdrainTimes: delta temporal entre cada drainTime
%                 deltaT: delta temporal inicial para los tiempos fuera de
%                 drainTimes + initTimes.
%     tiempoTotalCorrida: tiempo total de todo el proceso.
%            propanteGap: 
%                preCond: pre condicionador para mejorar calculo numerico.
%                   tita: 
%                deltaTs: delta temporal en cada Time.
%         produccionFlag: pre alocacion de variable.
%           condensacion: pre alocacion de variable. Sirve para saber el
%           tipo de resolucion de sistema de ecuaciones.
%           choleskyFlag: pre alocacion de variable.
%                 qrFlag: pre alocacion de variable.
%%
if strcmpi(key,'default')
    load('temporalProperties')
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
    propiedades = getProperties(archivo);
    
    temporalProperties.drainTimes       = varName('drainTimes', propiedades);
    temporalProperties.initTimes        = varName('initTimes', propiedades);
    temporalProperties.deltaTdrainTimes = varName('deltaTdrainTimes', propiedades);
    temporalProperties.deltaT           = varName('deltaT', propiedades);
    temporalProperties.deltaTMax        = varName('deltaTMax', propiedades);
    
    temporalProperties.tiempoISIP          = varName('tiempoISIP', propiedades);
    temporalProperties.deltaTISIP          = varName('deltaTISIP', propiedades);
    temporalProperties.deltaTProduccionMax = varName('deltaTProduccionMax', propiedades);
    
    tbombas = varName('tQ', propiedades); 
    tproduccion = varName('tProduccion', propiedades);
    %acaaaaaa
    finProduccionAnterior = 0;
    for i=1:size(tbombas,1) %para la cantidad de fracturas+isip+prod que tenga, voy llenando sus inicios y finales de isip y produccion
        temporalProperties.tInicioFrac(i)       = finProduccionAnterior;
        temporalProperties.tFinalFrac(i)        = temporalProperties.tInicioFrac(i) + tbombas(i,2);
        temporalProperties.tInicioISIP(i)       = temporalProperties.tFinalFrac(i);
        temporalProperties.tFinalISIP(i)        = temporalProperties.tInicioISIP(i) + temporalProperties.tiempoISIP; %todos los isip duran lo mismo
        temporalProperties.tInicioProduccion(i) = temporalProperties.tFinalISIP(i);
        temporalProperties.tFinalProduccion(i)  = temporalProperties.tInicioProduccion(i) + tproduccion(i,2);
        finProduccionAnterior                   = temporalProperties.tFinalProduccion(i);
    end
    
    temporalProperties.tiempoTotalCorrida = finProduccionAnterior;

    temporalProperties.preCond        = 1;
    temporalProperties.tita           = 1;   % Factor de Crank Nicolson
    temporalProperties.deltaTs        = [ones(1,temporalProperties.drainTimes)*temporalProperties.deltaTdrainTimes, ones(1,temporalProperties.initTimes+1)*temporalProperties.deltaT];
    temporalProperties.produccionFlag = false;
    temporalProperties.condensacion   = false;
    temporalProperties.choleskyFlag   = flag;
    temporalProperties.qrFlag         = false;
    save('temporalProperties','temporalProperties')
end

fprintf('---------------------------------------------------------\n');
fprintf('Las <strong>propiedades temporales</strong> a utilizar son: \n');
disp(temporalProperties);
end

