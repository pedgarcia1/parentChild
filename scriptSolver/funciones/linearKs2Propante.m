function [Ks,cohesivos,dTS2_dN,dTS_dSksi,dTS_dSeta] = linearKs2Propante(cohesivos,dSIter,dSPrev,dNIter,iCohesivo,iPg,iTime,propanteProperties)
deadFlag        = cohesivos.deadFlag(iCohesivo,iPg);
Ks0Propante     = propanteProperties.Ks0_2P;

%%% EL CORTE Y EL dNIter DEASCOPLADOS %%%
dTS2_dN = 0;
dTS_dSksi = 0;

%%% apertura final
aperturaFinal = propanteProperties.aperturaFinal(iCohesivo,iPg);

%% ALGORITMO DE DECISION DEL E A TOMAR %%
if deadFlag == 1 %entra el propante
    if dNIter < aperturaFinal %le doy rigidez, esta comprimido
        Ks                        = Ks0Propante;
        dTS_dSeta                 = Ks0Propante;
    else %no le doy rigidez, no esta comprimido
        Ks                        = 0;
        dTS_dSeta                 = 0;
    end
else %sigo teniendo cohesivo
   disp('Entrando mal en linearKs2Propante.m')
end
cohesivos.Ks2Iter(iCohesivo,iPg) = Ks;

end