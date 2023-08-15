% 1: sum(cumsum(temporalProperties.deltaTs(temporalProperties.drainTimes+1:end))<=temporalProperties.tInicioISIP)+temporalProperties.drainTimes+1
for iTimeEspecifico = iTime
    clf
    %     set(gcf,'Position',[200 41.8 900 740.8]);
%     set(gcf,'Position',[0 41.8 1820 800]);
    subplot(1,2,1)
    hold on
    bandplot(meshInfo.cohesivos.elements,meshInfo.nodes,meshInfo.cohesivos.dNTimes(:,:,iTimeEspecifico))
    nodosMuertos = reshape(meshInfo.elementsBarra.ALL(unique(meshInfo.cohesivos.relatedEB(logical(meshInfo.cohesivos.deadFlagTimes(:,:,iTimeEspecifico)))),:),[],1);
    scatter3(meshInfo.nodes(nodosMuertos,1),meshInfo.nodes(nodosMuertos,2),meshInfo.nodes(nodosMuertos,3),'r')
    axis square
    view(-45,20)
    daspect([1 1 1])
    %     scatter3(meshInfo.nodes(nodosMuertos,1),meshInfo.nodes(nodosMuertos,2),meshInfo.nodes(nodosMuertos,3),'r')
    title(['iTime: ',num2str(iTimeEspecifico)])
    
    subplot(1,2,2)
    presion = dTimes(paramDiscEle.nDofTot_U+1:paramDiscEle.nDofTot_U+paramDiscEle.nDofTot_P,iTimeEspecifico)*temporalProperties.preCond;
    plotColo(meshInfo.nodes,meshInfo.elementsFluidos.elements,presion)
    axis square
    view(-45,20)
    daspect([1 1 1])
    title(['iTime: ',num2str(iTimeEspecifico)])
    drawnow
    %     saveas(gcf,[num2str(iTime),'.png'])
    %     pause(0.1)
    fprintf([num2str(iTimeEspecifico),' de ',num2str(113),'\n'])
end