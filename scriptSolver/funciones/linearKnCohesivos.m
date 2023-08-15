function [Kn,cohesivos,dTN_dN,dTN_dSksi, dTN_dSeta] = linearKnCohesivos(cohesivos,dNIter,dNPrev,dSipg,iCohesivo,iPg,iTime)
%% VARIABLES A UTILIZAR DEL iCohesivo
coeficiente = 1;
deadFlag        = cohesivos.deadFlag(iCohesivo,iPg);
TN0             = cohesivos.TN0(iCohesivo,iPg);
TN0             = coeficiente*TN0;
dN0             = cohesivos.dN0(iCohesivo,iPg);
Kn0             = cohesivos.Kn0(iCohesivo,iPg);
KnPropante      = cohesivos.KnPropante(iCohesivo,iPg);
dN1             = cohesivos.dN1(iCohesivo,iPg);
dN10            = cohesivos.dN10(iCohesivo,iPg);
% KnTimes         = cohesivos.KnTimes(iCohesivo,iPg,:);
positiveFlag    = cohesivos.positiveFlag(iCohesivo,iPg);
lastPositiveKn   = cohesivos.lastPositiveKn(iCohesivo,iPg);

%%% EL CORTE Y EL dNIter DEASCOPLADOS %%%
dTN_dSksi = 0;
dTN_dSeta = 0;

%% ALGORITMO DE DECISION DEL Kn Y LAS DERIVADAS 

if iTime == 1
    KnPrevTime = Kn0;
else
    KnPrevTime = cohesivos.KnPrevTime(iCohesivo,iPg);
end




%% ALGORITMO DE DECISION DEL E A TOMAR %%
if deadFlag == 1
    if dNIter < 0
        Kn                             = Kn0;
        dTN_dN                         = Kn0;
        cohesivos.highEFlag(iCohesivo,iPg) = 1;
        if cohesivos.produccionFlag == true
            Kn                              = KnPropante;
            dTN_dN                          = KnPropante;
            cohesivos.highEFlag(iCohesivo,iPg) = 1;
            
        end
    else
        Kn                             = 0;
        dTN_dN                         = 0;
        cohesivos.highEFlag(iCohesivo,iPg) = 0;
    end
else
    if dNIter < 0
        Kn                             = Kn0;
        dTN_dN                         = Kn0;
        cohesivos.highEFlag(iCohesivo,iPg) = 1;
    else
        cohesivos.highEFlag(iCohesivo,iPg) = 0;
        if dNIter <= dNPrev
            Kn      = KnPrevTime;
            dTN_dN  = KnPrevTime;
        else
            if dNIter < dN1
                if positiveFlag == 0
                    Kn      = lastPositiveKn;
                    dTN_dN  = lastPositiveKn;
                else
                    Kn      = KnPrevTime;
                    dTN_dN  = KnPrevTime;
                end
            else
                if dNIter > dN0
                    Kn      = 0;
                    dTN_dN  = 0;
                    cohesivos.elementsFluidosActivos(iCohesivo) = true;
                else
%                     Kn      = 0;
%                     dTN_dN  = 0;
                    cohesivos.elementsFluidosActivos(iCohesivo) = true;
                    Kn = ( -TN0 * (dNIter - dN10) / (dN0 - dN10) + TN0) / dNIter;
                    dTN_dN = -TN0 * dN10/ (dN0-dN10)/ (dNIter^2) - TN0/(dNIter^2);
%                     dTN_dN = (-TN0 / (dN0 - dN10)); MAL
                end
            end
        end
    end
end

 cohesivos.KnIter(iCohesivo,iPg) = Kn;

end