function [ nodosDesplazados,aperturasNormal] = getNodosDesplazados2(nodes,propantesVar,cohesivos,propanteProperties,dN)

nodosDesplazados = cell(1,1);
aperturasNormal  = zeros(numel(propantesVar),4);
iEleProp = 0;

for iEleCohesivo = propantesVar'
    iEleProp = iEleProp+1;
    Rot = cohesivos.T(:,:,iEleCohesivo);
    nodesElemento_minus = nodes(cohesivos.related8Nodes(iEleCohesivo,1:4),:);
    nodesElemento_plus  = nodes(cohesivos.related8Nodes(iEleCohesivo,5:8),:);
    
    
    aperturasNormalElemento     = dN(iEleCohesivo,:)*propanteProperties.hP;
    aperturasNormalElemento(aperturasNormalElemento<0) = 0;
    aperturasNormal(iEleProp,:) = aperturasNormalElemento;
    
    desplazamientosElementoProyect_minus = [-aperturasNormalElemento'/2,zeros(4,2)];
    desplazamientosElementoMod_minus     = desplazamientosElementoProyect_minus*Rot';
    
    
    desplazamientosElementoProyect_plus =  [aperturasNormalElemento'/2,zeros(4,2)];
    desplazamientosElementoMod_plus     = desplazamientosElementoProyect_plus*Rot';
        
    nodosDesplazados{iEleProp} = [nodesElemento_minus + desplazamientosElementoMod_minus;nodesElemento_plus + desplazamientosElementoMod_plus]; 
%     nodosDesplazados{iEleProp} = nodosDesplazados{iEleProp}([8 5 6 7 4 1 2 3],:); 
    nodosDesplazados{iEleProp} = nodosDesplazados{iEleProp}([8 4 1 5 7 3 2 6],:); 
end
end

