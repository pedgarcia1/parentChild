function [Ks,cohesivos,dTS_dN,dTS1_dSksi,dTS1_dSeta] = linearKs1Propante(cohesivos,dSIter,dSPrev,dNIter,iCohesivo,iPg,iTime,propanteProperties)
deadFlag        = cohesivos.deadFlag(iCohesivo,iPg);
Ks0Propante     = propanteProperties.Ks0_1P;

%%% EL CORTE Y EL dNIter DEASCOPLADOS %%%
dTS_dN = 0;
dTS1_dSeta = 0;

%%% apertura final
aperturaFinal = propanteProperties.aperturaFinal(iCohesivo,iPg);


%% ALGORITMO DE DECISION DEL E A TOMAR %%
if deadFlag == 1 %entra el propante
    if dNIter < aperturaFinal %le doy rigidez, esta comprimido
        Ks                         = Ks0Propante;
        dTS1_dSksi                 = Ks0Propante;
    else %no le doy rigidez, no esta comprimido
        Ks                         = 0;
        dTS1_dSksi                 = 0;
    end
else %sigo teniendo cohesivo
    disp('Entrando mal en linearKs1Propante.m')
end
 cohesivos.Ks1Iter(iCohesivo,iPg) = Ks;



end