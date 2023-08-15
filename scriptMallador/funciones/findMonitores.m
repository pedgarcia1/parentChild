function [nodoBomba, nodosMonitores] = findMonitores(nodes, posNodoBomba,sizeElements)
% Devuelve la posicion y el orden de los nodos monitores segun un nodo
% bomba ingresado. 
% - posNodoBomba deberia ser una matriz nx3, siendo n la cantidad de nodos
% bomba y en cada columna la posicion del nodo bomba en las cada direccion.
% WARNING: no esta contemplada la posibilidad de que haya menos de dos
% elementos entre el nodo bomba y el extremo de la malla
% - sizeElements es un vector 1x3 con el tamanio de los elementos en cada
% direccion asumiendo que son iguales o que al menos se partio de elementos
% h8 iguales y se aplico un refinamiento posterior.
% - nodes la matriz de nodos
for t = 1:size(posNodoBomba,1)
nodoBomba.coords(t,:) = posNodoBomba(t,:);
nodoBomba.index(t) = find(sum(nodes==posNodoBomba(t,:),2)==3);

nodosMonitores.coords{t}(1,:) = [posNodoBomba(t,1)-2*sizeElements(1),posNodoBomba(t,2),posNodoBomba(t,3)]; 
nodosMonitores.coords{t}(2,:) = [posNodoBomba(t,1)+2*sizeElements(1),posNodoBomba(t,2),posNodoBomba(t,3)]; 
nodosMonitores.coords{t}(3,:) = [posNodoBomba(t,1),posNodoBomba(t,2)-2*sizeElements(2),posNodoBomba(t,3)]; 
nodosMonitores.coords{t}(4,:) = [posNodoBomba(t,1),posNodoBomba(t,2)+2*sizeElements(2),posNodoBomba(t,3)]; 
nodosMonitores.coords{t}(5,:) = [posNodoBomba(t,1),posNodoBomba(t,2),posNodoBomba(t,3)-2*sizeElements(3)]; 
nodosMonitores.coords{t}(6,:) = [posNodoBomba(t,1),posNodoBomba(t,2),posNodoBomba(t,3)+2*sizeElements(3)]; 

for i = 1:6
try
nodosMonitores.index{t}(i) = find(sum(nodes==nodosMonitores.coords{t}(i,:),2)==3);
catch 
if i<3
[~,x1] = min(abs(nodosMonitores.coords{t}(i,1)-nodes(:,1)))
nodosMonitores.coords{t}(i,1)=nodes(x1,1);
nodosMonitores.index{t}(i) = find(sum(nodes==nodosMonitores.coords{t}(i,:),2)==3);
elseif i<5
[~,y1] = min(abs(nodosMonitores.coords{t}(i,2)-nodes(:,2)))
nodosMonitores.coords{t}(i,2)=nodes(y1,2);
nodosMonitores.index{t}(i) = find(sum(nodes==nodosMonitores.coords{t}(i,:),2)==3);
else
[~,z1] = min(abs(nodosMonitores.coords{t}(i,3)-nodes(:,3)))
nodosMonitores.coords{t}(i,3)=nodes(x1,3);
nodosMonitores.index{t}(i) = find(sum(nodes==nodosMonitores.coords{t}(i,:),2)==3);
end
end
end
end
end