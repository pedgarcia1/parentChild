function value = varName(varToFind,dataMatrix)
% varName es una funcion que sirve para encontrar el valor de una
% una variable en una matriz de datos según el nombre de la msima.
% 
% varToFind: nombre de la variable en CHAR
% dataMatrix: matriz de celdas tamaño Nx2
% los valores de dataMatrix salen de la función getProperties(archivo)

value = str2num(dataMatrix{strcmp(dataMatrix(:,1), varToFind), 2}); % num

if isempty(value)
    value = dataMatrix{strcmp(dataMatrix(:,1), varToFind), 2}; % char 
    if strcmp(value, '[]')
        value = [];
    end
end

end