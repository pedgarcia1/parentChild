function [cohesivos] = updateCohesivoShearEta(cohesivos,dSIter,dSPrev,iCohesivo,iTime,iPg)
%% VARIABLES A UTILIZAR DEL iCohesivo
deadFlag        = cohesivos.deadFlag(iCohesivo,iPg);
dS0             = cohesivos.dS0_2(iCohesivo,iPg);
dS1             = cohesivos.dS1_2(iCohesivo,iPg);
damageFlag      = cohesivos.damageFlagS2(iCohesivo,iPg);



%% ALGORITMO %%

[Ks] = linearKs2Cohesivos(cohesivos,dSIter,dSPrev,0,iCohesivo,iPg,iTime);

if dSIter<0
    dSIter = -1*dSIter;
    dSPrev = -1*dSPrev;
end


if dSIter <= dSPrev
    if damageFlag == 1
        dS1         = dSPrev;
        damageFlag  = 0;
    end
else
    if dSIter < dS1
    else
        if dSIter > dS0
            deadFlag = 1;
        else
            damageFlag = 1;
        end
    end
end


cohesivos.dS1_2(iCohesivo,iPg)            = dS1;
cohesivos.damageFlagS2(iCohesivo,iPg)     = damageFlag;
cohesivos.deadFlag(iCohesivo,iPg)         = deadFlag;
cohesivos.Ks2Iter(iCohesivo,iPg)          = Ks;
cohesivos.dS2Mat(iCohesivo,iPg)           = dSIter;


end