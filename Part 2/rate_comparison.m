close all
clear
clc

% define LDPC  
Lambda = [0 1323 177];
Rho = [0 0 0 0 0 1 453];
[H, G] = createLdpcFromPoly(Lambda, Rho);

sim_iterations = 100;
n = 1500;

irregular_erasure_rates = zeros(1,length(epsilon_list));
irregular_failure_rates = zeros(1,length(epsilon_list));


% Theoretic limit
code_rate_limit = (n - sum(Rho)) / n;

for i = 1:length(epsilon_list)
    epsilon = epsilon_list(i)
    [irregular_erasure_rates(1,i), irregular_failure_rates(1,i)] = simulateLdpc(H, G, epsilon, sim_iterations);
end

% figure;
% semilogy(epsilon_list(:), irregular_erasure_rates(1,:));
% hold on
% semilogy(epsilon_list(:), irregular_erasure_rates(2,:));
% xlabel('Channel Erasure Probability');
% ylabel('BER');
% title('BER comparison for 2 different  LDPC codes');
% legend('$\epsilon$=0.2','$\epsilon$=0.4','interpreter','latex');

% figure;
% plot(epsilon_list(:), irregular_erasure_rates(1,:));
% hold on
% plot(epsilon_list(:), irregular_erasure_rates(2,:));
% xlabel('Channel Erasure Probability');
% ylabel('BER');
% title('BER comparison for 2 different  LDPC codes');
% legend('$\epsilon$=0.2','$\epsilon$=0.4','interpreter','latex');

