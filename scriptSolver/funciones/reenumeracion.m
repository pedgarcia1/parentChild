clear
load('PRUEBA_2_DFN_ANG_0.mat')
% H8
nEleH8 = size(elements,1);
for iEle = 1:nEleH8
    nodosElemento = nodes(elements(iEle,:),:);
    xProm = sum(nodosElemento(:,1))/4;
    yProm = sum(nodosElemento(:,2))/4;
    zProm = sum(nodosElemento(:,3))/4;
    
    nodo1         = [nodosElemento];
    
    
    
    
end