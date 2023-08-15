function [nodes] = circle3(nodes,desv,debugPlots) 
n = size(nodes,1);

mitad = linspace(desv,0,ceil(n/2));
primera_mitad = flip(mitad);

factor = [primera_mitad(1:end-1) mitad];
factor = 2.72.^factor;

tita = deg2rad(linspace(180,270,size(nodes,1)));
R = ones(1,n)*(max(nodes(:,1))-min(nodes(:,1))).*factor.^2;

R(ceil(n/2)) = R(ceil(n/2))*1.05;

x = R.*factor.*cos(tita);
z = R.*factor.*sin(tita);

x = x+min(R)+min(nodes(:,1));
z = z+min(R)+min(nodes(:,3));

if debugPlots == 1
    figure
    plot(nodes(:,1),nodes(:,3),'d')
    hold on
    plot(x,z,'o')
end

nodes(:,1) = x;
nodes(:,3) = z;

if debugPlots == 1
    hold off
    figure
    plot(x,z,'o')
end
end