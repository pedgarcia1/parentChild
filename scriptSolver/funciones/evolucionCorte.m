close all; 
magnification = 500;
figure
adaptedNodes = meshInfo.nodes;
% CASO TSHAPES
adaptedNodes(meshInfo.cohesivos.related8Nodes(1:225,1:4),2) = adaptedNodes(meshInfo.cohesivos.related8Nodes(1:225,1:4),2) - 1000;
adaptedNodes(meshInfo.cohesivos.related8Nodes(1:225,5:8),2) = adaptedNodes(meshInfo.cohesivos.related8Nodes(1:225,5:8),2) + 1000;

adaptedNodes(meshInfo.cohesivos.related8Nodes(226:end,1:4),3) = adaptedNodes(meshInfo.cohesivos.related8Nodes(226:end,1:4),3) - 1000;
adaptedNodes(meshInfo.cohesivos.related8Nodes(226:end,5:8),3) = adaptedNodes(meshInfo.cohesivos.related8Nodes(226:end,5:8),3) + 1000;

% CASO NORMAL
% adaptedNodes(meshInfo.cohesivos.related8Nodes(:,1:4),1) = adaptedNodes(meshInfo.cohesivos.related8Nodes(:,1:4),1) - 100;
% adaptedNodes(meshInfo.cohesivos.related8Nodes(:,5:8),1) = adaptedNodes(meshInfo.cohesivos.related8Nodes(:,5:8),1) + 100;
desplazamientosTimes = dTimes(1:size(meshInfo.nodes,1)*3,:);
% desplazamientosTimes = reshape(desplazamientosTimes,3,[])';
han = figure;
for iTime = 150:2:temporalProperties.nTimes
    clf
    suptitle('Evolucion de Fractura tipo TSHAPES de verificacion')
    subplot(1,2,1)
    patch('Faces',meshInfo.cohesivos.elements,'Vertices',adaptedNodes + magnification*reshape(desplazamientosTimes(:,iTime),3,[])','FaceColor','r','FaceAlpha',1)
    hold on
    patch('Faces',meshInfo.cohesivos.related8Nodes(:,5:end),'Vertices',adaptedNodes + magnification*reshape(desplazamientosTimes(:,iTime),3,[])','FaceColor','b','FaceAlpha',1)
    axis square
    view(-45,20)
    %     view([0 1 0])
    daspect([1 1 1])
    xlabel('X [mm]')
    ylabel('Y [mm]')
    zlabel('Z [mm]')
    title(num2str(iTime))
    set(gcf,'Position',[200 41.8 900 740.8]);
    subplot(1,2,2)
    patch('Faces',meshInfo.cohesivos.elements,'Vertices',adaptedNodes + magnification*reshape(desplazamientosTimes(:,iTime),3,[])','FaceColor','r','FaceAlpha',1)
    hold on
    patch('Faces',meshInfo.cohesivos.related8Nodes(:,5:end),'Vertices',adaptedNodes + magnification*reshape(desplazamientosTimes(:,iTime),3,[])','FaceColor','b','FaceAlpha',1)
    axis square
    %     view(-45,20)
    view([-1 0 0])
    daspect([1 1 1])
    xlabel('X [mm]')
    ylabel('Y [mm]')
    zlabel('Z [mm]')
    title(num2str(iTime))
    set(gcf,'Position',[200 41.8 900 740.8]);
%     pause(0.5)
    
    saveas(han,['evolucionTSHAPES_',num2str(iTime),'.png']) 
      
end
    
    