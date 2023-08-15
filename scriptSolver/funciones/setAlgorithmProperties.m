function [algorithmProperties] = setAlgorithmProperties(key,varargin)
% setAlgorithmroperties es una funcion que sirve para setear las
% propiedades del algoritmo de convergencia para la resolucion del problema.
% Se puede elegir establecer dichas propiedades (a mano), continuar 
% trabajando con las utlimas que se utilizaron, utilizar las propiedades de
% la corrida de verificacion o cargar las propeidades de un archivo ya 
% escrito. Para cambiar las propiedades fisicas del problema ingresar como 
% key.

% key: "change" "default" "test" "load"

% Las propiedades se guardan en la estrcutura "algorithmProperties" con los
% siguientes campos:
% algorithmProperties: 
%             toleranciaU: tolerancia de convergencia en desplazamientos.
%             toleranciaP: tolerancia de convergencia en presions.
%     toleranciaCohesivos: tolerancia de convergencia en separacion de 
%                          cohesivos.
%                nIterDiv: numero de iteraciones para considerar
%                divergencia.
%               nIterFast: numero de iteraciones para considerar
%               convergencia rapida y duplicar el deltaT del proximo iTime.
%               nIterSlow: numero de iteraciones para considerar
%               convergencia lenta y dividir el deltaT del proximo iTime.
%               precondCT: pre condicionador para mejorar el calculo
%               numerico.
%                criterio: define el tipo de analisis de error utilizado.
%             elapsedTime: tiempo que transcurre del problema real a medida
%             que avanza el programa.
%                 flagDiv: pre alocacion de variable. Sirve para reconocer
%                cuando debe actuar el algoritmo de timestep.
%%
if strcmpi(key,'default')
    load('algorithmProperties')
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
    
    algorithmProperties.toleranciaU         = varName('toleranciaU', propiedades);
    algorithmProperties.toleranciaP         = varName('toleranciaP', propiedades);
    algorithmProperties.toleranciaCohesivos = varName('toleranciaCohesivos', propiedades);
    algorithmProperties.nIterDiv    = varName('nIterDiv', propiedades);
    algorithmProperties.nIterFast   = varName('nIterFast', propiedades);
    algorithmProperties.nIterSlow   = varName('nIterSlow', propiedades);
    algorithmProperties.precondCT   = varName('precondCT', propiedades);
    algorithmProperties.criterio    = 'VARIABLES';
    algorithmProperties.elapsedTime = 0;
    algorithmProperties.flagDiv     = 0; 
    save('algorithmProperties','algorithmProperties')
end

fprintf('---------------------------------------------------------\n');
fprintf('Las <strong>propiedades para el algoritmo de convergencia</strong> a utilizar son: \n');
disp(algorithmProperties);
end

