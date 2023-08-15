% function  plotElementalProperties(nodes,elements,field,cBar,titulo,rotuloX,rotuloY,rotuloZ,rotuloCbar)
clear; close all;
load('TRIPLET_SW_FINA_2.mat')

% Ev    = [1.92 1.92 2.96 2.96 1.92  1.92 2.96 2.96  1.92  1.92 2.96 2.96  1.92  1.92 2.96 2.96  1.92 1.92];
 Ev    = [1.92 1.92 2.96 2.96 1.92  1.92 2.96 2.96  1.92  1.92 1.92 1.92  1.92  1.92 2.96 2.96  1.92 1.92];
depth = [   0  50  55  80  130 139.9  140  142 142.9 161.9  162  164 164.9 183.9  184  186 186.9  326]*1e3;
%  depth = [   0  100  105  125  130 140  140  142 142 162  162  164 164 184  184  186 186  326]*1e3;

for iNode = 1:size(nodes,1)
    zNode = nodes(iNode,3);
    if zNode <= 186000 && zNode >= 184000
    a = 1;
    end
    nodalField(iNode,1) = interp1(depth,Ev,zNode);
end

nElements = size(elements,1);
figure
% subplot(1,2,2)
hold on
for iEle = 1:nElements
    if iEle == 1855
        A = 1;
    end
    element        = elements(iEle,:);
    elementalNodes = nodes(element,:);
    elementalField = nodalField(element);
    element        = 1:8;
    auxiliar       = element(:,[1 2 6 5 2 3 7 6 3 4 8 7 4 1 5 8 1 2 3 4 5 6 7 8]);
    auxiliar1      = reshape(auxiliar',4,[])';
    patch('Vertices',elementalNodes,'Faces',auxiliar1,'FaceVertexCData',elementalField,'FaceColor','interp','EdgeColor','k','EdgeAlpha',1,'LineWidth',0.5)
end
% view([0 -1 -1])
axis square
set(gca,'DataAspectRatio',[1 1 1])
ax2 = gca;
ax2.ZDir = 'reverse';
colormap copper
colorbar 

title('Propiedades Mecánicas vs profundidad')
% xlabel(rotuloX)
% ylabel(rotuloY)
zlabel('Profundidad [m]')
set(gca,'xtick',[],'ytick',[],'ztick',[])
% if strcmpi(cBar,'Y')
    hc = colorbar;
    hc.Label.String = 'Modulo de Young Vertical [Mpsi]';
%     hc.Label.Interpreter = 'latex';
%     hc.Label.FontSize = 24;
% end
% end

% subplot(1,2,1)
figure
plot(Ev,abs(depth/1000+2953))
title('Propiedades Mecánicas vs profundidad')
xlabel('Modulo de Young Vertical [Mpsi]')
ylabel('Profundida [m]')
ax = gca;
ax.YDir = 'reverse';
grid
