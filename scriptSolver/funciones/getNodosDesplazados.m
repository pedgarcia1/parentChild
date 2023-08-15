function [ nodosDesplazados,aperturasNormal] = getNodosDesplazados(nodes,propantesVar,displacements,cohesivos,propanteProperties)

nodosDesplazados = cell(1,1);
aperturasNormal  = zeros(numel(propantesVar),4);
iEleProp = 0;

for iEleCohesivo = propantesVar'
    iEleProp = iEleProp+1;
    Rot = cohesivos.T(:,:,iEleCohesivo);
    nodesElemento_minus = nodes(cohesivos.related8Nodes(iEleCohesivo,1:4),:);
    nodesElemento_plus  = nodes(cohesivos.related8Nodes(iEleCohesivo,5:8),:);
    
    desplazamientosElemento_minus = displacements(cohesivos.related8Nodes(iEleCohesivo,1:4),:);
    desplazamientosElemento_plus  = displacements(cohesivos.related8Nodes(iEleCohesivo,5:8),:);
    
    desplazamientosElementoProyect_minus = desplazamientosElemento_minus*Rot*propanteProperties.hP;
    desplazamientosElementoProyect_minus = [desplazamientosElementoProyect_minus(:,1),zeros(4,2)];
    desplazamientosElementoMod_minus     = desplazamientosElementoProyect_minus*Rot';
   
    desplazamientosElementoProyect_plus = desplazamientosElemento_plus*Rot*propanteProperties.hP;
    desplazamientosElementoProyect_plus = [desplazamientosElementoProyect_plus(:,1),zeros(4,2)];
    desplazamientosElementoMod_plus     = desplazamientosElementoProyect_plus*Rot';
    
    aperturasNormal(iEleProp,:) = desplazamientosElementoProyect_plus(:,1)-desplazamientosElementoProyect_minus(:,1);
    if aperturasNormal(iEleProp) < 0
        error('aperturaNormal de propante seteada en valor < 0 en getNodosDesplazados')
    end
    
    nodosDesplazados{iEleProp} = [nodesElemento_minus + desplazamientosElementoMod_minus;nodesElemento_plus + desplazamientosElementoMod_plus]; 
    nodosDesplazados{iEleProp} = nodosDesplazados{iEleProp}([8 5 6 7 4 1 2 3],:); 
end
end

