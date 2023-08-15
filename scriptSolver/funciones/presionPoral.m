function Celemento = presionPoral(paramDiscEle,pGaussParam,nodesEle,Biot)

Celemento = sparse(paramDiscEle.nDofNod*paramDiscEle.nNodEl,paramDiscEle.nNodEl); 
    
    for ipg = 1:pGaussParam.npg
        % Punto de Gauss
        ksi = pGaussParam.upg(ipg,1);
        eta = pGaussParam.upg(ipg,2);  
        zeta = pGaussParam.upg(ipg,3);

%         Funciones de forma
        N = [ (1-ksi)*(1-eta)*(1+zeta)/8, (1-ksi)*(1-eta)*(1-zeta)/8, (1-ksi)*(1+eta)*(1-zeta)/8.... 
              (1-ksi)*(1+eta)*(1+zeta)/8, (1+ksi)*(1-eta)*(1+zeta)/8, (1+ksi)*(1-eta)*(1-zeta)/8....
              (1+ksi)*(1+eta)*(1-zeta)/8, (1+ksi)*(1+eta)*(1+zeta)/8 ];
%           
        N = N(1,[8,4,1,5,7,3,2,6]);   
        
        % Derivadas de las funciones de forma respecto de ksi, eta, zeta         
        dN = [ ((eta - 1)*(zeta + 1))/8, -((eta - 1)*(zeta - 1))/8, ((eta + 1)*(zeta - 1))/8, -((eta + 1)*(zeta + 1))/8, -((eta - 1)*(zeta + 1))/8, ((eta - 1)*(zeta - 1))/8, -((eta + 1)*(zeta - 1))/8, ((eta + 1)*(zeta + 1))/8
               ((ksi - 1)*(zeta + 1))/8, -((ksi - 1)*(zeta - 1))/8, ((ksi - 1)*(zeta - 1))/8, -((ksi - 1)*(zeta + 1))/8, -((ksi + 1)*(zeta + 1))/8, ((ksi + 1)*(zeta - 1))/8, -((ksi + 1)*(zeta - 1))/8, ((ksi + 1)*(zeta + 1))/8
               ((eta - 1)*(ksi - 1))/8,  -((eta - 1)*(ksi - 1))/8,  ((eta + 1)*(ksi - 1))/8,  -((eta + 1)*(ksi - 1))/8,  -((eta - 1)*(ksi + 1))/8,  ((eta - 1)*(ksi + 1))/8,  -((eta + 1)*(ksi + 1))/8,  ((eta + 1)*(ksi + 1))/8 ];
        
        dN = dN(:,[8,4,1,5,7,3,2,6]);

        jac = dN*nodesEle;                

        % Derivadas de las funciones de forma respecto de x,y,z
        dNxyz = jac\dN;          % dNxyz = inv(jac)*dN
        
        B = zeros(6,24); 

        B(1,1:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(1,:);
        B(2,2:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(2,:); 
        B(3,3:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(3,:);
        B(4,1:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(2,:);
        B(4,2:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(1,:);
        B(5,2:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(3,:);
        B(5,3:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(2,:);
        B(6,1:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(3,:);
        B(6,3:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(1,:);

        Celemento = Celemento + B'*Biot(:,:,ipg)*pGaussParam.wpg(ipg)*N*det(jac);
%         Celemento = Celemento + B'*Biot(:,:,1)*pGaussParam.wpg(ipg)*N*det(jac);  % Caso tshape original.         
    end
    
end

