function [coords, index] = nodosFracturasZ(posXFractura,posZFractura,posYFractura,nodes,tol)

%%% Procesamiento de data para el inpolygon, la fractura se encuentra en el
%%% plano Z-Y y esta alineada con el eje X

% xv = [posXFractura-tol;posXFractura+tol;posXFractura+tol;posXFractura-tol;posXFractura-tol];
% yv = [posYFractura(1)-tol;posYFractura(1)-tol;posYFractura(2)+tol;posYFractura(2)+tol;posYFractura(1)-tol];

zv = [posZFractura-tol;posZFractura+tol;posZFractura+tol;posZFractura-tol;posZFractura-tol];
xv = [posXFractura(1)-tol;posXFractura(1)-tol;posXFractura(2)+tol;posXFractura(2)+tol;posXFractura(1)-tol];


xq = nodes(:,1);
zq = nodes(:,3);

[in,~] = inpolygon(xq,zq,xv,zv);
number_nodFis1 = find(in);
nodes_fis1 = nodes(number_nodFis1,:);

n = size(nodes_fis1,1);
nStirr = false(n,1);

for iNod=1:n
    yCoord = nodes_fis1(iNod,2);
    if yCoord<=posYFractura(2) && yCoord>=posYFractura(1)
        nStirr(iNod) = true;
    end
    
end
index  = number_nodFis1(nStirr);
coords = nodes_fis1(nStirr,:);

end
