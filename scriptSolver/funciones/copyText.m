function [ textoMod ] = copyText( archivo )
texto = fopen(archivo,'r');
i = 1;
while ~feof(texto)
    lectura = fgetl(texto);
    textoMod{i,1} = lectura;
    i = i+1;
end
fclose('all');
end
