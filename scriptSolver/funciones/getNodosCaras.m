function [nodosCara, cara ] = getNodosCaras(meshInfo,paramDiscEle)
% getNodosCaras es una funcion que sirve para obtener "caras" que contiene 
% vectores logicos que separan los nodos de las caras y "nodosCaras" que  
% contiene los nodos de cada cara correspondiente.
%%
tol          = 1e-8; % tolerancia admisible para la posicion de los nodos.
cara.inferior = abs(meshInfo.nodes(1:paramDiscEle.nDofTot_P,3) - 0) < tol;                        %(_P es nodos sin winklers. serian de presion) 
cara.superior = abs(meshInfo.nodes(1:paramDiscEle.nDofTot_P,3) - meshInfo.anchoZ) < tol;
cara.sur      = abs(meshInfo.nodes(1:paramDiscEle.nDofTot_P,2) - 0) < tol;
cara.norte    = abs(meshInfo.nodes(1:paramDiscEle.nDofTot_P,2) - meshInfo.anchoY) < tol;
cara.este     = abs(meshInfo.nodes(1:paramDiscEle.nDofTot_P,1) - meshInfo.anchoX) < tol;
cara.oeste    = abs(meshInfo.nodes(:,1) - 0) < tol;

aux = 1:max([size(cara.inferior),size(cara.superior),size(cara.este),size(cara.oeste),size(cara.norte),size(cara.sur)]); % Artilugio para no usar la funcion find.
nodosCara.inferior = aux(cara.inferior);
nodosCara.superior = aux(cara.superior);
nodosCara.este     = aux(cara.este);
nodosCara.oeste    = aux(cara.oeste);
nodosCara.norte    = aux(cara.norte);
nodosCara.sur      = aux(cara.sur);


end

