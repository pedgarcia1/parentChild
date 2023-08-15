function dNNodalITER = gapCalculator3(nodes,cohesivos,dITER)
%Calcula dNNodal para cada cohesivo. Por lo tanto, para los cohesivos que
%comparten nodos, van a haber valores repetidos. No es lo más eficiente,
%pero anda.
nNod     = size(nodes,1);
nodeDofs = reshape(1:nNod*3,3,nNod)';
nCohesivos = size(cohesivos.elements,1);
NP = 1; %"nodal point", o sea la posicion del nodo!
upgC = [ -NP -NP
          NP -NP
          NP  NP
         -NP  NP ];
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

        dNNodalMat(iCohesivo,iPg)  = calculatedDs(1);
        %dS1Nodal(iCohesivo,iPg) = calculatedDs(2);
        %dS2Nodal(iCohesivo,iPg) = calculatedDs(3);
    end
end

%reordeno los dN en un vector de valores por nodo. Promedio los duplicados
%(que de todas formas valen lo mismo).
auxIdx=unique(cohesivos.elements);
dNNodalITER = zeros(size(auxIdx));
i=1;
for iNode=auxIdx' %para todos los nodos que tengo que mirar
    pos = find(cohesivos.elements==iNode); %busco su posicion en la matriz cohesivos.elements, que es la misma que su posicion en dNNodalMat y dNNodalPrevMat
    dNNodalITER(i) = mean(dNNodalMat(pos)); %promedio los valores (que pueden ser 1, 2 o 4) que tengo para ese nodo, y los guardo en un vector.
    i=i+1;
end