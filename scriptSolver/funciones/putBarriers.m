function [ properties ] = putBarriers( properties)
properties.Ev = properties.EvD;
properties.Eh = properties.EhD;
properties.NUv = properties.NUvD;
properties.NUh = properties.NUhD;
properties.depth = properties.depthD;

for nL = 1:size(properties.EvL,2)
    posL = sum(properties.depth <= properties.depthL(nL));
    properties.Ev = [[properties.Ev(1:posL), properties.Ev(posL)],[properties.EvL(nL),properties.EvL(nL)],[properties.Ev(posL+1),properties.Ev(posL+1:end)]]; 
    properties.Eh = [[properties.Eh(1:posL), properties.Eh(posL)],[properties.EhL(nL),properties.EhL(nL)],[properties.Eh(posL+1),properties.Eh(posL+1:end)]]; 
    properties.NUv = [[properties.NUv(1:posL), properties.NUv(posL)],[properties.NUvL(nL),properties.NUvL(nL)],[properties.NUv(posL+1),properties.NUv(posL+1:end)]]; 
    properties.NUh = [[properties.NUh(1:posL), properties.NUh(posL)],[properties.NUhL(nL),properties.NUhL(nL)],[properties.NUh(posL+1),properties.NUh(posL+1:end)]]; 
    properties.depth = [properties.depth(1:posL),[properties.depthL(nL)-properties.eT(nL),properties.depthL(nL),properties.depthL(nL)+ properties.eL(nL),properties.depthL(nL)+ properties.eL(nL)+properties.eT(nL)],properties.depth(posL+1:end)];
end
end

