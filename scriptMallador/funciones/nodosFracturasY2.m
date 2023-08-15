function [coords, index] = nodosFracturasY2(posXFractura,posYFractura,posZFractura,nodes,tol)

%%% Procesamiento de data para el inpolygon, la fractura se encuentra en el
%%% plano Z-X y esta alineada con el eje Y

yv = [posYFractura-tol; posYFractura+tol; posYFractura+tol; posYFractura-tol; posYFractura-tol];
xv = [posXFractura(1)-tol; posXFractura(1)-tol; posXFractura(2)+tol; posXFractura(2)+tol; posXFractura(1)-tol];


xq = nodes(:,1);
yq = nodes(:,2);

[in,~] = inpolygon(xq,yq,xv,yv);
number_nodFis1 = find(in);
nodes_fis1 = nodes(number_nodFis1,:);

n = size(nodes_fis1,1);
nStirr = false(n,1);

for iNod=1:n
    zCoord = nodes_fis1(iNod,3);
    if zCoord<=(posZFractura(2)+tol) && zCoord>=(posZFractura(1)-tol)
        nStirr(iNod) = true;
    end
    
end
index  = number_nodFis1(nStirr);
coords = nodes_fis1(nStirr,:);

end
