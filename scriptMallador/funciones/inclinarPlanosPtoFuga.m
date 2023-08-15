function [nodesSal,nodesFisu] = inclinarPlanosPtoFuga(nodes,elements,nodesFisu,alpha,posYAnglePlanes,posYAngleDFNs,distNatFracs,ancho,param)  

nodesVanilla = nodes;
tol1 = 1e-4;
tol = 2;
tol2 = 0.00001;

%% IDENTIFICACION DE PLANOS VERTICALES DE LA MALLA
planosPosX = [0 ancho(1)];
planosPosZ = [0 ancho(3)];

% seleccion de planos que se desean rotar
% - todos los planos con normal y:
yPlanes        = sort(uniquetol(nodes(:,2),1e-4));

% - planos con normal y que se desean rotar:
rotationPlanes = yPlanes(yPlanes >= posYAnglePlanes(1) & yPlanes <= posYAnglePlanes(end));

% correccion por si estan todos los planos seleccionados para mover -- el
% primero y el ultimo no deben rotar
if rotationPlanes(end) == ancho(2)
    rotationPlanes = rotationPlanes(1:end-1);
end

if rotationPlanes(1) == 0
    rotationPlanes = rotationPlanes(2:end);
end

% - zona de dfns 
DFNPlanes = yPlanes(yPlanes >= posYAngleDFNs(1) & yPlanes <= posYAngleDFNs(end));


%% me armo el vector de angulos

nAnglePlanes = size(DFNPlanes,1);                              % cant planos de dfn
nTPlanes1    = sum(rotationPlanes < posYAngleDFNs(1) - tol );  % cant planos de transicion ascendente
nTPlanes2    = sum(rotationPlanes > posYAngleDFNs(end) + tol); % cant planos de transicion descendente

alpha        = deg2rad(alpha);
alphaVec     = alpha*[(1:nTPlanes1)/(nTPlanes1+1),ones(1,nAnglePlanes),flip(1:nTPlanes2)/(nTPlanes2+1)];

%% ubicacion del punto de fuga
% posYptoFuga(1): posicion punto de fuga zona ascendente
% posYptoFuga(2): posicion punto de fuga zona descendente

x           = find((~(ismembertol(yPlanes,rotationPlanes,'ByRows',true)))==0);
posYptoFuga = yPlanes(x(1)-1);
ptoFuga(1,:)     = [-ancho(1)/param posYptoFuga 0];

% identifico el ultimo plano de DFN q determinara el 2do punto de fuga
lastDFNPlane = max(find(alphaVec == alpha));
c = 0; % counter para cantidad de dnfs 

%% corrimiento y correccion de posiciones de planos
lastAlpha = 0;

if alpha ~=1
for i = 1:length(rotationPlanes)
    
    planoPosY = rotationPlanes(i);
    [nodesFisucoords,nodesFisuindex] = nodosFracturasY2(planosPosX,planoPosY,planosPosZ,nodes,tol1);
    %     nodes = corrimientoFrac3(alphaVec(i),beta,nodes,elements,nodesPlano.coords,nodesPlano.index,diffAlphaVec(i),ancho,posYptoFuga,distNatFracs);
   
    if alphaVec(i) >= lastAlpha
        
        % si estoy en la zona de transicion ascendente
        if alphaVec(i) > alpha+rad2deg(tol2) || alphaVec(i) < alpha-rad2deg(tol2)
            h = (nodesFisucoords(:,1)+abs(ptoFuga(1,1)))*tan(alphaVec(i));
            nodesFisucoords(:,2) = h + posYptoFuga;
            
            if i == 1
               dist2 = min(nodesFisucoords(:,2)) - posYptoFuga ; % para despues 
            end
       
        % si estoy en la zona de dfns    
        else
            h = (nodesFisucoords(:,1)+abs(ptoFuga(1,1)))*tan(alphaVec(i));
            nodesFisucoords(:,2) = h + c*distNatFracs*ones(size(nodesFisucoords(:,1),1),1) + posYptoFuga;
            c = c+1; % counter por si hay mas de una dfn
            
            if i == lastDFNPlane % cambio el punto de fuga!!
                posYptoFuga = max(nodesFisucoords(:,2)) + (ancho(1)/param)*tan(alphaVec(i));
                ptoFuga(2,:) = [ancho(1)*(1+1/param) posYptoFuga 0];
            end
        end
        
    %si estoy en la zona de transicion descendente
    else
        x = ones(size(nodesFisucoords(:,1),1),1)*ptoFuga(2,1) - nodesFisucoords(:,1);
        h =  x*tan(alphaVec(i));
        nodesFisucoords(:,2) = ptoFuga(2,2)*ones(size(nodesFisucoords(:,1),1),1)-h;
    end
%     
%     figure
%     plotMitadMalla(nodes,elements,2)
%     hold on
%     scatter3(nodesFisucoords(:,1),nodesFisucoords(:,2),nodesFisucoords(:,3),'r');
%     scatter3(ptoFuga(:,1),ptoFuga(:,2),ptoFuga(:,3),'b')
%     view([0 0 1])
% %     
    nodes(nodesFisuindex,2) = nodesFisucoords(:,2);
  
lastAlpha = alphaVec(i);
end


%% corro el ultimo plano para que el ultimo plano inclinado no salga del dominio de la malla

if max(nodes(:,2)) > max(nodesVanilla(:,2))-0.1e3
    [nodesPlano.coords,nodesPlano.index] = nodosFracturasY2(planosPosX,ancho(2),planosPosZ,nodes,tol1);
    dist =  abs(max(nodes(:,2)) - nodesPlano.coords(:,2));
    nodesPlano.coords(:,2) = nodesPlano.coords(:,2) + dist + dist2*ones(size(dist,1),1);
    nodes(nodesPlano.index,2) = nodesPlano.coords(:,2);
end


%     figure
%     plotMitadMalla(nodes,elements,2)
%     hold on
% %     scatter3(nodesFisucoords(:,1),nodesFisucoords(:,2),nodesFisucoords(:,3),'r');
%     scatter3(ptoFuga(:,1),ptoFuga(:,2),ptoFuga(:,3),'b')
%     view([0 0 1])
%     
    
%% MUEVO EL SISTEMA DE COORDENADAS A LA ESQUINA MAS AUSTRAL %%
nNod      = size(nodes,1);
moverEjes = [-min(nodes(:,1))*ones(nNod,1) -min(nodes(:,2))*ones(nNod,1) -min(nodes(:,3))*ones(nNod,1)];
nodes     = nodes + moverEjes;

% corrijo las facturas, ahora van a ser oblicuas
end
nodesSal = nodes;
nodesFisu.coords = nodes(nodesFisu.index,:);
end