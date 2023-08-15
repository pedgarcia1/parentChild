function [I] = getOrientedStress(tita_x,tita_y,tita_z,ShMin,Sv,ShMax)
% Disposicion de partida: Se parte de una condicion en la que se supone
% alineado el eje x con ShMin, el eje y con Sv y eje z con ShMax.
% tita_i corresponde al angulo en grados que gira respecto al eje "i".

% Matriz de giro respecto al eje x.
Qx = [1               0                0
      0     cosd(tita_x)     -sind(tita_x)
      0     sind(tita_x)      cosd(tita_x)];

% Matriz de giro respecto al eje y.
Qy = [cosd(tita_y)    0    sind(tita_y)
                0    1              0
     -sind(tita_y)    0    cosd(tita_y)];
 
% Matriz de giro respecto al eje z.
Qz = [cosd(tita_z)   -sind(tita_z)    0 
      sind(tita_z)    cosd(tita_z)    0
      0                        0    1];

v1 = Qx*Qy*Qz*[1 0 0]';
v2 = Qx*Qy*Qz*[0 1 0]';
v3 = Qx*Qy*Qz*[0 0 1]';

l1 = v1(1); m1 = v1(2); n1 = v1(3);
l2 = v2(1); m2 = v2(2); n2 = v2(3);
l3 = v3(1); m3 = v3(2); n3 = v3(3);


% No incluye los cortes porque parte de un sistema alineado con las
% direcciones principales.

S1 = ShMin*l1^2 + Sv*m1^2 + ShMax*n1^2;
t12 = ShMin*l1*l2 + Sv*m1*m2 + ShMax*n1*n2;
t13 = ShMin*l1*l3 + Sv*m1*m3 + ShMax*n1*n3;

S3 = ShMin*l3^2 + Sv*m3^2 + ShMax*n3^2;
t31 = t13;
t32 = ShMin*l3*l2 + Sv*m3*m2 + ShMax*n3*n2;

S2 = ShMin*l2^2 + Sv*m2^2 + ShMax*n2^2;
t21 = t12;
t23 = t32;

% Tensor de tensiones resultante.
I = [S1 t12 t13
     t21 S2 t23
     t31 t32 S3];

vert = [-1 -1  1
         1 -1  1
         1  1  1
        -1  1  1
       
        -1  1 -1
         1  1 -1
         1 -1 -1
        -1 -1 -1
         ];

faces = [1 2 3 4
         4 3 6 5
         2 7 6 3
         8 7 6 5
         1 2 7 8
         1 8 5 4];

vert2 = (Qx*Qy*Qz*vert')'; % Vertices rotados.             

figure
patch('Vertices',vert,'Faces',faces,'FaceColor','w','EdgeColor','b')
hold on
patch('Vertices',vert2,'Faces',faces,'FaceColor','w','EdgeColor','g')
title('Rotacion de dominio')
legend('Inicial','Final')
view([45 45 45])
grid
end












