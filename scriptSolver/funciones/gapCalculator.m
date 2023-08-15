function [ cohesivos ] = gapCalculator(iCohesivos,nodes ,cohesivos, dPrevITER, dPrevTime)
        nNod            = size(nodes,1);
        nodeDofs        = reshape(1:nNod*3,3,nNod)';
        relatedEight    = cohesivos.related8Nodes(iCohesivos,:);
        
        % Orientamos el cohesivo
        Rot = cohesivos.T(:,:,iCohesivos);
        GP = 1/sqrt(3);
        upgC = [ -GP -GP
                  GP -GP
                  GP  GP
                 -GP  GP ];
        % N�mero de puntos de Gauss
        npgC = size(upgC,1);
        for iPg = 1:npgC
            
            ksi = upgC(iPg,1);
            eta = upgC(iPg,2);
   
            N4 = 0.25*(1 - ksi)*(1 + eta); N3 = 0.25*(1 + ksi)*(1 + eta); N2 = 0.25*(1 + ksi)*(1 - eta); N1 = 0.25*(1 - ksi)*(1 - eta);
            
            N = [N1 N2 N3 N4];
            
            Nint = [N(1) 0    0    N(2) 0    0    N(3) 0    0    N(4) 0    0   -N(1) 0    0   -N(2) 0    0   -N(3) 0    0   -N(4) 0    0
                    0    N(1) 0    0    N(2) 0    0    N(3) 0    0    N(4) 0    0   -N(1) 0    0   -N(2) 0    0   -N(3) 0    0   -N(4) 0
                    0    0    N(1) 0    0    N(2) 0    0    N(3) 0    0    N(4) 0    0   -N(1) 0    0   -N(2) 0    0   -N(3) 0    0   -N(4)];
            
            Nint = Nint(:, [13:24 1:12]);
            
            calculatedDsPrev = Rot'*Nint*dPrevTime(reshape(nodeDofs(relatedEight,:)',1,[])');
            calculatedDs = Rot'*Nint*dPrevITER(reshape(nodeDofs(relatedEight,:)',1,[])');
            
            cohesivos.dNCalculado(iCohesivos,iPg) = calculatedDs(1);
            cohesivos.dS1Calculado(iCohesivos,iPg) = calculatedDs(2);
            cohesivos.dS2Calculado(iCohesivos,iPg) = calculatedDs(3);
            
            
            dNipgPrev = calculatedDsPrev(1);
            dS1ipgPrev = calculatedDsPrev(2);
            dS2ipgPrev = calculatedDsPrev(3);
 
            cohesivos.dNCalculadoPrev(iCohesivos,iPg)   = dNipgPrev;
            cohesivos.dS1CalculadoPrev(iCohesivos,iPg)  = dS1ipgPrev;
            cohesivos.dS2CalculadoPrev(iCohesivos,iPg)  = dS2ipgPrev;       
        end
end