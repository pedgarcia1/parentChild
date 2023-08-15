function [tOut,ftOut] = suavizado( t,ft,tol,div,acercamiento)
% La funcion suavizado sirve para suavizar saltos discretos dentro de una
% funcion. Sirve para saltos del tipo escalon.

% tol: Tiempo minimo entre datos para considerar un salto discreto.
% div: Numero de divisiones del intervalor temporal entre datos consecutivos.

% acercamiento: Mide cuanto se acerca al punto de informacion anterior al salto discreto. 
%               Si vale 1 repite la informacion del punto. Mientras
%               mas cercano a 1 mayor es el acercamiento y mientras
%               mas cercano a div menor es el acercamiento.

% Busco la discontinuidad.
deltaT = diff(t);
tPos = find(deltaT<=tol & abs(diff(ft))>0);
nDisc = numel(tPos);
nPos = zeros(nDisc+1,1);
tOut = t;
ftOut = ft;

for i = 1:nDisc
    tPosAux = [tPos(i),tPos(i)+1];
    deltaTdiv = min(deltaT([tPosAux(1)-1,tPosAux(2)]))/div;
    
    x = t(tPosAux(1))-deltaTdiv*div/acercamiento : deltaTdiv : t(tPosAux(2))+deltaTdiv*div/acercamiento;
    x0 = t(tPosAux(1)-1);
    x1 = x(1);
    x2 = x(end);
    x3 = t(tPosAux(2)+1);
    
    y1 = interp1([x0,t(tPosAux(1))],[ft(tPosAux(1)-1),ft(tPosAux(1))],x1);
    y2 = interp1([t(tPosAux(2)),x3],[ft(tPosAux(2)),ft(tPosAux(2)+1)],x2);
     
    
    y0 = ft(tPosAux(1)-1);
    y3 = ft(tPosAux(2)+1);
    dx01 = x1-x0;
    dx23 = x3-x2;
    if dx01==0 || dx23==0
        x0 = t(tPosAux(1)-2);
        x3 = t(tPosAux(2)+2);
        y0 = ft(tPosAux(1)-2);
        y3 = ft(tPosAux(2)+2);
        dx01 = x1-x0;
        dx23 = x3-x2;
    end
    
    X = [ x1^3    x1^2  x1 1
          x2^3    x2^2  x2 1
          3*x1^2  2*x1  1  0
          3*x2^2  2*x2  1  0];
    Y = [ y1
          y2
         (y1-y0)/dx01
         (y3-y2)/dx23];
    
    C = X\Y;
    
    fun = C(1)*x.^3+ C(2)*x.^2 + C(3)*x + C(4);
    tOut = [tOut(1:tPosAux(1)-1+ nPos(i)), x, tOut(tPosAux(2)+1+ nPos(i):end)];
    ftOut = [ftOut(1:tPosAux(1)-1+ nPos(i)), fun, ftOut(tPosAux(2)+1+ nPos(i):end)];
    
    nPos(i+1) = nPos(i) + numel(x)-2;   
end
end

