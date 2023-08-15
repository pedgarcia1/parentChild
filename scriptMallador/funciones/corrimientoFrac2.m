function nodes = corrimientoFrac2(alpha,beta,nodes,nodesFisucoords,nodesFisuindex)
%rotacion horaria de planos 
%% ANGULO CON RESPECTO A EJE Y %
%entrar a mano el angulo

alpha = deg2rad(alpha);
delta1 = nodesFisucoords(:,1)*tan(alpha);

puntoMedio = (max(nodesFisucoords(:,1)) - min(nodesFisucoords(:,1)))/2;
dif =  puntoMedio*tan(alpha);
delta1 = delta1 - dif;

nodesvan = nodesFisucoords(:,2);

nodesFisucoords(:,2) = nodesFisucoords(:,2) + delta1;

nodes(nodesFisuindex,2) = nodesFisucoords(:,2);

nodesvan(:,1) =  nodesFisucoords(:,2);

%% ANGULO CON RESPECTO A EJE Z %%
% angulo vertical

beta = deg2rad(beta);
delta2 = (max(nodes(:,3))-nodesFisucoords(:,3))*tan(beta);

nodesFisucoords(:,2) = nodesFisucoords(:,2) + delta2;

nodes(nodesFisuindex,2) = nodesFisucoords(:,2);

nodesAngFrac = nodesFisuindex;
end