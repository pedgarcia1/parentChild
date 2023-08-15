function [ SRVProperties ] = setSRVProperties(key,key2,meshInfo,varargin)
% key: "change" "default" "test" "load"
%%
if strcmpi(key,'default')
    load('propanteProperties')
elseif strcmpi(key,'change')
else
    if strcmpi(key,'load')
        if nargin<4
            fprintf('---------------------------------------------------------\n');
            archivo = input('Ingrese nombre del archivo a correr: ');
            clc
        else
            archivo = varargin{1};
        end
    elseif strcmpi(key,'test')
        archivo = 'corridaVerificacion.txt';
    end
    m2mm = 1000;
    propiedades       = getProperties(archivo);
    SRVProperties.key = varName('SRVKey', propiedades);
    SRVProperties.dX  = varName('dX', propiedades)*m2mm;
    SRVProperties.dY  = varName('dY', propiedades)*m2mm;
    SRVProperties.dZ  = varName('dZ', propiedades)*m2mm;
    SRVProperties.elementsIndex = (1:size(meshInfo.elements,1))';
    mskElementosSRV   = false(1,size(meshInfo.elements,1));
    
    for iElement = 1:size(meshInfo.elements,1)
        nodos = meshInfo.nodes(meshInfo.elements(iElement,:),:);
        mskX = nodos(:,1) - SRVProperties.dX(1) >= 0 & nodos(:,1) - SRVProperties.dX(2) <= 0;
        mskY = nodos(:,2) - SRVProperties.dY(1) >= 0 & nodos(:,2) - SRVProperties.dY(2) <= 0;
        mskZ = nodos(:,3) - SRVProperties.dZ(1) >= 0 & nodos(:,3) - SRVProperties.dZ(2) <= 0;
        if  all(mskX & mskY & mskZ)
            mskElementosSRV(iElement) = true;
        end
    end
    SRVProperties.elementsIndex = SRVProperties.elementsIndex(mskElementosSRV);
    save('SRVProperties','SRVProperties')
    if strcmpi(key2,'Y')
%         plotMeshColo3D(meshInfo.nodes,meshInfo.elements,meshInfo.cohesivos.elements,'on','on','w','r','k',0.1)
        plotMeshColo3D(meshInfo.nodes,meshInfo.elements(SRVProperties.elementsIndex,:),meshInfo.cohesivos.elements,'on','on','b','r','k',0.1)
    end
end

fprintf('---------------------------------------------------------\n');
fprintf('Las <strong>propiedades del SRV</strong> a utilizar son: \n');
disp(SRVProperties);
end