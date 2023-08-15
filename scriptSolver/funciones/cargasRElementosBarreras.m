R = sparse(paramDiscEle.nDofTot_U,1);
initialStressSolPG = cell(paramDiscEle.nel,1);
for iEle = 1:paramDiscEle.nel
    nodesEle    = meshInfo.elements(iEle,:);
    nodesPosEle = meshInfo.nodes(meshInfo.elements(iEle,:),:);
    nodalDofs   = reshape(paramDiscEle.nodeDofs(nodesEle',:)',1,24)';
    Re          = zeros(paramDiscEle.nDofEl,1);
    BiotE       = Biot{iEle};
    
    if any(iEle == meshInfo.elementsBarreras.index)
        initialSressExtPG = initialSressExtL;
    else
        initialSressExtPG = initialSressExtS;
    end
    
    for ipg = 1:pGaussParam.npg
        % Punto de Gauss
        ksi = pGaussParam.upg(ipg,1);
        eta = pGaussParam.upg(ipg,2);
        zeta = pGaussParam.upg(ipg,3);
       
        
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
        
        jac = dN*nodesPosEle;
%         jac = [jac(2,1) 0 0; 0 jac(3,2) 0; 0 0 jac(1,3)]; %BORRAR
        
        % Derivadas de las funciones de forma respecto de x,y,z
        dNxyz = jac\dN;          % dNxyz = inv(jac)*dN
        
        B = zeros(6,paramDiscEle.nDofEl);
        
        B(1,1:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(1,:);
        B(2,2:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(2,:);
        B(3,3:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(3,:);
        B(4,1:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(2,:);
        B(4,2:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(1,:);
        B(5,2:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(3,:);
        B(5,3:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(2,:);
        B(6,1:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(3,:);
        B(6,3:paramDiscEle.nDofNod:paramDiscEle.nDofEl) = dNxyz(1,:);
       
        initialStressSolPG{iEle}(:,ipg) = initialSressExtPG + BiotE(:,:,ipg)*initialPPoral;

        Re = Re - B'*initialStressSolPG{iEle}(:,ipg)*pGaussParam.wpg(ipg)*det(jac);        
    end
    R(nodalDofs) = R(nodalDofs) + Re;
end

