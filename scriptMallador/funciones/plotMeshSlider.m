function plotMeshSlider(nodes, elements, color)
% Funcion de ploteo de malla basada en la del Colo pero con un slider por
% coordenada por si hace falta ver algo particular
fig = figure();hold on;
    set(fig, 'Position', [175, 75, 1000, 500])
    set(fig,'DeleteFcn',@deleteFile);
    auxiliar = elements(:,[1 2 6 5 2 3 7 6 3 4 8 7 4 1 5 8 1 2 3 4 5 6 7 8]);
    auxiliar1  = reshape(auxiliar',4,[])' ;

    if nargin<3
        color = 'w';
        opacity = 1;
    else if nargin<4
            opacity = 1;
        end
    end
    
    % Creamos los sliders para cada coordenada
    try
        load('filteredEle.mat');
    catch
        filteredEle{1}=1:length(elements);
        filteredEle{2}=1:length(elements);
        filteredEle{3}=1:length(elements);
    end
    
    meshPlot(filteredEle);
    
    slider_x = uicontrol('Style', 'slider', 'Position', [0 300 200 20], 'Min', 0, 'Max', max(nodes(:,1)), 'Value', 0, 'Callback', {@slider_callback, 1,filteredEle});
    slider_y = uicontrol('Style', 'slider', 'Position', [0 200 200 20], 'Min', 0, 'Max', max(nodes(:,2)), 'Value', 0, 'Callback', {@slider_callback, 2,filteredEle});
    slider_z = uicontrol('Style', 'slider', 'Position', [0 100 200 20], 'Min', 0, 'Max', max(nodes(:,3)), 'Value', max(nodes(:,3)), 'Callback', {@slider_callback, 3,filteredEle});

    %% Edits
    edit_x = uicontrol('Style', 'edit', 'Position', [0 325 200 20], 'String', ['X=' num2str(get(slider_x, 'Value'))], 'Callback', {@edit_callback, 1});
    edit_y = uicontrol('Style', 'edit', 'Position', [0 225 200 20], 'String', ['Y=' num2str(get(slider_y, 'Value'))], 'Callback', {@edit_callback, 2});
    edit_z = uicontrol('Style', 'edit', 'Position', [0 125 200 20], 'String', ['Z=' num2str(get(slider_z, 'Value'))], 'Callback', {@edit_callback, 3});

    
    %% Función de callback que se ejecuta cada vez que se mueve un slider
    function filteredEle= slider_callback(src, event, coord,filteredEle)
        load('filteredEle.mat');
    % Obtenemos el valor actual de la coordenada correspondiente al slider
        pos = get(src, 'Value');
    % Filtramos los elementos que atraviesan el plano perpendicular a la coordenada correspondiente
        filteredEle{coord}=eleFilter([],[],coord, pos);
        meshPlot(filteredEle)
    end


    %% Función de callback que se ejecuta cada vez que se ingresa un valor en un cuadro de texto
    function filteredEle = edit_callback(src, event, slider,filteredEle)
        load('filteredEle.mat');
    % Obtenemos el valor ingresado en el cuadro de texto
    text = get(src, 'String');
    if length(text)<2
        val = str2double(text);
        if isnan(val)
            error
        end
    elseif char(text(2))== '=' 
        val = str2double(text(3:end));
    else
        val = str2double(text);
    end
    
    % Verificamos si el valor ingresado es un número válido
        if ~isnan(val)
            % Si es válido, actualizamos el valor del slider correspondiente
                switch slider
                    case 1
                        set(slider_x, 'Value', val,'Callback', {@slider_callback, 1});
                        filteredEle{1}=eleFilter([],[],1, val);
                        meshPlot(filteredEle)
                    case 2
                        set(slider_y, 'Value', val,'Callback', {@slider_callback, 2});
                        filteredEle{2}=eleFilter([],[],2, val);
                        meshPlot(filteredEle)                    
                    case 3
                        set(slider_z, 'Value', val,'Callback', {@slider_callback, 3});
                        filteredEle{3}=eleFilter([],[],3, val);
                        meshPlot(filteredEle)
                end

        end
    end

%% Funcion de filtrar elementos
    function filtered_elements=eleFilter(src,event,coord, pos)
        filtered_elements = [];
        if coord==3
            for t = 1:size(elements,1)
                if(sum(nodes(elements(t,:),coord)<=pos)==8)
                     filtered_elements = [filtered_elements; t];
                end
            end
        else 
            for t = 1:size(elements,1)
                if(sum(nodes(elements(t,:),coord)>=pos)==8)
                     filtered_elements = [filtered_elements; t];
                end
            end
        end
        set(edit_x,'String', ['X=' num2str(get(slider_x, 'Value'))]);
        set(edit_y,'String', ['Y=' num2str(get(slider_y, 'Value'))]);
        set(edit_z,'String', ['Z=' num2str(get(slider_z, 'Value'))]);
    end

%% Actualizar la figura
    function meshPlot(filteredEle)
        filtered_elements = unique(filteredEle{1}(find(ismember(filteredEle{1},filteredEle{2}(find(ismember(filteredEle{2},filteredEle{3})))))));
        cla
        auxiliar = elements(filtered_elements,[1 2 6 5 2 3 7 6 3 4 8 7 4 1 5 8 1 2 3 4 5 6 7 8]);
        auxiliar1  = reshape(auxiliar',4,[])' ;
        obj = patch('Vertices',nodes,'Faces',auxiliar1,'FaceColor',color,'EdgeColor','k','EdgeAlpha',0.6,'FaceAlpha',opacity);
        colormap jet
        axis([min(nodes(:,1)) max(nodes(:,1)) min(nodes(:,2)) max(nodes(:,2)) min(nodes(:,3)) max(nodes(:,3))]);
        axis equal
        view(-45,20)
        save('filteredEle.mat','filteredEle');
    end



function deleteFile(~,~)
    try
        delete('filteredEle.mat');
    catch
    end
end
end
    

