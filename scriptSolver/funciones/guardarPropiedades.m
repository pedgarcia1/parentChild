function guardarPropiedades(archivo,nombreCorrida)
propiedadesTexto = copyText(archivo);
fid = fopen(['propiedades_',nombreCorrida,'.txt'],'w');
for iLine = 1:size(propiedadesTexto,1)
    fprintf(fid,[propiedadesTexto{iLine},'\n']);
end
fclose('all');
end

