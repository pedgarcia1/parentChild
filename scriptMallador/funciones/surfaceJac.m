function loadJac = surfaceJac(gaussPoint,jac)



selector = (abs(gaussPoint) == 1);


normAxis = 1:3;
normAxis = normAxis(selector)*gaussPoint(selector);

switch normAxis
    case 1
        v1 = jac(2,:);
        v2 = jac(3,:);
        jacComp  = jac([2 3],:);

    case 2
        v1 = jac(3,:);
        v2 = jac(1,:);
        jacComp  = jac([1 3],:);
        
    case 3
        v1 = jac(1,:);
        v2 = jac(2,:);
        jacComp = jac([1 2],:);
        
    case -1
        v2 = jac(2,:);
        v1 = jac(3,:);
        jacComp  = jac([2 3],:);

    case -2
        v2 = jac(3,:);
        v1 = jac(1,:);
        jacComp  = jac([1 3],:);
        
    case -3
        v2 = jac(1,:);
        v1 = jac(2,:);
        jacComp = jac([1 2],:);
       
        
end


normJac = cross(v1,v2)/norm(cross(v1,v2));
tau1Jac = cross(normJac,v2)/norm(cross(normJac,v2));
tau2Jac = cross(v1,normJac)/norm(cross(v1,normJac));




loadJac = [normJac',tau1Jac',tau2Jac']*norm(cross(jacComp(1,:),jacComp(2,:)));

end