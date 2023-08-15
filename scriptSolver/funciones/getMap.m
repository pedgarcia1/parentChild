function [ row,col] = getMap(masterDofs )
row = cell(size(masterDofs,2),1);
col = cell(size(masterDofs,2),1);
for i = 1:size(masterDofs,2)
    row{i} = repmat(masterDofs(:,i),1,4);
    col{i} = row{i}';
end

