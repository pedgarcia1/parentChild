function plotColo3D(nodes,elements,field)

auxiliar = elements(:,[1 2 6 5 2 3 7 6 3 4 8 7 4 1 5 8 1 2 3 4 5 6 7 8]);
auxiliar1  = reshape(auxiliar',4,[])' ;

% figure
patch('Vertices',nodes,'Faces',auxiliar1,'FaceVertexCData',field,'FaceColor','interp','EdgeColor','k','EdgeAlpha',0.2)
colormap jet
c = colorbar;
%set(gca,'TickLabelInterpreter','latex','Limits',[min(cg) max(cg)],'box','off','FontSize',25)
% c.TickLabelInterpreter = 'latex';
% c.FontSize = 22;
c.Limits = [min(field) max(field)];
c.Box = 'off';
% c.Location = 'southoutside';
% c.Label.String = 'C';
% c.Label.FontSize = 25;
c.Label.Rotation = 90;
% c.Label.Interpreter = 'latex';
c.Label.String = 'Pp [psi]';
view(-45,20)
axis square
set(gca,'DataAspectRatio',[1 1 1])
set(gca,'xtick',[],'ytick',[],'ztick',[])
xlabel('x')
ylabel('y')
zlabel('z')

end