function [nodes] = circle_prueba(nodes,debugPlots) 
n = size(nodes,1);



DesMax = 1.15;
mitad = linspace(DesMax,1,ceil(n/2));
factor = [flip(mitad(1:end-1)) mitad];

tita = linspace(180,270,size(nodes,1));
R = ones(1,n)*(max(nodes(:,1))-min(nodes(:,1))).*factor;
[x,y] = pol2cart(tita,R);











for i = 0:(size(nodes,1)-1)
    tita = deg2rad(90/(size(nodes,1)-1)*i+180);
    x = [x; R*factor(i+1)^2*cos(tita)];
    z = [z; R*factor(i+1)^2*sin(tita)];
end

x = x+R+min(nodes(:,1));
z = z+R+min(nodes(:,3));

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
