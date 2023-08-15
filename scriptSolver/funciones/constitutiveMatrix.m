function [ C ] = constitutiveMatrix( Ev,Eh,NUv,NUh)
% constitutiveMatrix es una funcion que sirve para determinar la matriz
% consitutiva de un elemento 3D de material orthotropo en Z.
%%
% Elementos de la matriz.
A_10    = Eh/((1 + NUh)*((Eh/Ev)*(1 - NUh) - (2*NUv^2)));
A11_10  = A_10*((Eh/Ev) - NUv^2);
A22_10  = A11_10;
A12_10  = A_10*((Eh/Ev)*NUh + NUv^2);
A21_10  = A12_10;
A13_10  = A_10*NUv*(1 + NUh);
A23_10  = A13_10;
A31_10  = A13_10;
A32_10  = A13_10;
A33_10  = A_10*(1 - NUh^2);
Gv_10   = Ev/(2*(1 + NUv));
Gh_10   = Eh/(2*(1 + NUh));

% Matriz expresada de forma full.
% C = [   A11_10 A12_10 A13_10 0      0      0
%         A21_10 A22_10 A23_10 0      0      0
%         A31_10 A32_10 A33_10 0      0      0
%         0      0      0      Gv_10  0      0
%         0      0      0      0      Gv_10  0
%         0      0      0      0      0      Gh_10];
%
% Matriz expresada de forma esparsa.
C = sparse([1 2 3 1 2 3 1 2 3 4 5 6]',[1 1 1 2 2 2 3 3 3 4 5 6]',[A11_10 A21_10 A31_10 A12_10 A22_10 A32_10 A13_10 A23_10 A33_10 Gv_10 Gv_10 Gh_10]');    

end

