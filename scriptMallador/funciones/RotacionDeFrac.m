function [nodes] = RotacionDeFrac(alpha,beta,nodes,nodesFisuindex,nodesFisu.Y.coords)

%% ANGULO CON RESPECTO A EJE X %% 
% angulo horizontal 

alpha = deg2rad(alpha);
delta1 = nodesFisu.Y.coords(:,1)*tan(alpha);

if desdeMitad == 1
    puntoMedio = (max(nodesFisu.Y.coords(:,1)) - min(nodesFisu.Y.coords(:,1)))/2;
    dif =  puntoMedio*tan(alpha);
    delta1 = delta1 - dif;
end

nodesFisu.Y.coords(:,2) = nodesFisu.Y.coords(:,2) + delta1;

if debugPlots == 1
scatter3(nodesFisu.Y.coords(:,1),nodesFisu.Y.coords(:,2),nodesFisu.Y.coords(:,3))
end

nodes(nodesFisu.Y.index,2) = nodesFisu.Y.coords(:,2);

figure
plotMeshColo3D(nodes,elements,'w')
 
%% ANGULO CON RESPECTO A EJE Z %%
% angulo vertical 

beta = 5; 
beta = deg2rad(beta);
delta2 = nodesFisu.Y.coords(:,3)*tan(beta);

if desdeMitad == 1
    puntoMedio = (max(nodesFisu.Y.coords(:,3)) - min(nodesFisu.Y.coords(:,3)))/2;
    dif =  puntoMedio*tan(beta);
    delta2 = delta2 - dif;
end

nodesFisu.Y.coords(:,2) = nodesFisu.Y.coords(:,2) - delta2;

if debugPlots == 1
scatter3(nodesFisu.Y.coords(:,1),nodesFisu.Y.coords(:,2),nodesFisu.Y.coords(:,3))
end

nodes(nodesFisu.Y.index,2) = nodesFisu.Y.coords(:,2);

figure
plotMeshColo3D(nodes,elements,'w')
hold off
