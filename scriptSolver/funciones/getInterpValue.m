 function [fi] = getInterpValue(t,f,ti)
% t: variable independiente.
% f: variable dependiente.
% Si hay salto discreto toma el valor a la izquierda del salto. 
% (no deberia porque la curva se suaviza antes)
tiPos = [sum(ti>=t) sum(ti>=t)+1];
t0 = t(tiPos(1));
t1 = t(tiPos(2));
f0 = f(tiPos(1));
f1 = f(tiPos(2));
fi = interp1([t0 t1],[f0 f1],ti);
 end

















