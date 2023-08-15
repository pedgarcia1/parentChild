function plotMeshColo3D2(nodes,elements,color,opacity,linewidth)

auxiliar = elements(:,[1 2 6 5 2 3 7 6 3 4 8 7 4 1 5 8 1 2 3 4 5 6 7 8]);
auxiliar1  = reshape(auxiliar',4,[])' ;

if nargin<3
    color = 'w';
    opacity = 1;
else if nargin<4
        opacity = 1;
    end
end

% figure
patch('Vertices',nodes,'Faces',auxiliar1,'FaceColor',color,'EdgeColor','k','EdgeAlpha',0.6,'FaceAlpha',opacity,'LineWidth',linewidth)
colormap jet
axis equal
view(-45,20)

end