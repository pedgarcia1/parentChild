function [dofsC,dofsX,dofsCU,dofsCP,dofsAT,dofsNoLineales,dofsXNoLineales] = getDofs(isFixed,bc_poral,nCREqFluidos,nCREqFrac,nDofTotales,paramDiscEle,meshInfo)
% Dofs Conocidos.
% dofsC = [isFixed                         
%          bc_poral                         
%          false(nCREqFluidos,1)
%          false(nCREqFrac,1)
%          false(nCREqWinkler,1)];   

dofsC = [isFixed                         
         bc_poral                         
         false(nCREqFluidos,1)
         false(nCREqFrac,1)
         ];   

% Dofs Desconocidos.    
dofsX = ~dofsC;

% Dofs Conocidos de desplazamientos.
% dofsCU = [isFixed
%          false(size(bc_poral,1),1)
%          false(nCREqFluidos,1)
%          false(nCREqFrac,1)
%          false(nCREqWinkler,1)];
dofsCU = [isFixed
         false(size(bc_poral,1),1)
         false(nCREqFluidos,1)
         false(nCREqFrac,1)
         ];

% Dofs Conocidos de presiones.
% dofsCP = [false(size(isFixed,1),1)
%          bc_poral
%          false(nCREqFluidos,1)
%          false(nCREqFrac,1)
%          false(nCREqWinkler,1)] ;
dofsCP = [false(size(isFixed,1),1)
         bc_poral
         false(nCREqFluidos,1)
         false(nCREqFrac,1)
         ] ;
     

% Dofs de presiones. Incluyendo constraints fluidos.          
% dofsAT  = [ false(size(isFixed,1),1)
%             true(size(bc_poral))
%             true(nCREqFluidos,1)
%             false(nCREqFrac,1)
%             false(nCREqWinkler,1)] ;
dofsAT  = [ false(size(isFixed,1),1)
            true(size(bc_poral))
            true(nCREqFluidos,1)
            false(nCREqFrac,1)
            ] ;
        

dofsNoLinealesIndex = unique(paramDiscEle.nodeDofs(meshInfo.cohesivos.related8Nodes(:,:),:));
dofsNoLineales = false(nDofTotales,1);
dofsNoLineales(dofsNoLinealesIndex) = true;
dofsNoLineales = dofsNoLineales ;%| dofsPresion;
dofsLineales = ~dofsNoLineales;
dofsXLineales = dofsLineales & dofsX;
dofsXNoLineales = dofsNoLineales & dofsX;


end

