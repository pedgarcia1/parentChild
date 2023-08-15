function plotColo(nodes,elements,scalarField)

v = nodes;
f = elements;
col = scalarField;
% figure
patch('Faces',f,'Vertices',v,'FaceVertexCData',col,'FaceColor','interp');
colormap(jet(10))
c = colorbar;
c.Label.String = 'Presion de fractura [MPa]';
%set(gca,'TickLabelInterpreter','latex','Limits',[min(cg) max(cg)],'box','off','FontSize',25)
%c.TickLabelInterpreter = 'latex';
% c.FontSize = 8;
%c.Limits = [min(cg) max(cg)];
% c.Box = 'off';
% c.Location = 'southoutside';
maxCbar = max(max(scalarField(elements)));
minCbar = min(min(scalarField(elements)));
caxis([minCbar maxCbar])
colormap parula

% c.Label.String = 'Presion';
% c.Label.FontSize = 12;
% c.Label.Rotation = 0;


% kssv = round(linspace(min(scalarField),max(scalarField),5),2);
% set(c,'YtickMode','manual','YTick',kssv); % Set the tickmode to manual

%set(gca,'xtick',[],'ytick',[],'XColor','none','YColor','none')

axis square
ylabel('y [mm]'),zlabel('z [mm]');
axis tight
%set(gca,'XTick',[],'YTick',[])
end