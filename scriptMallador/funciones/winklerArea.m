function [areas] = winklerArea(nodes,elements,loadedNodes,dir)
nel = size(elements,1);
loadedNodes = find(loadedNodes);
nodeNums = [1 2 3 4 5 6 7 8];
rsInt = 2*ones(1,2);
[wpg,~ , npg] = gauss(rsInt);
nNod        = size(nodes,1);
nDofTot_U   = nNod*3;

A = cell(3,1);
iNodGlob = 0;
areas = zeros(nNod,1);
for iele = 1:nel
    nodesEle = nodes(elements(iele,:),:);
    nodosInEle    = elements(iele,:)';
    nodosInFace   = ismember(nodosInEle,loadedNodes);
    area = 0;
    activeNodes = nodeNums(nodosInFace);
    
    if nnz(nodosInFace)>3
        for iNod = 1:size(activeNodes,2)
            Re = zeros(3,1);
            for ipg = 1:npg
                [ksi, eta, zeta] = faceDetect3D(rsInt(1), nodosInFace,ipg);
                
                N = [ (1-ksi)*(1-eta)*(1+zeta)/8, (1-ksi)*(1-eta)*(1-zeta)/8, (1-ksi)*(1+eta)*(1-zeta)/8....
                    (1-ksi)*(1+eta)*(1+zeta)/8, (1+ksi)*(1-eta)*(1+zeta)/8, (1+ksi)*(1-eta)*(1-zeta)/8....
                    (1+ksi)*(1+eta)*(1-zeta)/8, (1+ksi)*(1+eta)*(1+zeta)/8 ];
                
                N = N(1,[8,4,1,5,7,3,2,6]);
                
                % Derivadas de las funciones de forma respecto de ksi, eta, zeta
                dN = [ ((eta - 1)*(zeta + 1))/8, -((eta - 1)*(zeta - 1))/8, ((eta + 1)*(zeta - 1))/8, -((eta + 1)*(zeta + 1))/8, -((eta - 1)*(zeta + 1))/8, ((eta - 1)*(zeta - 1))/8, -((eta + 1)*(zeta - 1))/8, ((eta + 1)*(zeta + 1))/8
                    ((ksi - 1)*(zeta + 1))/8, -((ksi - 1)*(zeta - 1))/8, ((ksi - 1)*(zeta - 1))/8, -((ksi - 1)*(zeta + 1))/8, -((ksi + 1)*(zeta + 1))/8, ((ksi + 1)*(zeta - 1))/8, -((ksi + 1)*(zeta - 1))/8, ((ksi + 1)*(zeta + 1))/8
                    ((eta - 1)*(ksi - 1))/8,  -((eta - 1)*(ksi - 1))/8,  ((eta + 1)*(ksi - 1))/8,  -((eta + 1)*(ksi - 1))/8,  -((eta - 1)*(ksi + 1))/8,  ((eta - 1)*(ksi + 1))/8,  -((eta + 1)*(ksi + 1))/8,  ((eta + 1)*(ksi + 1))/8 ];
                
                dN = dN(:,[8,4,1,5,7,3,2,6]);
                jac = dN*nodesEle;
                
                Nvec = N(nodosInFace);
                area = det(jac) + area;
                
                loadJac = surfaceJac([ksi eta zeta],jac);
                
                Re = Re + Nvec(iNod)*loadJac*[-1;0;0]*wpg(ipg);        
            end
            
            nodosInFaceGlobal = nodosInEle(nodosInFace);
            nodoGlobal = nodosInFaceGlobal(iNod);
            
            if dir == 1
                areas(nodoGlobal) = abs(Re(1)) + areas(nodoGlobal);
            else if dir == 2
                    areas(nodoGlobal) = abs(Re(2)) + areas(nodoGlobal);
                else
                    areas(nodoGlobal) = abs(Re(3)) + areas(nodoGlobal);
                end
            end
            
            
%             columna = 1;
%             eleDofs = nodeDofs(elements(iele,activeNodes(iNod)),:)';
%             I = repmat(eleDofs,1,size(columna,1));
%             J = repmat(columna',size(eleDofs,1),1);
%             iNodGlob = iNodGlob + 1;
%             A{1}{iNodGlob}=I;
%             A{2}{iNodGlob}=J;
%             A{3}{iNodGlob}=Re;
        end
    end

end
% Ensamble
% 
% I = vertcat(A{1,1}{:});
% J = vertcat(A{2,1}{:});
% S = vertcat(A{3,1}{:});
% R = sparse(I,J,S,nDofTot_U,1);

end
