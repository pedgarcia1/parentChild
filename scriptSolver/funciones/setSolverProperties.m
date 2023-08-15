function [ solverProperties ] = setSolverProperties( key,varargin )
% setSolverProperties es una funcion que sirve para setear las
% propiedades del solver.
% Se puede elegir establecer dichas propiedades (a mano), continuar 
% trabajando con las utlimas que se utilizaron, utilizar las propiedades de
% la corrida de verificacion o cargar las propeidades de un archivo ya 
% escrito. Para cambiar las propiedades fisicas del problema ingresar como 
% key.

% key: "change" "default" "test" "load"

% Las propiedades se guardan en la estrcutura "solverProperties" con los
% siguientes campos:
% solverProperties:
%       ILU_Solver: indica el tipo de solver a utilizar.
%             
%%
if strcmpi(key,'default')
    load('solverProperties')
elseif strcmpi(key,'change')
    fprintf('---------------------------------------------------------\n');
    solverProperties.ILU_Solver = input('  Ingrese ILU_Solver: ');%false;
    save('solverProperties','solverProperties');
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
    solverProperties.ILU_Solver = logical(propiedades{54}'-'0');
    save('solverProperties','solverProperties');
end
fprintf('---------------------------------------------------------\n');
fprintf('Las <strong>propiedades del solver</strong> a utilizar son: \n');
disp(solverProperties);
fprintf('---------------------------------------------------------\n');
end

