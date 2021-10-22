function [DHDTHpert_param, DHDQpert_param, DMDTHpert_param, DMDQpert_param] = param_jac(DHDTHpert, DHDQpert, DMDTHpert, DMDQpert, H_pert_T)

param_method = 1;

%FIND TOP OF CONVECTION
for k = 1,kmax
    
    if ( abs(H_pert_T(k)) > 1.0e-8 )

        CON_TOP = k;

        break

    end

end

if param_method == 1

    DHDTHpert_param = zeros(size(DHDTHpert));
    DHDQpert_param = zeros(size(DHDQpert));
    DMDTHpert_param = zeros(size(DMDTHpert));
    DMDQpert_param = zeros(size(DMDQpert));


    for i = 1:length(DHDTHpert)-1

        DHDTHpert_param(i,i+1) = DHDTHpert(i,i+1);
        DHDTHpert_param(i+1,i) = DHDTHpert(i+1,i);

        DHDQpert_param(i,i+1) = DHDQpert(i,i+1);
        DHDQpert_param(i+1,i) = DHDQpert(i+1,i);

        DMDTHpert_param(i,i+1) = DMDTHpert(i,i+1);
        DMDTHpert_param(i+1,i) = DMDTHpert(i+1,i);

        DMDQpert_param(i,i+1) = DMDQpert(i,i+1);
        DMDQpert_param(i+1,i) = DMDQpert(i+1,i);

    end

elseif param_method == 2
    
    
    
    
end