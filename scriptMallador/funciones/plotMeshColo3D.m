function plotMeshColo3D(nodes,elements,color,opacity)

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
patch('Vertices',nodes,'Faces',auxiliar1,'FaceColor',color,'EdgeColor','k','EdgeAlpha',0.6,'FaceAlpha',opacity)
colormap jet
axis([min(nodes(:,1)),max(nodes(:,1)),min(nodes(:,2)),max(nodes(:,2)),min(nodes(:,3)),max(nodes(:,3))])
view(-45,20)

end