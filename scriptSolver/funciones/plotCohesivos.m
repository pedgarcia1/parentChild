function plotCohesivos(nodes,elementsCohesivos)
figure
hold on
    patch('Faces',elementsCohesivos,'Vertices',nodes,'FaceColor','r','FaceAlpha',0.8)
    axis square
    view(-45,20)
    daspect([1 1 1])
    xlabel('X [mm]')
    ylabel('Y [mm]')
    zlabel('Z [mm]')
end