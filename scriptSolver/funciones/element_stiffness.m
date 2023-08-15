function [Ke] = element_stiffness(pGaussParam,paramDiscEle,nodesEle,constitutivas)

Ke = sparse(paramDiscEle.nDofEl,paramDiscEle.nDofEl);
    for ipg = 1:pGaussParam.npg
        % Punto de Gauss
        ksi = pGaussParam.upg(ipg,1);
        eta = pGaussParam.upg(ipg,2);  
        zeta = pGaussParam.upg(ipg,3);
        C = constitutivas(:,:,ipg);
        % Funciones de forma
%         N = [ (1-ksi)*(1-eta)*(1+zeta)/8, (1-ksi)*(1-eta)*(1-zeta)/8, (1-ksi)*(1+eta)*(1-zeta)/8.... 
%               (1-ksi)*(1+eta)*(1+zeta)/8, (1+ksi)*(1-eta)*(1+zeta)/8, (1+ksi)*(1-eta)*(1-zeta)/8....
%               (1+ksi)*(1+eta)*(1-zeta)/8, (1+ksi)*(1+eta)*(1+zeta)/8 ];
%           
%         N = N(1,[8,4,1,5,7,3,2,6]);   
        
        % Derivadas de las funciones de forma respecto de ksi, eta, zeta         
        dN = [ ((eta - 1)*(zeta + 1))/8, -((eta - 1)*(zeta - 1))/8, ((eta + 1)*(zeta - 1))/8, -((eta + 1)*(zeta + 1))/8, -((eta - 1)*(zeta + 1))/8, ((eta - 1)*(zeta - 1))/8, -((eta + 1)*(zeta - 1))/8, ((eta + 1)*(zeta + 1))/8
               ((ksi - 1)*(zeta + 1))/8, -((ksi - 1)*(zeta - 1))/8, ((ksi - 1)*(zeta - 1))/8, -((ksi - 1)*(zeta + 1))/8, -((ksi + 1)*(zeta + 1))/8, ((ksi + 1)*(zeta - 1))/8, -((ksi + 1)*(zeta - 1))/8, ((ksi + 1)*(zeta + 1))/8
               ((eta - 1)*(ksi - 1))/8,  -((eta - 1)*(ksi - 1))/8,  ((eta + 1)*(ksi - 1))/8,  -((eta + 1)*(ksi - 1))/8,  -((eta - 1)*(ksi + 1))/8,  ((eta - 1)*(ksi + 1))/8,  -((eta + 1)*(ksi + 1))/8,  ((eta + 1)*(ksi + 1))/8 ];
        
        dN = dN(:,[8,4,1,5,7,3,2,6]);

        jac = dN*nodesEle;                

        % Derivadas de las funciones de forma respecto de x,y,z
        dNxyz = jac\dN;          % dNxyz = inv(jac)*dN
        
        B = zeros(size(C,1),paramDiscEle.nDofEl);

        B(1,1:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(1,:);
        B(2,2:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(2,:); 
        B(3,3:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(3,:);
        B(4,1:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(2,:);
        B(4,2:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(1,:);
        B(5,2:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(3,:);
        B(5,3:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(2,:);
        B(6,1:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(3,:);
        B(6,3:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(1,:);
        
    
        Ke = Ke + B'*C*B*pGaussParam.wpg(ipg)*det(jac);             
    end


end

