function [ bombaProperties ] = setBombaProperties3(meshInfo,key,key2,varargin )
% setBombaProperties es una funcion que sirve para setear las
% propiedades de la bomba.
% Se puede elegir establecer dichas propiedades (a mano), continuar 
% trabajando con las utlimas que se utilizaron, utilizar las propiedades de
% la corrida de verificacion o cargar las propeidades de un archivo ya 
% escrito. Para cambiar las propiedades fisicas del problema ingresar como 
% key.

% key: "change" "default" "test" "load"

% Para plotear la curva del caudal de bomba ingresada y observar el caudal
% de bomba suavizado ingresar como key2.

% key2: "on" "off"

% Las propiedades se guardan en la estrcutura "bombaProperties" con los
% siguientes campos:
% bombaProperties: 
%       Qbombas: vector con caudal de bobma.
%       tbombas: tiempo para caudal de bomba.
%     nodoBomba: nodo para la inyeccion del caudal de bomba.
%%

% scaleMeshFactor = varargin{2};
if strcmpi(key2,'default')
    load('bombaProperties')   
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
    BPM2mm3s    = 0.00264979 * (1000)^3;
    propiedades = getProperties(archivo);
    
    bombaProperties.QbombasOG   = varName('Q', propiedades);
    bombaProperties.tbombasOG   = varName('tQ', propiedades);
    posNodoBomba                = varName('posNodoBomba', propiedades);
    bombaProperties.QProduccion = 0;
    bombaProperties.nBombas     = size(bombaProperties.QbombasOG,1);
    
    
    tiempoISIP                  = varName('tiempoISIP', propiedades);
    
    nodoBomba = zeros(1, bombaProperties.nBombas);
    for i=1:bombaProperties.nBombas
        possibleNode                 = getNodesInPos(10,meshInfo,posNodoBomba(i,:));
        nodoBomba(i)                 = possibleNode(1);
    end
    
    bombaProperties.nodoBomba = nodoBomba;
    
    save('bombaProperties','bombaProperties')
end

if strcmpi(key,'On')
    BPM2mm3s      = 0.00264979 * (1000)^3;
    figure
    for i=1:bombaProperties.nBombas
        plot(bombaProperties.tbombasOG(i,:),bombaProperties.QbombasOG(i,:));
        hold on
        [tbombas ,Qbombas ] = suavizado( bombaProperties.tbombasOG(i,:),bombaProperties.QbombasOG(i,:),1,40,5);
        plot(tbombas,Qbombas,'o-');
    end
    xlabel('Tiempo[s]')
    ylabel('Caudal [BPM]')
    title('Caudal vs tiempo')
    legend('Curva original','Curva suavizada')
    grid
    axis([0 max(max(bombaProperties.tbombasOG))*1.1 min(min(bombaProperties.QbombasOG))-0.1 max(max(bombaProperties.QbombasOG))*1.1]) 
end
fprintf('---------------------------------------------------------\n');
fprintf('Las <strong>propiedades de la bomba</strong> a utilizar son: \n');
fprintf('(Unidades en mm3/s, mm y s) \n\n');
format compact
disp('--QbombasOG: ');   disp(bombaProperties.QbombasOG);
disp('--tBombasOG: ');   disp(bombaProperties.tbombasOG);
disp(['--QProduccion: '  num2str(bombaProperties.QProduccion)]);
disp(['--nBombas: '      num2str(bombaProperties.nBombas)]);
disp(['--nodoBomba: '     num2str(bombaProperties.nodoBomba)]);
format loose

%% Suavizado y arreglo del caudal de entrada.
% Se suaviza el caudal de bomba para eliminar saltos discretos que pueda llegar a tener la funcion. 
for i=1:bombaProperties.nBombas
    [bombaProperties.tbombas(i,:) ,bombaProperties.Qbombas(i,:) ] = suavizado( bombaProperties.tbombasOG(i,:) ,bombaProperties.QbombasOG(i,:) ,1,40,5);
end
% Al vector caudal de bomba se le incorpora el ISIP y la produccion (por
% ahora con un caudal negativo).
tInicioInyeccion = bombaProperties.tbombas(:,1);
tFinInyeccion = bombaProperties.tbombas(:,end);
tInicioISIP = max(bombaProperties.tbombas(:,end))*ones(bombaProperties.nBombas,1);

bombaProperties.Qbombas = [0*ones(bombaProperties.nBombas,2),                    bombaProperties.Qbombas, zeros(bombaProperties.nBombas,2)];
bombaProperties.tbombas = [-1*ones(bombaProperties.nBombas,1), tInicioInyeccion, bombaProperties.tbombas, tFinInyeccion, tInicioISIP+1];

% Se vuelve a suavizar con distintos parametros. 
% [bombaProperties.tbombas ,bombaProperties.Qbombas ] = suavizado( bombaProperties.tbombas ,bombaProperties.Qbombas ,0.1,100,50);
bombaProperties.Qbombas = bombaProperties.Qbombas*0.00264979 * (1000)^3;
end

