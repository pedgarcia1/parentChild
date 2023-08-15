function [nodes] = circle(nodes,debugPlots) 

R = max(nodes(:,1))-min(nodes(:,1));
x = [];
z = [];

for i = 0:(size(nodes,1)-1)
    tita = deg2rad(90/(size(nodes,1)-1)*i+180);
    x = [x; R*cos(tita)];
    z = [z; R*sin(tita)];
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
