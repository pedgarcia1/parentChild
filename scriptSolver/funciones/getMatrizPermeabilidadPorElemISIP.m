function [ Kperm ] = getMatrizPermeabilidadPorElemISIP(physicalProperties,meshInfo,SRVProperties,improvePerm,type,key )
KpermGP_S   = physicalProperties.fluidoPoral.kappaS*eye(3,3);
KpermGP_L   = [physicalProperties.fluidoPoral.kappaLH*eye(2,3);physicalProperties.fluidoPoral.kappaLV*fliplr(eye(1,3))];
% KpermGP_ISIP   = improvePerm*KpermGP_S; %No se usa este valor
KpermGP_SRV = physicalProperties.fluidoPoral.kappaSRV*eye(3,3);
% La opcion "single" sirve para tener menos drain times dando un valor
% grande (arbitrario 2mD) de permeabilidad a todo el dominio. Una vez 
% terminados los drain times, se ajusta la permeabilidad del dominio y las
% barreras con la opcion "double".


switch type
    case 'drain' 
        Kperm{1}  = repmat(1.108988764044944*eye(3,3),1,1,8);
        Kperm     = repmat(Kperm,size(meshInfo.elements,1),1);
        KpermPlotH = 1.108988764044944*ones(size(meshInfo.elements));
        KpermPlotV = 1.108988764044944*ones(size(meshInfo.elements));

    case 'frac' % En caso de que haya TSHAPES primero se setea la permeabilidad de todo el dominio como si fuese shale y luego se reemplaza en los elementos de barerra por permeabilidad ortotropa de barrera. 
        Kperm{1}   = repmat(KpermGP_S,1,1,8);
        Kperm      = repmat(Kperm,size(meshInfo.elements,1),1);
        nElements  = size(meshInfo.elements,1);        
        KpermPlotH = physicalProperties.fluidoPoral.kappaS*ones(size(meshInfo.elements));
        KpermPlotV = physicalProperties.fluidoPoral.kappaS*ones(size(meshInfo.elements));
        
        for iEle = 1:nElements
            if any(iEle == meshInfo.elementsBarreras.index)
                Kperm{iEle}        = repmat(KpermGP_L,1,1,8);
                KpermPlotH(iEle,:) = Kperm{iEle}(1,1);
                KpermPlotV(iEle,:) = Kperm{iEle}(3,3);
            end
        end
    case 'produccion'% Se setea la permeabilidad del SRV una vez que arranca con la produccion. 
        Kperm{1}   = repmat(KpermGP_S,1,1,8);
        Kperm      = repmat(Kperm,size(meshInfo.elements,1),1);
        nElements  = size(meshInfo.elements,1); 
        KpermPlotH = physicalProperties.fluidoPoral.kappaS*ones(size(meshInfo.elements));
        KpermPlotV = physicalProperties.fluidoPoral.kappaS*ones(size(meshInfo.elements));
        for iEle = 1:nElements
            if any(iEle == meshInfo.elementsBarreras.index)
                Kperm{iEle} = repmat(KpermGP_L,1,1,8);
            elseif any(iEle == SRVProperties.elementsIndex)
                Kperm{iEle} = repmat(KpermGP_SRV,1,1,8);
            end
                KpermPlotH(iEle,:) = Kperm{iEle}(1,1);
                KpermPlotV(iEle,:) = Kperm{iEle}(3,3);
        end
    case 'ISIP' 
        Kperm{1}   = repmat(KpermGP_S,1,1,8);
        Kperm      = repmat(Kperm,size(meshInfo.elements,1),1);
        nElements  = size(meshInfo.elements,1);
        KpermPlotH = physicalProperties.fluidoPoral.kappaS*ones(size(meshInfo.elements));
        KpermPlotV = physicalProperties.fluidoPoral.kappaS*ones(size(meshInfo.elements));
        
        for iEle = 1:nElements
            Kperm{iEle}        = repmat(physicalProperties.fluidoPoral.kappaS.*improvePerm(iEle).*eye(3,3), [1, 1, 8]);
            KpermPlotH(iEle,:) = Kperm{iEle}(1,1);
            KpermPlotV(iEle,:) = Kperm{iEle}(3,3);

        end
end
if strcmpi(key,'Y') && ~strcmpi(type,'single') % Plot para verificar los valores de permeabilidad en el dominio. 
    plotElemental(meshInfo.nodes,meshInfo.elements,KpermPlotH,'Y','Permeabilidad Sin Promediar Horizontal','x [mm]','y [mm]','z [mm]','k [mD]')
    plotElemental(meshInfo.nodes,meshInfo.elements,KpermPlotV,'Y','Permeabilidad Sin Promediar Vertical','x [mm]','y [mm]','z [mm]','k [mD]')
end