pos = [90000      120000      170000
           0      120000       70000
       90000      120000       70000
           0      120000      170000];

tol = 1;       
msk = (meshInfo.nodes(:,1)-90000 <= 0 & meshInfo.nodes(:,1)-0 >= 0) & (abs(meshInfo.nodes(:,2)-120000) == 0) & (meshInfo.nodes(:,3)-170000 == 0 | meshInfo.nodes(:,3)-70000 == 0);
msk = msk + (meshInfo.nodes(:,1)-90000 == 0 ) & (abs(meshInfo.nodes(:,2)-120000) == 0) & (meshInfo.nodes(:,3)-170000 <= 0 & meshInfo.nodes(:,3)-70000 >= 0);
nodos = find(msk);