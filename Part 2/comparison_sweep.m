close all
clear
clc

% define best LDPC for epsilon=0.2 
Lambda1 = [0 1323 177];
Rho1 = [0 0 0 0 0 1 453];
[H1, G1] = createLdpcFromPoly(Lambda1, Rho1);

% define best LDPC for epsilon=0.4
Lambda2 = [0 1015 485];
Rho2 = [0 0 0 0 697];
[H2, G2] = createLdpcFromPoly(Lambda2, Rho2);

epsilon_list = [0.01 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5];
% epsilon_list = [0.1 0.3];

sim_iterations = 50;

irregular_erasure_rates = zeros(2,length(epsilon_list));
irregular_failure_rates = zeros(2,length(epsilon_list));

for i = 1:length(epsilon_list)
    epsilon = epsilon_list(i)
    [irregular_erasure_rates(1,i), irregular_failure_rates(1,i)] = simulateLdpc(H1, G1, epsilon, sim_iterations);
    [irregular_erasure_rates(2,i), irregular_failure_rates(2,i)] = simulateLdpc(H2, G2, epsilon, sim_iterations);
end

% figure;
% semilogy(epsilon_list(:), irregular_erasure_rates(1,:));
% hold on
% semilogy(epsilon_list(:), irregular_erasure_rates(2,:));
% xlabel('Channel Erasure Probability');
% ylabel('BER');
% title('BER comparison for 2 different  LDPC codes');
% legend('$\epsilon$=0.2','$\epsilon$=0.4','interpreter','latex');

figure;
plot(epsilon_list(:), irregular_erasure_rates(1,:));
hold on
plot(epsilon_list(:), irregular_erasure_rates(2,:));
xlabel('Channel Erasure Probability');
ylabel('BER');
title('BER comparison for 2 different  LDPC codes');
legend('$\epsilon$=0.2','$\epsilon$=0.4','interpreter','latex');

