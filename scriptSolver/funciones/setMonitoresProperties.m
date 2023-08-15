function [ monitoresProperties ] = setMonitoresProperties(meshInfo,key2,varargin )
% setBombaProperties es una funcion que sirve para setear las
% propiedades de la bomba.
% Se puede elegir establecer dichas propiedades (a mano), continuar 
% trabajando con las utlimas que se utilizaron, utilizar las propiedades de
% la corrida de verificacion o cargar las propeidades de un archivo ya 
% escrito. Para cambiar las propiedades fisicas del problema ingresar como 
% key.

% key: "change" "default" "test" "load"

% Las propiedades se guardan en la estrcutura "monitoresProperites" con los
% siguientes campos:
% bombaProperties: 
%       Qbombas: vector con caudal de bobma.
%       tbombas: tiempo para caudal de bomba.
%     nodoBomba: nodo para la inyeccion del caudal de bomba.
%%

if strcmpi(key2,'default')
    load('monitoresProperties')   
elseif strcmpi(key2,'change')
else
    if strcmpi(key2,'load')
        if nargin<4
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
    
    posNodoMonitores            = varName('posNodMonitores',propiedades);
    monitoresProperties.nNodos  = size(posNodoMonitores,1);
    
    tiempoISIP                  = varName('tiempoISIP', propiedades);
    
    nodoMoni = zeros(1, monitoresProperties.nNodos);
    tol = 1;
    for i=1:monitoresProperties.nNodos
        possibleNode                 = getNodesInPos(tol,meshInfo,posNodoMonitores(i,:));
        nodoMoni(i)                 = possibleNode(1);
    end
    
    monitoresProperties.nodoMonitores = nodoMoni;
    monitoresProperties.posNodos = meshInfo.nodes(nodoMoni,:);
    
    save('monitoresProperties','monitoresProperties')
end

%% display de propiedades
fprintf('---------------------------------------------------------\n');
fprintf('Las <strong>propiedades de los nodos monitores</strong> a utilizar son: \n');
fprintf('(Unidades en mm) \n\n');
format compact
disp('--nodoMonitores: ');   disp(monitoresProperties.nodoMonitores);
% disp('--posNodosMonitores: ');   disp(monitoresProperties.posNodos);
disp(['--nNodos: '      num2str(monitoresProperties.nNodos)]);
format loose

end

% by Pedro :) 
