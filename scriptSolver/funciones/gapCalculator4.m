function cohesivos = gapCalculator4(nodes,cohesivos,dITER)
%Calcula dN en GP para cada cohesivo y lo guarda en meshInfo.cohesivos.dNCalculado
nNod     = size(nodes,1);
nodeDofs = reshape(1:nNod*3,3,nNod)';
nCohesivos = size(cohesivos.elements,1);
GP = 1/sqrt(3); %"nodal point", o sea la posicion del nodo!
upgC = [ -GP -GP
          GP -GP
          GP  GP
         -GP  GP ];
% Número de puntos nodales por elemento (4)
npgC = size(upgC,1);
% matrices
dNNodalMat = zeros(size(cohesivos.elements));

%calculo dN de los nodos de cada cohesivo
for iCohesivo=1:nCohesivos
    relatedEight    = cohesivos.related8Nodes(iCohesivo,:);

    % Orientamos el cohesivo
    Rot = cohesivos.T(:,:,iCohesivo);
    for iPg = 1:npgC

        ksi = upgC(iPg,1);
        eta = upgC(iPg,2);

        N4 = 0.25*(1 - ksi)*(1 + eta); N3 = 0.25*(1 + ksi)*(1 + eta); N2 = 0.25*(1 + ksi)*(1 - eta); N1 = 0.25*(1 - ksi)*(1 - eta);

        N = [N1 N2 N3 N4];

        Nint = [N(1) 0    0    N(2) 0    0    N(3) 0    0    N(4) 0    0   -N(1) 0    0   -N(2) 0    0   -N(3) 0    0   -N(4) 0    0
                0    N(1) 0    0    N(2) 0    0    N(3) 0    0    N(4) 0    0   -N(1) 0    0   -N(2) 0    0   -N(3) 0    0   -N(4) 0
                0    0    N(1) 0    0    N(2) 0    0    N(3) 0    0    N(4) 0    0   -N(1) 0    0   -N(2) 0    0   -N(3) 0    0   -N(4)];

        Nint = Nint(:, [13:24 1:12]);

        calculatedDs = Rot'*Nint*dITER(reshape(nodeDofs(relatedEight,:)',1,[])');

        cohesivos.dNCalculado(iCohesivo,iPg)  = calculatedDs(1);
        cohesivos.dS1Calculado(iCohesivo,iPg) = calculatedDs(2);
        cohesivos.dS2Calculado(iCohesivo,iPg) = calculatedDs(3);
    end
end