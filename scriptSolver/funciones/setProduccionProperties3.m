function [produccionProperties] = setProduccionProperties3(key,varargin)
% setProduccionProperties es una funcion que sirve para setear las
% propiedades de durante la produccion.
% Se puede elegir establecer dichas propiedades (a mano), continuar 
% trabajando con las utlimas que se utilizaron, utilizar las propiedades de
% la corrida de verificacion o cargar las propeidades de un archivo ya 
% escrito. Para cambiar las propiedades como key.

% key: "change" "default" "test" "load"

% Las propiedades se guardan en la estrcutura "produccionProperties" con los
% siguientes campos:
% produccionProperties: 
%             pColumna: presion en el nodo bomba durante la produccion.
%%
if strcmpi(key,'default')
    load('produccionProperties')
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
    psi2MPa   = 6894.76/1e6;
    propiedades = getProperties(archivo);    
    produccionProperties.modoProduc  = varName('modo', propiedades);
    produccionProperties.pColumna    = varName('pProduccion', propiedades)*psi2MPa;
    produccionProperties.QProduc     = varName('QProduccion', propiedades)*0.00264979 * (1000)^3;
    produccionProperties.tColumna    = varName('tProduccion', propiedades);
    produccionProperties.frontImperm = varName('frontImpermeable', propiedades);
    save('produccionProperties','produccionProperties')
end

fprintf('---------------------------------------------------------\n');
fprintf('Las <strong>propiedades de produccion</strong> a utilizar son: \n');
disp(produccionProperties);

%Si produzco en 2 nodos entre 0 y 200seg, y entre 400 y 600seg, a q
%cte: mientras producen, tienen su q interpolado de produccion; cuando
%no producen, tienen q=0.
%Si produzco a p cte: mientras producen tienen su p de produccion;
%cuando no producen, tienen q=0 y no conozco ese dof de presion.

nNodProd = size(produccionProperties.tColumna,1);
maxT = max(max(produccionProperties.tColumna));
produccionProperties.pColumna = [zeros(nNodProd,2), produccionProperties.pColumna, zeros(nNodProd,2)];
produccionProperties.QProduc  = [zeros(nNodProd,2), produccionProperties.QProduc, zeros(nNodProd,2)];
produccionProperties.tColumna = [ones(nNodProd,1)*(-1), produccionProperties.tColumna(:,1), produccionProperties.tColumna, produccionProperties.tColumna(:,2), ones(nNodProd,1)*maxT];

end