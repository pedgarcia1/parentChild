function plotMitadMalla(nodes,elements,tol)

 menorzx1 = nodes(elements(:,1),3) <= max(nodes(:,3))/tol;
 menorzx2 = nodes(elements(:,2),3) <= max(nodes(:,3))/tol;
 menorzx3 = nodes(elements(:,3),3) <= max(nodes(:,3))/tol;
 menorzx4 = nodes(elements(:,4),3) <= max(nodes(:,3))/tol;
 menorzx5 = nodes(elements(:,5),3) <= max(nodes(:,3))/tol;
 menorzx6 = nodes(elements(:,6),3) <= max(nodes(:,3))/tol;
 menorzx7 = nodes(elements(:,7),3) <= max(nodes(:,3))/tol;
 menorzx8 = nodes(elements(:,8),3) <= max(nodes(:,3))/tol;
 
 
 condicionXo = double([menorzx1 menorzx2 menorzx3 menorzx4 menorzx5 menorzx6 menorzx7 menorzx8]);
 [logicX0, indexX0] = ismembertol(condicionXo,[1 1 1 1 1 1 1 1],'OutputAllIndices',true,'ByRows',true);
 
 index = logical(cell2mat(indexX0));
 
%  figure
 plotMeshColo3D(nodes,elements(index,:),'w')
end