%% Plot perfil de fractura y presion normalizada, para un timestep.
% Requiere cargar de antemano el archivo, definir el nombreCaso, si se
% plotea separacion normal o concentracion de propante
% (plotConcentracionPropante), y si se utiliza bandplot o plotColo para el
% grafico de separacion normal o conc. propante (banplotOPlotColo).
%%
iTime=20; %para verla en el timestep que quiera
if exist('iTime','var') == 0
    iTime=size(dTimes,2); %ultimo timestep guardado (fin fractura, fin produccion, segun el archivo)
end
if exist('nombreCaso','var') == 0
    nombreCaso='nombreCaso'; %nombre del caso, para poner de titulo a la figura
end
if exist('plotConcentracionPropante','var') == 0
    plotConcentracionPropante=0; %0: plotea apertura de fractura [mm] - 1: plotea concentracion de propante [kg/m2]
end
if exist('bandplotOPlotColo','var') == 0
    bandplotOPlotColo=0; %0: usa bandplot para el 1er plot ('bueno y lento') - 1: usa plotColo para el 1er plot ('malo y rapido')
end
if exist('plot12','var') == 0
    plot12=0; %0: ambos subplots - 1: solo 1er plot - 2: solo 2do plot
end


%nodos muertos por timestep para el scatter3
nodosMuertos             = reshape(meshInfo.elementsBarra.ALL(unique(meshInfo.cohesivos.relatedEB(logical(meshInfo.cohesivos.deadFlagTimes(:,:,iTime)))),:),[],1);
deadIntNodes             = ismember(intNodes,nodosMuertos);
if any(deadIntNodes)
deadIntNodesIndex    = intNodes(deadIntNodes);
nodesToAdd           = nonzeros(unique(reshape(meshInfo.CRFluidos(sum(ismember(meshInfo.CRFluidos,deadIntNodesIndex),2)>0,:),[],1)));
nodosMuertos         = unique([nodosMuertos
                               nodesToAdd ]);
end

%% Plots
figure

if plot12==0
    subplot(2,1,1)
    if plotConcentracionPropante==0
        if bandplotOPlotColo==0
            bandplot(meshInfo.cohesivos.elements,meshInfo.nodes,meshInfo.cohesivos.dNTimes(:,:,iTime))
%para plotear dS            %bandplot(meshInfo.cohesivos.elements,meshInfo.nodes,sqrt(meshInfo.cohesivos.dS1Times(:,:,iTime).^2+meshInfo.cohesivos.dS2Times(:,:,iTime).^2))
        else
            dNxNodo=getdNxNodo(meshInfo.cohesivos.elements,meshInfo.nodes,meshInfo.cohesivos.dNTimes(:,:,iTime));
            plotColo(meshInfo.nodes,meshInfo.cohesivos.elements,dNxNodo);
        end
            title({nombreCaso,['Apertura de fractura - iTime: ',num2str(iTime)]})
%para plotear dS            %title({nombreCaso,['Corte (dS) de fractura - iTime: ',num2str(iTime)]})
    else
        densidadPropante=1670; %kg/m3
        if bandplotOPlotColo==0
            concentracionPropante=meshInfo.cohesivos.dNTimes(:,:,iTime)*0.001*densidadPropante; %kg/m2
            bandplot(meshInfo.cohesivos.elements,meshInfo.nodes,concentracionPropante)
        else
            dNxNodo=getdNxNodo(meshInfo.cohesivos.elements,meshInfo.nodes,meshInfo.cohesivos.dNTimes(:,:,iTime));
            concentracionPropante=dNxNodo*0.001*densidadPropante; %kg/m2
            plotColo(meshInfo.nodes,meshInfo.cohesivos.elements,concentracionPropante);
        end
        title({nombreCaso,['Concentracion de propante - iTime: ',num2str(iTime)]})
        c = colorbar;
        c.Label.String = 'Concentracion de propante [kg/m2]';
    end
    axis square
    %view(-45,20)
    view([0 -1 0]);
    daspect([1 1 1])
    hold on
    scatter3(meshInfo.nodes(nodosMuertos,1),meshInfo.nodes(nodosMuertos,2),meshInfo.nodes(nodosMuertos,3),'r')
    subplot(2,1,2)
    presion = dTimes(paramDiscEle.nDofTot_U+1:paramDiscEle.nDofTot_U+paramDiscEle.nDofTot_P,iTime)*temporalProperties.preCond;
    %plotColo(meshInfo.nodes,meshInfo.elementsFluidos.elements,presion)
    presionNormalizada = presion/physicalProperties.poroelasticas.pPoral;
    plotColo(meshInfo.nodes,meshInfo.elementsFluidos.elements,presionNormalizada);
    c = colorbar;
    c.Label.String = ['Presion normalizada (p_{reservorio}=' num2str(physicalProperties.poroelasticas.pPoral,'%.2f') ' MPa)'];
    axis square
    daspect([1 1 1])
    view(-20,10);
    title({nombreCaso,['Presion normalizada - iTime: ',num2str(iTime)]})
