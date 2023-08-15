function [Kn,cohesivos,dTN_dN,dTN_dSksi, dTN_dSeta,propanteProperties] = linearKnPropante(cohesivos,dNIter,dNPrev,dSipg,iCohesivo,iPg,iTime,propanteProperties)
%% VARIABLES A UTILIZAR DEL iCohesivo
deadFlag        = cohesivos.deadFlag(iCohesivo,iPg);
KnPropante      = propanteProperties.KnP;

%%% EL CORTE Y EL dNIter DEASCOPLADOS %%%
dTN_dSksi = 0;
dTN_dSeta = 0;

%%% apertura final
aperturaFinal = propanteProperties.aperturaFinal(iCohesivo,iPg);

%% ALGORITMO DE DECISION DEL E A TOMAR %%
if deadFlag == 1 %entra el propante
    if dNIter < aperturaFinal*1 %si esta "cerca" de ser un Gap y cerrarse hasta menos de aperturaFinal, tiene rigidez. Ayuda a la convergencia. La otra opcion es que si aplica rigidez en alguna iteracion, dejarla prendida para siempre.
        Kn                             = KnPropante;
        dTN_dN                         = KnPropante;
        propanteProperties.cierreFlag(iCohesivo,iPg) = 1;
        cohesivos.highEFlag(iCohesivo,iPg)  = 1;
    elseif propanteProperties.cierreFlag(iCohesivo,iPg) == 1;
        Kn                             = KnPropante;
        dTN_dN                         = KnPropante;
        
    else %si no se cierra mas que lo que fijo, tiene rigidez 0
        Kn                             = 0;
        dTN_dN                         = 0;
        cohesivos.highEFlag(iCohesivo,iPg) = 0;
    end
else %si no murio el cohesivo, se sigue portando como un cohesivo
    disp('Entrando mal en linearKnPropante.m')
end

 cohesivos.KnIter(iCohesivo,iPg) = Kn;

end