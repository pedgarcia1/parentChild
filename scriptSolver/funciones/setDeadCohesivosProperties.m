function [ deadCohesivosProperties ] = setDeadCohesivosProperties( key )
%%% DEAD COHESIVOS %%%
deadCohesivos = [];
aux = findNodesInPos(0,meshInfo.anchoY/2,36/2*1e3,0.1,meshInfo.nodes); %anchoZ/2
deadCohesivos = aux(1);
% deadCohesivos = findNodesInPos(0,anchoY/2,anchoZ/10*5,0.1,nodes);
%  deadCohesivos = findNodesInPos(0,anchoY/2,anchoZ/27*13,0.1,nodes);


% aux = findNodesInPos(0,anchoY/2,(0.555556 + 45)*1e3,0.1,nodes);
% deadCohesivos = aux(1);
% aux = findNodesInPos(0,anchoY/2,anchoZ/54*27+anchoZ/54,0.1,nodes);
% deadCohesivos = [deadCohesivos;aux(1)];
% aux = findNodesInPos(0,anchoY/2,anchoZ/54*27-anchoZ/54,0.1,nodes);
% deadCohesivos = [deadCohesivos;aux(1)];
% aux = findNodesInPos(anchoZ/54,anchoY/2,anchoZ/54*27+anchoZ/54,0.1,nodes);
% deadCohesivos = [deadCohesivos;aux(1)];
% aux = findNodesInPos(anchoZ/54,anchoY/2,anchoZ/54*27-anchoZ/54,0.1,nodes);
% deadCohesivos = [deadCohesivos;aux(1)];
% aux = findNodesInPos(anchoZ/54,anchoY/2,anchoZ/54*27,0.1,nodes);
% deadCohesivos = [deadCohesivos;aux(1)];

% aux = findNodesInPos(0,anchoY/2,anchoZ/10*6,0.1,nodes);
% deadCohesivos = [deadCohesivos;aux(1)];
% aux = findNodesInPos(0,anchoY/2,anchoZ/10*4,0.1,nodes);
% deadCohesivos = [deadCohesivos;aux(1)];
% aux = findNodesInPos(0,anchoY/2,18-36/54,0.1,nodes);
% deadCohesivos = [deadCohesivos;aux(1)];
% aux = findNodesInPos(0,anchoY/2,anchoZ/108*54,0.1,nodes);
% deadCohesivos = aux(1);
% aux = findNodesInPos(0,anchoY/2,anchoZ/108*54+anchoZ/108,0.1,nodes);
% deadCohesivos = [deadCohesivos;aux(1)];
% aux = findNodesInPos(0,anchoY/2,anchoZ/108*54-anchoZ/108,0.1,nodes);
% deadCohesivos = [deadCohesivos;aux(1)];
% aux = findNodesInPos(0,anchoY/2,anchoZ/108*54-2*anchoZ/108,0.1,nodes);
% deadCohesivos = [deadCohesivos;aux(1)];
% aux = findNodesInPos(0,anchoY/2,anchoZ/108*54+2*anchoZ/108,0.1,nodes);
% deadCohesivos = [deadCohesivos;aux(1)];

end

