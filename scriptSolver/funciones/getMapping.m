function [row,col,nodesEle] = getMapping( nDofEl,nel,nNodEl,nDofNod,nodeDofs,elements,nodes,key )

nodesEle = zeros(nNodEl,nDofNod,nel);

if strcmpi(key,'C')
    col = cell(nel,1);
    row = cell(nel,1);
    for iele = 1:nel
        col{iele} = repmat(elements(iele,:)',1,nDofEl)';
        row{iele} = repmat(reshape(nodeDofs(elements(iele,:),:)',1,[])',1,nNodEl);
        nodesEle(:,:,iele)= nodes(elements(iele,:),:);
    end
elseif strcmpi(key,'KC')||strcmpi(key,'S')
    col = cell(nel,1);
    row = cell(nel,1);
    for iele = 1:nel
        col{iele} = repmat(elements(iele,:)',1,nNodEl);
        row{iele} = col{iele}';
        nodesEle(:,:,iele)= nodes(elements(iele,:),:);
    end
elseif strcmpi(key,'Kw')||strcmpi(key,'H8')||strcmpi(key,'Kch')
    col = cell(nel,1);
    row = cell(nel,1);
    for iele=1:nel                                                                   % acomoda los 24 dofs que tiene cada elemento. tomando primero los nodos del elemento y despues lso dofs de cada nodo.
        col{iele} = repmat(reshape(nodeDofs(elements(iele,:),:)',1,[])',1,nDofEl);   % fila, columna, elemento. Hace una matriz donde coloca en columna  los 24 dofs de cada elemento 24 veces.
        row{iele} = col{iele}';
        nodesEle(:,:,iele)= nodes(elements(iele,:),:);                               % posiciones X Y Z de los nodos de cada elemento.
    end
end
end




