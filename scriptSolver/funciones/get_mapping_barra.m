function [row, col] = get_mapping_barra(nel,nodeDofs,elements,ndofel)

eleDofs = zeros(ndofel,nel);
row=zeros(ndofel,ndofel,nel);

for iele = 1:nel 
    eleDofs(:,iele) = reshape(nodeDofs(elements(iele,:),:)',1,[])';
end


for i=1:ndofel
    for j=1:nel
    row(:,i,j)=eleDofs(:,j)';    
    end
end

col=zeros(ndofel,ndofel,nel);

for j =1:nel
    col(:,:,j)=row(:,:,j);
    row(:,:,j)=row(:,:,j)';
end


end

