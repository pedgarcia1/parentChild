function [constitutivas, Biot]= eleProps(physicalProperties,nodes,elements,upg,key)
%%% Creacion de las matrices consitutivas, para cada elemento y dentro de
%%% cada elemento para cada punto de gauss. Se obtiene la posicion
%%% correspondiente del punto de gauss en coordenadas globales y se evalua
%%% la coordenada Z de aquel punto de gauss, asi se obtiene la matriz
%%% constitutiva.

% if strcmpi(key2,'default')
%     load('constitutiveDepthProperties')
%     fprintf('---------------------------------------------------------\n');
%     fprintf('Las distintos <strong>estratos de la malla</strong> son representados mediante las siguientes propiedades: \n');
%     disp(constitutiveDepthProperties);
%     
% elseif strcmpi(key2,'change')
%     fprintf('---------------------------------------------------------\n');
%     constitutiveDepthProperties.Ev = input('  Ingrese perfil de Ev [Mpsi]: ')*1e6/145;
%     constitutiveDepthProperties.Eh = input('  Ingrese perfil de Eh [Mpsi]: ')*1e6/145;
%     constitutiveDepthProperties.Nuv = input('  Ingrese perfil de Nuv: ');
%     constitutiveDepthProperties.Nuh = input('  Ingrese perfil de Nuh: ');
%     constitutiveDepthProperties.depth = input('  Ingrese perfil de profunidades (z) [mm]: ');
%     save('constitutiveDepthProperties','constitutiveDepthProperties');
% end
    
constitutivas = cell(size(elements,1),1);
Biot          = cell(size(elements,1),1);
for iele = 1:size(elements,1)
    zsEle            = nodes(elements(iele,:),3);                                     % Coordenada Z de cada nodo de los 8 elementos de un H8.
    constitutivasEle = zeros(6,6,size(upg,1));
    BiotEle          = zeros(6,1,size(upg,1));
    for ipg = 1:size(upg,1)
        
        %% Interpolacion de los puntos de gauss a Z global
        ksi  = upg(ipg,1);
        eta  = upg(ipg,2);
        zeta = upg(ipg,3);
        N    = shapefuns(ksi,eta,zeta);
        zPG  = N*zsEle;
        
        %% Sampleo de las propiedades
        if ~all(zPG > physicalProperties.constitutive.depth)
            EH  = interp1(physicalProperties.constitutive.depth,physicalProperties.constitutive.Eh,zPG);
            EV  = interp1(physicalProperties.constitutive.depth,physicalProperties.constitutive.Ev,zPG);
            NUV = interp1(physicalProperties.constitutive.depth,physicalProperties.constitutive.NUv,zPG);
            NUH = interp1(physicalProperties.constitutive.depth,physicalProperties.constitutive.NUh,zPG);
        else
            EH  = physicalProperties.constitutive.Eh(end);
            EV  = physicalProperties.constitutive.Ev(end);
            NUV = physicalProperties.constitutive.NUv(end);
            NUH = physicalProperties.constitutive.NUh(end);
        end
        constitutivasEle(:,:,ipg) = constitutiveMatrix( EV,EH,NUV,NUH); % Tensor Constitutivo Estrato 10 [C] 6x6. Material transversalmente isotrópico
        BiotEle(:,:,ipg)          = (physicalProperties.poroelasticas.m - constitutivasEle(:,:,ipg)*physicalProperties.poroelasticas.m/3/physicalProperties.poroelasticas.Ks);
    end
    constitutivas{iele} = constitutivasEle;
    Biot{iele}          = BiotEle;
end
% if strcmpi(key,'on')
%     % Plots de las propiedades
%     meshProps.E_H = interp1(physicalProperties.constitutive.depth,physicalProperties.constitutive.Eh,nodes(:,3));
%     plotColo3D(nodes,elements,meshProps.E_H)
%     colormap copper
%     view([0 1 0])
%     meshProps.E_V = interp1(physicalProperties.constitutive.depth,physicalProperties.constitutive.Ev,nodes(:,3));
%     plotColo3D(nodes,elements,meshProps.E_V)
%     colormap copper
%     view([0 1 0])
% end
end