elseif plot12==1
    if plotConcentracionPropante==0
        if bandplotOPlotColo==0
            bandplot(meshInfo.cohesivos.elements,meshInfo.nodes,meshInfo.cohesivos.dNTimes(:,:,iTime))
        else
            dNxNodo=getdNxNodo(meshInfo.cohesivos.elements,meshInfo.nodes,meshInfo.cohesivos.dNTimes(:,:,iTime));
            plotColo(meshInfo.nodes,meshInfo.cohesivos.elements,dNxNodo);
        end
            title({nombreCaso,['Apertura de fractura - iTime: ',num2str(iTime)]})
    else
        densidadPropante=1670; %kg/m3
        if bandplotOPlotColo==0
            concentracionPropante=meshInfo.cohesivos.dNTimes(:,:,iTime)*0.001*densidadPropante; %kg/m2
            bandplot(meshInfo.cohesivos.elements,meshInfo.nodes,concentracionPropante)
        else
            dNxNodo=getdNxNodo(meshInfo.cohesivos.elements,meshInfo.nodes,meshInfo.cohesivos.dNTimes(:,:,iTime));
            concentracionPropante=dNxNodo*0.001*densidadPropante; %kg/m2
            plotColo(meshInfo.nodes,meshInfo.cohesivos.elements,concentracionPropante);
        end
        title({nombreCaso,['Concentracion de propante - iTime: ',num2str(iTime)]})
        c = colorbar;
        c.Label.String = 'Concentracion de propante [kg/m2]';
    end
    axis square
    %view(-45,20)
    view([0 -1 0]);
    daspect([1 1 1])
    hold on
    scatter3(meshInfo.nodes(nodosMuertos,1),meshInfo.nodes(nodosMuertos,2),meshInfo.nodes(nodosMuertos,3),'r')
else
    presion = dTimes(paramDiscEle.nDofTot_U+1:paramDiscEle.nDofTot_U+paramDiscEle.nDofTot_P,iTime)*temporalProperties.preCond;
    %plotColo(meshInfo.nodes,meshInfo.elementsFluidos.elements,presion)
    presionNormalizada = presion/physicalProperties.poroelasticas.pPoral;
    plotColo(meshInfo.nodes,meshInfo.elementsFluidos.elements,presionNormalizada);
    c = colorbar;
    c.Label.String = ['Presion normalizada (p_{reservorio}=' num2str(physicalProperties.poroelasticas.pPoral,'%.2f') ' MPa)'];
    axis square
    daspect([1 1 1])
    view(-20,10);
    title({nombreCaso,['Presion normalizada - iTime: ',num2str(iTime)]})
end
%% Extras
set(gcf, 'Position', get(0, 'Screensize')); drawnow();
view([30,-5]);gcf;subplot(2,1,1);view([30,-5]);
%direccionAGuardar = 'C:\Users\jmujica2\DFIT-TSHAPE Rev.6 9-5-2022\Para plots\dfit largo malla fina\perfilesDeFractura';
%saveas(gcf,[direccionAGuardar '\_iTime_' num2str(iTime,'%d') '.jpg']);
%print('-clipboard','-dbitmap');