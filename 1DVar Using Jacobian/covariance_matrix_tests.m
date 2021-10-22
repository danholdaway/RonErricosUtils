close all
clear
clc

covariance_matrix

[X,Lam] = eig(B);
[U,S,V] = svd(B);

lambda = diag(Lam); clear Lam
sigma = diag(S); clear S

%Rank test
condB = max(sigma)/min(sigma);

fprintf('Cond(B) = %g \n\n', condB)

%POS DEF TEST
if min(min(B-B')) == 0 && max(max(B-B')) == 0
    fprintf('B is Hermitian \n\n')
else
    fprintf('B is NOT Hermitian \n\n')
end

%POS DEF TEST
if min(lambda) >= 0
    fprintf('B is positive definite \n\n')
else
    fprintf('B is NOT positive definite \n')
    fprintf('  Min eigenvalue = %g \n\n', min(lambda))
end

cd ../../Convection/GEOS5_ras_code/Jacobians/_i6j28_/0.0001p
HeatingRate_pert_T
JAC_DHDTHpert
JAC_DHDQpert
JAC_DMDTHpert
JAC_DMDQpert
cd ../../../../../Data' Assimilation'/1DVar' Using Jacobian'/

figure
contour(DHDTHpert)
% figure
% contour(DHDQpert)
% figure
% contour(DMDTHpert)
% figure
% contour(DMDQpert)

for i = 59:71
figure(2)
hold on
plot(DHDTHpert(:,i))
end

asd

[DHDTHpert_param, DHDQpert_param, DMDTHpert_param, DMDQpert_param] = param_jac(DHDTHpert, DHDQpert, DMDTHpert, DMDQpert, H_pert_T);


H = [DHDTHpert DHDQpert ; DMDTHpert DMDQpert];
H_param = [DHDTHpert_param DHDQpert_param ; DMDTHpert_param DMDQpert_param];

%clear DHDTHpert DHDQpert DMDTHpert DMDQpert

HBHT = H*B*H';
HBHT_param = H_param*B*H_param';


R_diag = 4*diag(HBHT);
% R_diag_param = 4*diag(HBHT_param);

%Fill R so that it has no zeros
R_t = R_diag(1:72);
R_q = R_diag(73:end);
% R_t_param = R_diag_param(1:72);
% R_q_param = R_diag_param(73:end);

count_t = 0;
count_q = 0;
% count_t_param = 0;
% count_q_param = 0;

for i = 1:72
    
    if R_t(i) == 0
        count_t = count_t + 1; 
    else
        break
    end

end
    
for i = 1:72
    
    if R_q(i) == 0
        count_q = count_q + 1; 
    else
        break
    end

end

% for i = 1:72
%     
%     if R_t_param(i) == 0
%         count_t_param = count_t_param + 1; 
%     else
%         break
%     end
% 
% end
%     
% for i = 1:72
%     
%     if R_q_param(i) == 0
%         count_q_param = count_q_param + 1; 
%     else
%         break
%     end
% 
% end

R_t(1:count_t) = R_t(count_t + 1);
R_q(1:count_q) = R_q(count_q + 1);
% R_t_param(1:count_t_param) = R_t_param(count_t_param + 1);
% R_q_param(1:count_q_param) = R_q_param(count_q_param + 1);

R = diag([R_t ; R_q]);
% R_param = diag([R_t_param ; R_q_param]);

K = B*H'/(H*B*H' + R);

K_param = B*H_param'/(H_param*B*H_param' + R);

%Maxvals
maxK = max(max([K ; K_param]));
minK = min(min([K ; K_param]));

contour(K)
colorbar
caxis([minK maxK])

figure
contour(K_param)
colorbar
caxis([minK maxK])


