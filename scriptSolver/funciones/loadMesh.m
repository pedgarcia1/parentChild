function  [meshInfo] =  loadMesh( key,varargin )
%% Help
% loadMesh sirve unicamente para cargar la informacion de la malla
% proveniente del mallador.
% Se puede elegir una malla nueva (como input), continuar trabajando con la
% ultima que fue utilizada, utilizar la malla que esta guardada para 
% verificaciones o cargar una malla nueva a partir de un archivo ya 
% escrito. Para cambiar la malla ingresar como parametro de entrada key.

% key: "change", "default", "test", "load".

% Toda la informacion se guarda en la estrcutura meshInfo y los campos se
% detallan a continuacion.

% meshInfo: Estructura con la informacion de la malla proveniente del
% mallador.

% Pedro: agrego scaleMeshFactor para escalar la malla
%%
if strcmpi(key,'default')
    load('selectedMesh')
    fprintf('---------------------------------------------------------\n');
    fprintf(['La malla a utilizar es <strong>',selectedMesh,'</strong> \n\n']);
    meshInfo = load(selectedMesh);
    
elseif strcmpi(key,'change')
    fprintf('---------------------------------------------------------\n');
    selectedMesh = input('Ingrese nombre de la malla a utilizar. Ej: ''nombre de la malla'': ');
    clc
    meshInfo = load(selectedMesh);
    save('selectedMesh','selectedMesh'); 
    
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
    fprintf('---------------------------------------------------------\n');
    selectedMesh = propiedades{1,2};
    fprintf(['La malla a utilizar es <strong>',selectedMesh,'</strong> \n\n']);
    meshInfo = load(selectedMesh);
    save('selectedMesh','selectedMesh');
end
% Se agrega informacion util extra a la del mallador que sera utilizada a
% lo largo del programa.
meshInfo.selectedMesh = selectedMesh; % Nombre de la malla seleccionada.
meshInfo.nMaster = size(meshInfo.elementsBarra.ALL,1); % Relacion entre mallaS.
% meshInfo.nWinkler = size(meshInfo.winkler.elements,1); % Numero de elementos Winkler. 
meshInfo.nCohesivos = size(meshInfo.cohesivos.elements,1); % Numero de elementos Cohesivos.
meshInfo.nElEB = size(meshInfo.elementsBarra.ALL,1); % Numero de elementos "barra".
meshInfo.nFluidos = size(meshInfo.elementsFluidos.elements,1); % Numero de elementos Fluidos.

end