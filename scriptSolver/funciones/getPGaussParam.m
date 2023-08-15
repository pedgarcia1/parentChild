function [ pGaussParam ] = getPGaussParam(  )
% getPGasussParam es una funcion que sirve para obtener la ubicacion de los
% puntos de gauss con sus respectivos pesos, que seran utilizados mas 
% adelante para la integracion de distintas funciones.
%%
GP   = 1/sqrt(3);
pGaussParam.upg = [  GP   GP   GP
                    -GP   GP   GP
                    -GP  -GP   GP 
                     GP  -GP   GP  
                     GP   GP  -GP
                    -GP   GP  -GP
                    -GP  -GP  -GP 
                     GP  -GP  -GP ]; 

pGaussParam.npg = size(pGaussParam.upg,1);
pGaussParam.wpg = ones(pGaussParam.npg,1);
pGaussParam.rsInt = 2*ones(1,2);


end

