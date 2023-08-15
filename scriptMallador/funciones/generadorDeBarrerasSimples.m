function [nodesNew] = generadorDeBarrerasSimples(posBarrera1,espesorBarrera1,fractura,stringFractura,cohesivos,nodes,elements,tol,debugPlots)

    % Extraer las coordenadas Z de los nodos
    X = nodes(:,1);
    Y = nodes(:,2);
    Z = nodes(:, 3);
    
    % Chequeo si la barrrera coincide con el borde de un elementos
    if any(posBarrera1 == Z)
        posBarrera1 = 1.05*posBarrera1;
        [nodesNew] = generadorDeBarrerasSimples(posBarrera1,espesorBarrera1,fractura,stringFractura,cohesivos,nodes,elements,tol,debugPlots);
    end
    
    % Chequear si la barrera esta en el borde de la fractura
%     elementosBorde = ismember(
%     if ismember(posBarrera1,max(max(Z(cohesivos.elements))))
%         posBarrera1 = posBarrera1 - 0.05*posBarrera1;
    
    % Dimensiones de la fractura (cohesivos)
    posXFractura = eval(sprintf('fractura.%s.posXFractura',stringFractura));
    posYFractura = sort(eval(sprintf('fractura.%s.posYFractura',stringFractura)));
    
    % Encontrar el nodo más cercano por encima de la barrera
    nodosArriba = find(Z > posBarrera1);
    [~, indiceArriba] = min(Z(nodosArriba));
    nodoArriba = nodes(nodosArriba(indiceArriba), :);
    
    % Encontrar el nodo más cercano por debajo de la barrera
    nodosAbajo = find(Z < posBarrera1);
    [~, indiceAbajo] = max(Z(nodosAbajo));
    nodoAbajo = nodes(nodosAbajo(indiceAbajo), :);

    % Encontrar todos los nodos en la fractura con por debajo y por encima
    % de la barrera
    logAbajo = (ismembertol(Z,nodoAbajo(3),tol) & ismembertol(X,posXFractura,tol) & Y <= posYFractura(2) & Y >= posYFractura(1) );
    logArriba = (ismembertol(Z,nodoArriba(3),tol) & ismembertol(X,posXFractura,tol) & Y <= posYFractura(2) & Y >= posYFractura(1)  );

    % Calculo dimensiones actuales
    espesorInicial = (nodoArriba(3)-nodoAbajo(3));
    deltaArriba = nodoArriba(3) -posBarrera1;
    deltaAbajo = abs(nodoAbajo(3) - posBarrera1);
    
    % Desplazamiento de los nodos
    nodes(logArriba,3) = nodes(logArriba,3) - (deltaArriba - espesorBarrera1/2);
    nodes(logAbajo,3) = nodes(logAbajo,3) + (deltaAbajo - espesorBarrera1/2);

    % Salida 
    nodesNew = nodes;
end

