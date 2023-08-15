function [cohesivos] = updateCohesivoNorm2(cohesivos,dNIter,dNPrev,iCohesivo,iTime,iPg)

%% VARIABLES A UTILIZAR DEL iCohesivo
deadFlag        = cohesivos.deadFlag(iCohesivo,iPg);
firstDmgFlag    = cohesivos.firstDmgFlagN(iCohesivo,iPg);
dN1             = cohesivos.dN1(iCohesivo,iPg);
damageFlag      = cohesivos.damageFlagN(iCohesivo,iPg);
dN0             = cohesivos.dN0(iCohesivo,iPg);
lastPositiveKn  = cohesivos.lastPositiveKn(iCohesivo,iPg);
highEFlag       = cohesivos.highEFlag(iCohesivo,iPg);

%% ALGORITMO %%

%a diferencia de la version anterior, al pedirle cohesivos como output, modifico/actualizo el valor de highEFlag
[Kn,cohesivos] = linearKnCohesivos(cohesivos,dNIter,dNPrev,0,iCohesivo,iPg,iTime);

if dNIter < 0
    positiveFlag = 0;
else
    if highEFlag == 0
        lastPositiveKn = Kn;
    else
        Kn = lastPositiveKn; %%% Si sucede que converge con un Kn Alto(asociado a dNIter negativo) pero el dNIter es positivo. Que el Kn de este tiempo sea enrealidad el ultimo positivo.
        cohesivos.discrepFlag(iCohesivo,iTime) = 1;
    end
    positiveFlag = 1;
    if dNIter <= dNPrev
        if damageFlag == 1
            dN1         = dNPrev;
            damageFlag  = 0;
        end
    else
        if dNIter < dN1
        else
            firstDmgFlag = 1;
            if dNIter > dN0
                deadFlag = 1;
            else
                damageFlag = 1;
            end
        end
    end
end

cohesivos.positiveFlag(iCohesivo,iPg)        = positiveFlag;
cohesivos.dN1(iCohesivo,iPg)                 = dN1;
cohesivos.damageFlagN(iCohesivo,iPg)         = damageFlag;
cohesivos.deadFlag(iCohesivo,iPg)            = deadFlag;
cohesivos.KnIter(iCohesivo,iPg)              = Kn;
cohesivos.lastPositiveKn(iCohesivo,iPg)      = lastPositiveKn;
cohesivos.dNMat(iCohesivo,iPg)               = dNIter;
cohesivos.firstDmgFlagN(iCohesivo,iPg)       = firstDmgFlag;


end