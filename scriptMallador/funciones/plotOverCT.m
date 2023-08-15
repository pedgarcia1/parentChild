function plotOverCT(meshInfo,key,nodosOverConstrained)

if strcmp(key,'on')
figure
hold on
plotMeshColo(meshInfo.nodes,meshInfo.elements,meshInfo.cohesivos.elements,'off','on','w','r','k',0.2) % Se plotea la malla
scatter3(meshInfo.nodes(nodosOverConstrained,1),meshInfo.nodes(nodosOverConstrained,2),meshInfo.nodes(nodosOverConstrained,3),'MarkerEdgeColor','k','MarkerFaceColor',[0 .75 .75])
hold off
end
function plotMeshColo(nodes,elements,elementsCohesivos,key1,key2,color,color2,colorEdge,opacity)
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
        
%         figure
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
    patch('Faces',elementsCohesivos,'Vertices',nodes,'FaceColor',color2,'FaceAlpha',1)
    axis square
    view(-45,20)
    daspect([1 1 1])
    xlabel('X [mm]')
    ylabel('Y [mm]')
    zlabel('Z [mm]')
end
end
end


