nStages = size(SRVProperties.KPermCell,1); figure;
for iStage = 1:nStages
    stage = SRVProperties.KPermCell{iStage,3};
    elementsIndex = SRVProperties.KPermCell{iStage,2};
    subplot(1,nStages,iStage);
    title(sprintf('%d: %s',iStage,stage))
    plotMeshColo3D(meshInfo.nodes,meshInfo.elements(elementsIndex,:),meshInfo.cohesivos.elements,'on','on','w','r','k',0.5);
end