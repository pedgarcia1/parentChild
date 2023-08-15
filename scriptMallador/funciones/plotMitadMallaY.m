function plotMitadMallaY(nodes,elements,tol)
 menorzx1 = nodes(elements(:,1),2) <= max(nodes(:,2))/tol;
 menorzx2 = nodes(elements(:,2),2) <= max(nodes(:,2))/tol;
 menorzx3 = nodes(elements(:,3),2) <= max(nodes(:,2))/tol;
 menorzx4 = nodes(elements(:,4),2) <= max(nodes(:,2))/tol;
 menorzx5 = nodes(elements(:,5),2) <= max(nodes(:,2))/tol;
 menorzx6 = nodes(elements(:,6),2) <= max(nodes(:,2))/tol;
 menorzx7 = nodes(elements(:,7),2) <= max(nodes(:,2))/tol;
 menorzx8 = nodes(elements(:,8),2) <= max(nodes(:,2))/tol;
 
 
 condicionXo = double([menorzx1 menorzx2 menorzx3 menorzx4 menorzx5 menorzx6 menorzx7 menorzx8]);
 [logicX0, indexX0] = ismembertol(condicionXo,[1 1 1 1 1 1 1 1],'OutputAllIndices',true,'ByRows',true);
 
 index = logical(cell2mat(indexX0));
 
 figure
 plotMeshColo3D(nodes,elements(index,:),'w')
end