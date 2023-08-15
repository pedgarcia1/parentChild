function [Ke] = KBarra3D(iele,nodes,elements,E,A,largoNumerico)

dir = nodes(elements(iele,2),:) - nodes(elements(iele,1),:);
L = norm(dir);
dir = dir / L;

k = E*A / largoNumerico;
ke_B  = [ k -k
         -k  k ];   
T = [ dir  0 0 0
      0 0 0  dir ];
              
Ke = T' * ke_B * T; 
% 
% Ke([1 4],[1 4]) = ke_B;
% Ke([2 5],[2 5]) = ke_B;
testVec = abs(dir);
product1 = dot(testVec,[1 0 0]);
product2 = dot(testVec,[0 1 0]);

% if product1 == 0 
%     if product2 == 0
% 
%         Ke([1 4],[1 4]) = ke_B;
%         Ke([2 5],[2 5]) = ke_B;
%     else 
%         Ke([1 4],[1 4]) = ke_B;
%         Ke([3 6],[3 6]) = ke_B;
%         
%     end
% else
%     Ke([2 5],[2 5]) = ke_B;
%     Ke([3 6],[3 6]) = ke_B;
%     
% end

end
