% subplot(1,2,1)
% bandplot(meshInfo.cohesivos.elements,meshInfo.nodes,meshInfo.cohesivos.dNCalculado)
% axis square
% view(-45,20)
% daspect([1 1 1])
% hold on
% scatter3(meshInfo.nodes(nodosMuertos,1),meshInfo.nodes(nodosMuertos,2),meshInfo.nodes(nodosMuertos,3),'r')
% title(['iTime: ',num2str(iTime)])
% 
% subplot(1,2,2)
% presion = dTimes(paramDiscEle.nDofTot_U+1:paramDiscEle.nDofTot_U+paramDiscEle.nDofTot_P,iTime)*temporalProperties.preCond;
% plotColo(meshInfo.nodes,meshInfo.elementsFluidos.elements,presion)
% axis square
% view(-45,20)
% daspect([1 1 1])
% title(['iTime: ',num2str(iTime)])
% drawnow



% bandplot(meshInfo.cohesivos.elements,meshInfo.nodes,meshInfo.cohesivos.dS2Calculado)
% axis square
% view(-45,20)
% daspect([1 1 1])
% hold on
% scatter3(meshInfo.nodes(nodosMuertos,1),meshInfo.nodes(nodosMuertos,2),meshInfo.nodes(nodosMuertos,3),'r')
% title(['iTime: ',num2str(iTime)])


for iTimePlot = iTime-40:1:iTime
    figure
    set(gcf,'Position',[600 41.8 2000 1200]);
    subplot(1,2,1)
    bandplot(meshInfo.cohesivos.elements,meshInfo.nodes,meshInfo.cohesivos.dNTimes(:,:,iTimePlot-1))
    axis square
    view(-45,20)
    daspect([1 1 1])
    hold on
    % scatter3(meshInfo.nodes(nodosMuertos,1),meshInfo.nodes(nodosMuertos,2),meshInfo.nodes(nodosMuertos,3),'r')
    title(['iTime: ',num2str(iTime)])
    
    subplot(1,2,2)
    presion = dTimes(paramDiscEle.nDofTot_U+1:paramDiscEle.nDofTot_U+paramDiscEle.nDofTot_P,iTimePlot-1)*temporalProperties.preCond;
    plotColo(meshInfo.nodes,meshInfo.elementsFluidos.elements,presion)
    axis square
    view(-45,20)
    daspect([1 1 1])
    title(['iTime: ',num2str(iTimePlot)])
    drawnow
    
end