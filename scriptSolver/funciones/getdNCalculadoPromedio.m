function [ dNCalculadoPromedio ] = getdNCalculadoPromedio(propantesVar,meshInfo)
nodosIntervinientes = unique(meshInfo.cohesivos.elements(propantesVar,:));
dNCalculadoPromedio = zeros(size(meshInfo.cohesivos.dNCalculado,1),size(meshInfo.cohesivos.dNCalculado,2));
for iNodo = nodosIntervinientes'
    if iNodo == 8448 % Despues borrar. Es para probar.
        F =1;
    end
    aux = 0;
    [ele,posNodo] = find(iNodo == meshInfo.cohesivos.elements);
    for j1 = 1:numel(ele)
        aux = aux + meshInfo.cohesivos.dNCalculado(ele(j1),posNodo(j1));
    end
    for j2 = 1:numel(ele)
        dNCalculadoPromedio(ele(j2),posNodo(j2)) = aux/j1;
    end
end
end
