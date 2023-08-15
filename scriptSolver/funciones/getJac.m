function [Apg] = getJac(cohesivos,iCohesivo)      

nodosElemento = cohesivos.nodesEle(:,:,iCohesivo);

GP   = 1/sqrt(3);
upgC = [ -GP -GP
          GP -GP
          GP  GP
         -GP  GP ];


% Numero de puntos de Gauss
npgC = size(upgC,1);
wpgC = ones(npgC,1);
Apg    = zeros(1,4);
for iPg = 1:npgC    
    ksi = upgC(iPg,1);
    eta = upgC(iPg,2);
    
    N4 = 0.25*(1 - ksi)*(1 + eta); N3 = 0.25*(1 + ksi)*(1 + eta); N2 = 0.25*(1 + ksi)*(1 - eta); N1 = 0.25*(1 - ksi)*(1 - eta);
    
    N = [N1 N2 N3 N4];
    
    dNint = [ -0.25*(1 - eta),  0.25*(1 - eta), 0.25*(1 + eta), -0.25*(1 + eta)         % derivadas de ksi
              -0.25*(1 - ksi), -0.25*(1 + ksi), 0.25*(1 + ksi),  0.25*(1 - ksi) ];      % derivadas de eta
    jac    = dNint*nodosElemento;
    Apg(iPg) = det(jac)*wpgC(iPg); 
end
end