function [area,volume] = areaVolumeInterfaceElement2(elementsFluidos,iele,cohesivos,iTime)
nDofNod = 1;                    % N�mero de grados de libertad por nodo
nNodEle = 4;                    % N�mero de nodos por elemento

%% Gauss

a   = 1/sqrt(3);
% Ubicaciones puntos de Gauss
upg = [ -a  -a
         a  -a
         a   a
        -a   a ];    
% N�mero de puntos de Gauss
npg = size(upg,1);
wpg = ones(npg,1);

%% Funciones de forma

Ni = zeros(1,4,npg);
for ipg = 1:npg
    
    ksi = upg(ipg,1);
    eta = upg(ipg,2);
    
    N4 = 0.25*(1 - ksi)*(1 + eta);
    N3 = 0.25*(1 + ksi)*(1 + eta);
    N2 = 0.25*(1 + ksi)*(1 - eta);
    N1 = 0.25*(1 - ksi)*(1 - eta);
    
    Ni(1,:,ipg) = [N1 N2 N3 N4];
end


%% Matriz [H] global
nodesEle        = elementsFluidos.nodesEle(:,:,iele);
area            = 0;
volume          = 0;
for ipg = 1:npg
    % Punto de Gauss
    ksi = upg(ipg,1);
    eta = upg(ipg,2);
    % Derivadas de las funciones de forma respecto de ksi, eta
    dN = 1/4*[-(1-eta)   1-eta    1+eta  -(1+eta)
        -(1-ksi) -(1+ksi)   1+ksi    1-ksi ];
    % Derivadas de x,y, respecto de ksi, eta
    jac = dN*nodesEle;
    % Derivadas de las funciones de forma respecto de x,y.
    dNxy = jac\dN;          % dNxy = inv(jac)*dN
    
    B = zeros(2,nDofNod*nNodEle);
    B(1,:) = dNxy(1,:);
    B(2,:) = dNxy(2,:);

    gap = cohesivos.dNTimes(iele,ipg,iTime);
    gap(gap<0) = 0;
    
    area = area + det(jac)*wpg(ipg);
    volume = volume + gap*det(jac)*wpg(ipg);

    
end



end
