function indexVector = pointsIn3DLine(pointCoords,startingPoint,endingPoint)
    nPoints = size(pointCoords,1);
    
    %%% |dot(p1-p0,p-p0)|/(|p1-p0|*|p-p0|) = 1.0
    
    xi = startingPoint(1);
    xf = endingPoint(1);
    yi = startingPoint(2);
    yf = endingPoint(2);
    zi = startingPoint(3);
    zf = endingPoint(3);
    
    dx=xf-xi;
    dy=yf-yi;
    dz=zf-zi; 
 
   
    

    indexVector = false(size(pointCoords,1),1);
    for iPoint = 1:nPoints
        x = pointCoords(iPoint,1);
        y = pointCoords(iPoint,2);
        z = pointCoords(iPoint,3);
        
        ex=x-xi;
        ey=y-yi;
        ez=z-zi;
        
        if (abs(ex)+abs(ey)+abs(ez))<1e-5
            
            indexVector(iPoint) = true;
            
        else
            q = dx*ex + dy*ey + dz*ez;
            q = q*q;
            q = q / (dx*dx+dy*dy+dz*dz);
            q = q / (ex*ex+ey*ey+ez*ez);
            
            if abs(q - 1)<1e-5
                indexVector(iPoint) = true;
            end
            
        end
        
        
    end
    
       

end