function plotMeshColo3D(nodes,elements,elementsCohesivos,key1,key2,color,color2,colorEdge,opacity)
if strcmpi(key1,'on')
        auxiliar = elements(:,[1 2 6 5 2 3 7 6 3 4 8 7 4 1 5 8 1 2 3 4 5 6 7 8]);
        auxiliar1  = reshape(auxiliar',4,[])' ;
        
        if nargin<8
            color = 'w';
            opacity = 1;
        else if nargin<7
                opacity = 1;
            end
        end
        
        % figure
        patch('Vertices',nodes,'Faces',auxiliar1,'FaceColor',color,'EdgeColor',colorEdge,'EdgeAlpha',0.6,'FaceAlpha',opacity)
        colormap jet
        axis square
        view(-45,20)
        daspect([1 1 1])
        xlabel('X [mm]')
        ylabel('Y [mm]')
        zlabel('Z [mm]')
end
if strcmpi(key2,'on')
    hold on
    patch('Faces',elementsCohesivos,'Vertices',nodes,'FaceColor',color2,'FaceAlpha',0.8)
    axis square
    view(-45,20)
    daspect([1 1 1])
    xlabel('X [mm]')
    ylabel('Y [mm]')
    zlabel('Z [mm]')
end
end