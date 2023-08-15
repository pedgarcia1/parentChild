for iTimeEspecifico = 355:temporalProperties.nTimes
    clf
    subplot(1,2,1)
%     set(gcf,'Position',[200 41.8 900 740.8]);
set(gcf,'Position',[0 41.8 1500 740.8]);
    plotPresionesPromediadas
    view([-30 30])
    zlim([0 meshInfo.anchoZ/2])
    ylim([0 meshInfo.anchoY])
    xlim([0 meshInfo.anchoX])   
    subplot(1,2,2)
    plotColo3D(meshInfo.nodes(1:paramDiscEle.nDofTot_P,:),meshInfo.elements,avgStress(:,1))
    title(['iTime: ',num2str(iTimeEspecifico)]);
    view([-30 30])
    zlim([0 meshInfo.anchoZ])
    ylim([meshInfo.anchoY/2 meshInfo.anchoY])
    xlim([0 meshInfo.anchoX])
%     set(gca,'xdir','reverse')
    drawnow 
    saveas(gcf,['pp',num2str(iTimeEspecifico),'.png']) 
%     pause(0.1)
    fprintf([num2str(iTimeEspecifico),' de ',num2str(temporalProperties.nTimes),'\n'])
end