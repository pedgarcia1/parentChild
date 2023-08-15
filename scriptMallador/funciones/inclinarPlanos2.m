function [nodes] = inclinarPlanos2(nodes,elements,alpha,beta,posYAnglePlanes,posYAngleNatFracs,ancho)  

anchoX       = max(nodes(:,1));
anchoY       = max(nodes(:,2));
anchoZ       = max(nodes(:,3));
nodesVanilla = nodes;

%% IDENTIFICO PLANO VERTICAL  
%a partir de esta fractura vertical voy a hacer el corrimiento de todos los planos

planosPosX = [0 anchoX];
planosPosZ = [0 anchoZ];
tol = 1e-9; 

%% seleccion de planos que se desean rotar  

yPlanes  = sort(uniquetol(nodes(:,2),1e-4));                                         % todos los planos con normal y de la malla 
posY     = yPlanes(yPlanes >= posYAnglePlanes(1) & yPlanes <= posYAnglePlanes(end)); % planos con normal y que se desean rotar  
noAngleY = yPlanes(yPlanes < posYAnglePlanes(1) | yPlanes > posYAnglePlanes(end)); % planos con normal y que se desean rotar  

% correccion por si estan todos los planos seleccionados para mover -- el
% primero y el ultimo deben quedarse sin rotacion
 if posY(end) == anchoY
     posY = posY(1:end-1);
 end
 
 if posY(1) == 0
     posY = posY(2:end);
 end

 
%% me armo el vector de angulos

nAnglePlanes = sum(posY >= posYAngleNatFracs(1) & posY <= posYAngleNatFracs(end)); 
nTPlanes1 = sum(posY < posYAngleNatFracs(1));
nTPlanes2 = sum(posY > posYAngleNatFracs(end));

alphaVec = alpha*[(1:nTPlanes1)/nTPlanes1,ones(1,nAnglePlanes),flip(1:nTPlanes2)/nTPlanes2];

%% corrimiento y correccion de posiciones de planos 


for i = 1:length(posY)
    planoPosY = posY(i);
    [nodesPlano.coords,nodesPlano.index] = nodosFracturasY2(planosPosX,planoPosY,planosPosZ,nodes,tol);  %identifico nodos del plano i
    [nodes,~] = corrimientoFrac2(alphaVec(i),beta,nodes,nodesPlano.coords,nodesPlano.index);             %hago corrimiento de nodos del plano i

    figure 
   
plotMeshColo3D(nodes,elements,'w')
view([0 0 1])

%  [nodesPlano.coords,nodesPlano.index] = nodosFracturasY2(planosPosX,planoPosY,planosPosZ,nodes,tol);  %identifico nodos del plano i
%  nodes    
%  [nodes,~] = corrimientoFrac2(alphaVec(i),beta,nodes,nodesPlano.coords,nodesPlano.index);             %hago corrimiento de nodos del plano i
%     [nodes2,~] = corrimientoFrac3(alphaVec(i),ancho,nodes,nodesPlano.coords,nodesPlano.index,planoPosY); %hago corrimiento de nodos del plano i 
% %     angFracAllIndices(:,i) = angFracIndex;

% subplot(1,2,2)
% plotMeshColo3D(nodes2,elements,'w')
% title('puntoFuga')
% hold off
% view([0 0 1])

end

% 


%corro el ultimo plano para que el ultimo plano inclinado no salga del dominio de la malla
if max(nodes(:,2)) > max(nodesVanilla(:,2))
    [nodesPlano.coords,nodesPlano.index] = nodosFracturasY2(planosPosX,anchoY,planosPosZ,nodes,tol);
    dist =  abs(max(nodes(:,2)) - nodesPlano.coords(:,2));
    nodesPlano.coords(:,2) = nodesPlano.coords(:,2) + dist + 10e3*ones(size(dist,1),1);
    nodes(nodesPlano.index,2) = nodesPlano.coords(:,2);
end


%  %corro el primer plano para que el primer plano inclinado no salga del dominio de la malla
% if minY(1) < min(noAngleY)
%     dist =  abs(posY(1) - min(noAngleY));
%     nodes(angFracAllIndeces(:,1),2) = nodes(angFracAllIndeces(:,1),2) - (dist+10e3)*(ones(size(angFracAllIndeces(:,1)))); 
% end


figure
plotMeshColo3D(nodes,elements,'w')
hold off

% 
% for i = 1:size(minY,1)-1
% if minY(i+1) < minY(i)
%     dist =  abs(minY(i) - minY(i+1));
%     fracIndices = angFracAllIndeces(:,i);
%     nodes(fracIndices,2) = nodes(fracIndices,2) + (dist + 10e3)*(size(fracIndices,1));
% end
% 
% figure
% plotMeshColo3D(nodes,elements,'w')
% hold off

        
end