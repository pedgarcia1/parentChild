function [ CTFluidos,nCREqFluidos] = getCTFluidos( CRFluidos,preCondCTFluidos,nDofTot_P )
nCREqFluidos = sum(sum(CRFluidos ~= 0,2) - ones(size(CRFluidos,1),1));           
nSlavesPerMaster = sum(CRFluidos ~= 0,2) - ones(size(CRFluidos,1),1);             %% Se fija si son 2, 3 o n nodos que comparten la misma presion.
nCRFluidos   = size(CRFluidos,1);
CTFluidos = zeros(nCREqFluidos,nDofTot_P);
iFila = 1;

for iCR = 1:nCRFluidos
    nEquations  = nSlavesPerMaster(iCR);
    for iEq = 1:nEquations
        CTFluidos(iFila,[CRFluidos(iCR,1) CRFluidos(iCR,iEq + 1)]) = preCondCTFluidos*[-1 1];
        iFila = iFila + 1;
    end
end

end

