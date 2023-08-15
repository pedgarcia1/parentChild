function Draw_Barra(Element,Node,c)

nel = size(Element,1);
nnodel = size(Element,2);
xx = zeros(nnodel,1);
yy = zeros(nnodel,1);
zz = zeros(nnodel,1);
for k = 1:nel;
    for i = 1:nnodel;
        xx(i) = Node(Element(k,i),1);
        yy(i) = Node(Element(k,i),2);
        zz(i) = Node(Element(k,i),3);
%         text(xx(i),yy(i),zz(i),num2str(Element(k,i)),'VerticalAlignment','bottom','Color','r','FontSize',8);
    end
    plot3(xx,yy,zz,c)
    plot3(xx,yy,zz,'o','MarkerFaceColor','r','MarkerEdgeColor','r','MarkerSize',2)
    x = mean(Node(Element(k,:),1));
    y = mean(Node(Element(k,:),2));
%     text(x,y,num2str(k),'EdgeColor','k','Color','k','FontSize',8);
    
end

grid on
% axis equal
