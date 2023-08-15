function [Ks,cohesivos,dTS_dN,dTS1_dSksi,dTS1_dSeta] = linearKs1Cohesivos(cohesivos,dSIter,dSPrev,dNIter,iCohesivo,iPg,iTime)
coeficiente = 1;
deadFlag        = cohesivos.deadFlag(iCohesivo,iPg);
TS0             = cohesivos.TS0_1(iCohesivo,iPg);
% TS0             = coeficiente*TS0_1;
dS0             = cohesivos.dS0_1(iCohesivo,iPg);
Ks0             = cohesivos.Ks0_1(iCohesivo,iPg);
dS1             = cohesivos.dS1_1(iCohesivo,iPg);
dS10            = cohesivos.dS10_1(iCohesivo,iPg);
% KsTimes         = cohesivos.Ks1Times(iCohesivo,iPg,:);

%%% EL CORTE Y EL dNIter DEASCOPLADOS %%%
dTS_dN = 0;
dTS1_dSeta = 0;

%% ALGORITMO DE DECISION DEL Ks Y LAS DERIVADAS 

if iTime == 1
    KsPrevTime = Ks0;
else
    KsPrevTime = cohesivos.Ks1PrevTime(iCohesivo,iPg);
end

%% ALGORITMO DE DECISION DEL E A TOMAR %%
if deadFlag == 1
    Ks                             = 0;
    dTS1_dSksi                         = 0;
else
    if dSIter < 0 %% dSIter NEGATIVO
        dSIter       = -dSIter;
        dSPrev       = -dSPrev;
    end
    cohesivos.highEFlag(iCohesivo,iPg) = 0;
    if dSIter <= dSPrev
        Ks      = KsPrevTime;
        dTS1_dSksi  = KsPrevTime;
    else
        if dSIter < dS1
                Ks      = KsPrevTime;
                dTS1_dSksi  = KsPrevTime;
        else
            if dSIter > dS0
                Ks      = 0;
                dTS1_dSksi  = 0;
            else
                Ks = ( -TS0 * (dSIter - dS10) / (dS0 - dS10) + TS0) / dSIter;
                dTS1_dSksi = -TS0 * dS10 / (dS0 - dS10) / (dSIter^2) - TS0/ (dSIter^2);
%                 dTS1_dSksi = (-TS0 / (dS0 - dS10)); MAL
            end
        end
    end
end
 cohesivos.Ks1Iter(iCohesivo,iPg) = Ks;



end