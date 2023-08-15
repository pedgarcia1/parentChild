function [nodes] = inclinarPlanos(nodes,elements,elementSizeX,alpha,beta,debugPlots)  

anchoX       = max(nodes(:,1));
anchoY       = max(nodes(:,2));
anchoZ       = max(nodes(:,3));
nodesVanilla = nodes;

%% IDENTIFICO PLANO VERTICAL  
%a partir de esta fractura vertical voy a hacer el corrimiento de todos los planos

planosPosY = [0 anchoY];
planosPosZ = [0 anchoZ];
tol = 0.5; 

for i = 1:anchoX/(elementSizeX)-1
    planosPosX = elementSizeX*i;
    [nodesPlano.coords,nodesPlano.index] = nodosFracturasX2(planosPosX,planosPosY,planosPosZ,nodes,tol); %identifico nodos del plano i
    nodes = corrimientoFrac(alpha,beta,nodes,nodesPlano.coords,nodesPlano.index);             %hago corrimiento de nodos del plano i
%         figure
%         plotMeshColo3D(nodes,elements,'w')
%         hold off
     
end

figure
 plotMeshColo3D(nodes,elements,'w')
        hold off
        
%corro el ultimo plano para que el ultimo plano inclinado no salga del dominio de la malla
if max(nodes(:,1)) > max(nodesVanilla(:,1))
    [nodesPlano.coords,nodesPlano.index] = nodosFracturasX2(anchoX,planosPosY,planosPosZ,nodes,tol);
    dist =  max(nodes(:,1)) - nodesPlano.coords(:,1);
    nodesPlano.coords(:,1) = nodesPlano.coords(:,1) + dist + 1000;
    nodes(nodesPlano.index) = max(nodesPlano.coords(:,1));
    if debugPlots ==1
        figure
        plotMeshColo3D(nodes,elements,'w')
        hold off
    end 
end

 %corro el primer plano para que el primer plano inclinado no salga del dominio de la malla
if min(nodes(:,1)) < min(nodesVanilla(:,1)) 
    [nodesPlano.coords,nodesPlano.index] = nodosFracturasX2(0,planosPosY,planosPosZ,nodes,tol);
    dist =  abs(min(nodes(:,1))) - nodesPlano.coords(:,1);
    nodesPlano.coords(:,1) = nodesPlano.coords(:,1) - dist - 1000;
    nodes(nodesPlano.index) = max(nodesPlano.coords(:,1));
end

figure
 plotMeshColo3D(nodes,elements,'w')
        hold off
        
end