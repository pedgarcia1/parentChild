function N = shapefuns(ksi,eta,zeta)
% Funciones de forma
N = [ (1-ksi)*(1-eta)*(1+zeta)/8, (1-ksi)*(1-eta)*(1-zeta)/8, (1-ksi)*(1+eta)*(1-zeta)/8....
    (1-ksi)*(1+eta)*(1+zeta)/8, (1+ksi)*(1-eta)*(1+zeta)/8, (1+ksi)*(1-eta)*(1-zeta)/8....
    (1+ksi)*(1+eta)*(1-zeta)/8, (1+ksi)*(1+eta)*(1+zeta)/8 ];

N = N(1,[4,1,5,8,3,2,6,7]);
end