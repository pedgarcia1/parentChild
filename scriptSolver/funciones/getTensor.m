function [ T ] = getTensor(meshInfo,paramDiscEle,pGaussParam,physicalProperties,Biot,Kperm,key)

if strcmpi(key,'C')
    [row,col,nodesEle] = getMapping(paramDiscEle.nDofEl,paramDiscEle.nel,paramDiscEle.nNodEl,paramDiscEle.nDofNod,paramDiscEle.nodeDofs,meshInfo.elements,meshInfo.nodes,'C');
    Ce = cell(paramDiscEle.nel,1);
    for iele = 1:paramDiscEle.nel
        Ce{iele}  =  presionPoral(paramDiscEle,pGaussParam,nodesEle(:,:,iele),Biot{iele});
    end
    C = sparse(vertcat(row{:}),vertcat(col{:}),vertcat(Ce{:}),paramDiscEle.nDofTot_U,paramDiscEle.nDofTot_P);
    T = C;
    
elseif strcmpi(key,'KC')
    [row,col,nodesEle] = getMapping(paramDiscEle.nDofEl,paramDiscEle.nel,paramDiscEle.nNodEl,paramDiscEle.nDofNod,paramDiscEle.nodeDofs,meshInfo.elements,meshInfo.nodes,'KC');
    KCe = cell(paramDiscEle.nel,1);
    for iele = 1:paramDiscEle.nel
        KCe{iele}  =  gradiente_poral(pGaussParam.npg,pGaussParam.upg,pGaussParam.wpg,nodesEle(:,:,iele),paramDiscEle.nNodEl,Kperm{iele});
    end
    KC = sparse(vertcat(row{:}),vertcat(col{:}),vertcat(KCe{:}),paramDiscEle.nDofTot_P,paramDiscEle.nDofTot_P);
    T = KC;
    
elseif strcmpi(key,'S')
    [row,col,nodesEle] = getMapping(paramDiscEle.nDofEl,paramDiscEle.nel,paramDiscEle.nNodEl,paramDiscEle.nDofNod,paramDiscEle.nodeDofs,meshInfo.elements,meshInfo.nodes,'S');
    Se = cell(paramDiscEle.nel,1);
    for iele = 1:paramDiscEle.nel
        Se{iele}   =   poral_temporal(pGaussParam.npg,pGaussParam.upg,pGaussParam.wpg,nodesEle(:,:,iele),paramDiscEle.nNodEl,physicalProperties.storativity.M);
    end
    S = sparse(vertcat(row{:}),vertcat(col{:}),vertcat(Se{:}),paramDiscEle.nDofTot_P,paramDiscEle.nDofTot_P);
    T = S;
end
end

