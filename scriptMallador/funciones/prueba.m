%% START %%
clc
clearvars
close all
addpath('C:\matlab\geomec\mallas') 
addpath('C:\matlab\geomec\funciones') 

debugPlots = 1;
saveMat    = 0;

%% DESIRED GAP %%
gap = 1000;
fprintf('%s: %d %s \n','Gap elegido',gap,'mm')

%% MESH LOADING %%
% LOAD NODES FROM ADINA%%

nombreOutput  = 'Casing_NatFrac_ang_0_0.mat';
nodes         = load('CasingAngleRefinement_nodes.txt'); 
elements      = load('CasingAngleRefinement_elements.txt');

% fprintf('%s: %s \n','Nombre de corrida',nombreOutput)

mapeoNodos              = nodes(:,1);
nNod                    = size(nodes,1);
nodes(:,[1 5])          = [];

elements(:,[1 10:end])  = [];
nel                     = size(elements,1);

% MUEVO EL SISTEMA DE COORDENADAS A LA ESQUINA MAS AUSTRAL %%%%
moverEjes = [-min(nodes(:,1))*ones(nNod,1) -min(nodes(:,2))*ones(nNod,1) -min(nodes(:,3))*ones(nNod,1)];
nodes     = nodes + moverEjes;
    
% Arreglo para que la numeracion de nodos arranque en 1%%
 for iNod = 1:size(nodes,1)
        nodoAMapear = mapeoNodos(iNod);
        elements(ismember(elements,nodoAMapear)) = iNod;
 end
 
%% ELEMENTS Y NODES SIN MODIFICAR %%

plotMeshColo3D(nodes,elements,'w')
xlabel 'x'
ylabel 'y'
zlabel 'z'

elementsVanilla = elements;
nodesVanilla    = nodes;
nodes = nodes*1000;

