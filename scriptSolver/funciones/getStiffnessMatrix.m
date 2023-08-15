function [K] = getStiffnessMatrix(paramDiscEle,pGaussParam,constitutivas,meshInfo)
[row,col,nodesEle]  = getMapping(paramDiscEle.nDofEl,paramDiscEle.nel,paramDiscEle.nNodEl,paramDiscEle.nDofNod,paramDiscEle.nodeDofs,meshInfo.elements,meshInfo.nodes,'H8');
Ke = cell(paramDiscEle.nel,1);
for iele = 1:paramDiscEle.nel
    Ke{iele} = element_stiffness(pGaussParam,paramDiscEle,nodesEle(:,:,iele),constitutivas{iele});
end
K  = sparse(vertcat(row{:}),vertcat(col{:}),vertcat(Ke{:}),paramDiscEle.nDofTot_U,paramDiscEle.nDofTot_U);
end