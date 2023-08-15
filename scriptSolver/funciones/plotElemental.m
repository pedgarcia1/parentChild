function  plotElemental(nodes,elements,field,cBar,titulo,rotuloX,rotuloY,rotuloZ,rotuloCbar)
nElements = size(elements,1);
figure
hold on
for iEle = 1:nElements
    element        = elements(iEle,:);
    elementalNodes = nodes(element,:);
    element        = 1:8;
    elementalField = field(iEle,:,1);
    auxiliar       = element(:,[1 2 6 5 2 3 7 6 3 4 8 7 4 1 5 8 1 2 3 4 5 6 7 8]);
    auxiliar1      = reshape(auxiliar',4,[])';
    patch('Vertices',elementalNodes,'Faces',auxiliar1,'FaceVertexCData',elementalField','FaceColor','interp','EdgeColor','k','EdgeAlpha',1,'LineWidth',0.5)
end
view(-45,20)
axis square
set(gca,'DataAspectRatio',[1 1 1])
title(titulo)
xlabel(rotuloX)
ylabel(rotuloY)
zlabel(rotuloZ)
set(gca,'xtick',[],'ytick',[],'ztick',[])
if strcmpi(cBar,'Y')
    hc = colorbar;
    hc.Label.String = rotuloCbar;
%     hc.Label.Interpreter = 'latex';
    hc.Label.FontSize = 24;
end
end

