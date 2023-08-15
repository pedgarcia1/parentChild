function nodes = corrimientoFrac(alpha,beta,nodes,nodesFisucoords,nodesFisuindex)
%rotacion horaria de planos 
%% ANGULO CON RESPECTO A EJE Y %
%entrar a mano el angulo

alpha = deg2rad(alpha);
delta1 = nodesFisucoords(:,2)*tan(alpha);

puntoMedio = (max(nodesFisucoords(:,2)) - min(nodesFisucoords(:,2)))/2;
dif =  puntoMedio*tan(alpha);
delta1 = delta1 - dif;

nodesvan = nodesFisucoords(:,1);

nodesFisucoords(:,1) = nodesFisucoords(:,1) + delta1;

nodes(nodesFisuindex,1) = nodesFisucoords(:,1);

nodesvan(:,2) =  nodesFisucoords(:,1);

%% ANGULO CON RESPECTO A EJE Z %%
% angulo vertical

beta = deg2rad(beta);
delta2 = (max(nodes(:,3))-nodesFisucoords(:,3))*tan(beta);

nodesFisucoords(:,1) = nodesFisucoords(:,1) + delta2;

nodes(nodesFisuindex,1) = nodesFisucoords(:,1);
end