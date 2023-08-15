function [ textoMod ] = getProperties( archivo )
texto = fopen(archivo,'r');
i = 1;
while ~feof(texto)
    lectura = fgetl(texto);
    if isempty(lectura)
    elseif strcmpi(lectura(1),'-')
    else
        textoMod{i,1} = lectura;
        i = i+1;
    end
end

for j = 1:i-1
    aux = strsplit(textoMod{j},' = ');
    textoMod(j, [1 2]) = aux;
end
fclose('all');
end

