function [ kElCohesivo, kTanElCohesivo ,Kn, KsKsi , KsEta, dD,cohesivos,cElCohesivo ] = interfaceElements3D(iCohesivos,nodes , nDofEl ,cohesivos,iTime,dPrevITER,dPrevTime,cohesivosProperties)
        
        nNod         = size(nodes,1);
        nodeDofs     = reshape(1:nNod*3,3,nNod)';
        relatedEight = cohesivos.related8Nodes(iCohesivos,:);
        
        % Orientamos el cohesivo

        Rot = cohesivos.T(:,:,iCohesivos);
%         nodosElemento = cohesivos.nodesEle(:,:,iCohesivos);
        nodosElemento = transpose(Rot'*nodes(cohesivos.elements(iCohesivos,:),:)');
        nodosElemento = nodosElemento(:,~all(abs(diff(nodosElemento))< 1));

        GP = 1/sqrt(3);
        upgC = [ -GP -GP
                  GP -GP
                  GP  GP
                 -GP  GP ];


        % Numero de puntos de Gauss
        npgC = size(upgC,1);
        wpgC = ones(npgC,1);

        kTanElCohesivoE = cell(npgC,1);
        kElCohesivoE    = cell(npgC,1);
        cElCohesivoE    = cell(npgC,1);

        for iPg = 1:npgC
            
            ksi = upgC(iPg,1);
            eta = upgC(iPg,2);
   
            N4 = 0.25*(1 - ksi)*(1 + eta); N3 = 0.25*(1 + ksi)*(1 + eta); N2 = 0.25*(1 + ksi)*(1 - eta); N1 = 0.25*(1 - ksi)*(1 - eta);
            
            N = [N1 N2 N3 N4];

            dNint = [ -0.25*(1 - eta),  0.25*(1 - eta), 0.25*(1 + eta), -0.25*(1 + eta)         % derivadas de ksi
                      -0.25*(1 - ksi), -0.25*(1 + ksi), 0.25*(1 + ksi),  0.25*(1 - ksi) ];      % derivadas de eta
            
            jac = dNint*nodosElemento;
            if det(jac)<0
                error('Determinante de jacobiano < 0 en interfaceElements3D')
            end
            
            Nint = [N(1) 0    0    N(2) 0    0    N(3) 0    0    N(4) 0    0   -N(1) 0    0   -N(2) 0    0   -N(3) 0    0   -N(4) 0    0
                    0    N(1) 0    0    N(2) 0    0    N(3) 0    0    N(4) 0    0   -N(1) 0    0   -N(2) 0    0   -N(3) 0    0   -N(4) 0
                    0    0    N(1) 0    0    N(2) 0    0    N(3) 0    0    N(4) 0    0   -N(1) 0    0   -N(2) 0    0   -N(3) 0    0   -N(4)];
            
            Nint = Nint(:, [13:24 1:12]);
            
            calculatedDsPrev = Rot'*Nint*dPrevTime(reshape(nodeDofs(relatedEight,:)',1,[])');
            calculatedDs     = Rot'*Nint*dPrevITER(reshape(nodeDofs(relatedEight,:)',1,[])');
            
            cohesivos.dNCalculado(iCohesivos,iPg)  = calculatedDs(1);
            cohesivos.dS1Calculado(iCohesivos,iPg) = calculatedDs(2);
            cohesivos.dS2Calculado(iCohesivos,iPg) = calculatedDs(3);
            
            dNipg  = cohesivos.dNCalculado(iCohesivos,iPg); 
            dS1ipg = cohesivos.dS1Calculado(iCohesivos,iPg);
            dS2ipg = cohesivos.dS2Calculado(iCohesivos,iPg);
            
            dNipgPrev  = calculatedDsPrev(1);
            dS1ipgPrev = calculatedDsPrev(2);
            dS2ipgPrev = calculatedDsPrev(3);
            
            if cohesivos.produccionFlag == true && cohesivos.deadFlag(iCohesivos,iPg) == 1
                dNipg = dNipg - cohesivos.propanteGap;
            end
           
     
            [Kn,cohesivos,dTN_dN,dTN_dSksi, dTN_dSeta]      = linearKnCohesivos(cohesivos,dNipg,dNipgPrev,dS1ipg,iCohesivos,iPg,iTime);
            [KsKsi,cohesivos,dTS1_dN,dTS1_dSksi,dTS1_dSeta] = linearKs1Cohesivos(cohesivos,dS1ipg,dS1ipgPrev,dNipg,iCohesivos,iPg,iTime);
            [KsEta,cohesivos,dTS2_dN,dTS2_dSksi,dTS2_dSeta] = linearKs2Cohesivos(cohesivos,dS2ipg,dS2ipgPrev,dNipg,iCohesivos,iPg,iTime);
            
            cohesivos.dNCalculadoPrev(iCohesivos,iPg)  = dNipgPrev;
            cohesivos.dS1CalculadoPrev(iCohesivos,iPg) = dS1ipgPrev;
            cohesivos.dS2CalculadoPrev(iCohesivos,iPg) = dS2ipgPrev;
            
            D = [Kn     0       0
                 0      KsKsi   0   
                 0      0       KsEta];

            dD = [dTN_dN    dTN_dSksi   dTN_dSeta
                  dTS1_dN   dTS1_dSksi  dTS1_dSeta 
                  dTS2_dN   dTS2_dSksi  dTS2_dSeta];

            assert(det(jac)>0)
            kElCohesivoE{iPg} = Nint'*Rot*D*Rot'*Nint*wpgC(iPg)*det(jac);
            cElCohesivoE{iPg} = Nint'*Rot*cohesivos.biot(iCohesivos,iPg) *[1;0;0]*N*wpgC(iPg)*det(jac); 
            kTanElCohesivoE{iPg} = Nint'*Rot*dD*Rot'*Nint*wpgC(iPg)*det(jac);
            
        end
        row = repmat(1:nDofEl,nDofEl,1);
        col = row';
        kElCohesivo = sparse(repmat(col,npgC,1),repmat(row,npgC,1),vertcat(kElCohesivoE{:}));
        kTanElCohesivo = sparse(repmat(col,npgC,1),repmat(row,npgC,1),vertcat(kTanElCohesivoE{:}));
        cElCohesivo = sparse(repmat(col(:,1:4),npgC,1),repmat(row(:,1:4),npgC,1),vertcat(cElCohesivoE{:}));
end