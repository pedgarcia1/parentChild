function [ksi,eta,zeta] = faceDetect3D(linearGauss,condition,ipg)

rsInt = linearGauss*ones(1,3);
[~,upg, ~] = gauss(rsInt);
condition = condition(1:8);

if sum(condition == [0; 0; 1; 1; 0; 0; 1; 1]) > 7
    ksi = upg(ipg,2);
    eta = -1;
    zeta = upg(ipg,3);
elseif sum(condition == [1; 1; 0; 0; 1; 1; 0; 0]) > 7
    ksi =upg(ipg,2) ;
    eta = 1;
    zeta = upg(ipg,3);
    
elseif sum(condition == [1; 1; 1; 1; 0; 0; 0; 0]) > 7
    ksi = upg(ipg,2);
    eta = upg(ipg,3);
    zeta = 1;
elseif sum(condition == [0; 0; 0; 0; 1; 1; 1; 1]) > 7
    ksi = upg(ipg,2);
    eta = upg(ipg,3);
    zeta = -1;
        
elseif sum(condition == [0; 1; 1; 0; 0; 1; 1; 0]) > 7
    ksi = -1;
    eta = upg(ipg,2);
    zeta = upg(ipg,3);
elseif sum(condition == [1; 0; 0; 1; 1; 0; 0; 1]) > 7    
    ksi = 1;
    eta = upg(ipg,2);
    zeta = upg(ipg,3);
    
end


end