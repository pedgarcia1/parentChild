function He = HFluidos2D(elementsFluidos,iele,hh,MU,cohesivos,nodes,angDilatancy)
nDofNod = 1;                    % Numero de grados de libertad por nodo
nNodEle = 4;                    % Numero de nodos por elemento

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
HeE             = cell(npg,1);
Rot = cohesivos.T(:,:,iele);
nodosElemento = transpose(Rot'*nodes(cohesivos.elements(iele,:),:)');
nodosElemento = nodosElemento(:,~all(abs(diff(nodosElemento))< 1));

hhEle           = hh(elementsFluidos.relatedEB(iele,:));
%%% DOFS FLUIDOS y NODOS FLUIDOS locales es analogo ya que en la malla
%%% local de fluidos, el numero de nodo es el mismo dof.
for ipg = 1:npg
    % Punto de Gauss
    ksi = upg(ipg,1);
    eta = upg(ipg,2);
    % Derivadas de las funciones de forma respecto de ksi, eta
    dN = 1/4*[-(1-eta)   1-eta    1+eta  -(1+eta)
        -(1-ksi) -(1+ksi)   1+ksi    1-ksi ];
    % Derivadas de x,y, respecto de ksi, eta
    jac = dN*nodosElemento;
    if det(jac) < 0 
        error('Determinante de jacobiano < 0  en HFluidos2D')
    end
    % Derivadas de las funciones de forma respecto de x,y.
    dNxy = jac\dN;          % dNxy = inv(jac)*dN
    
    B = zeros(2,nDofNod*nNodEle);
    B(1,:) = dNxy(1,:);
    B(2,:) = dNxy(2,:);
    
    % Interpolacion de los valores nodales de h a los ipg
    %h = Ni(1,:,ipg)*hhEle;
    h   = cohesivos.dNCalculado(iele,ipg); h(h<0) = 0;
    dS1 = cohesivos.dS1Calculado(iele,ipg);
    dS2 = cohesivos.dS2Calculado(iele,ipg);
    
    h = h + dS2*tand(angDilatancy) + dS1*tand(angDilatancy); % apertura efectiva 
    % Matriz H local del elemento en el ipg
    HL = h^2 / (12 * MU) * [ 1   0
                             0   1];
    HeE{ipg} =  B'*HL*B*wpg(ipg)*det(jac)*h;
end
row = repmat((1:nDofNod*nNodEle),nDofNod*nNodEle,1);
col = row';
He = sparse(repmat(col,npg,1),repmat(row,npg,1),vertcat(HeE{:}));
end