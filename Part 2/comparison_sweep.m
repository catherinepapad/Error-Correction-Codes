close all
clear
clc


% Define LDPC configurations for different epsilon values
ldpc_configurations = {
    struct('Lambda', [0 1323 177], 'Rho', [0 0 0 0 0 1 453],'epsilon', 0.2)  
    struct('Lambda', [0 1323 177], 'Rho', [0 1 0 0 635],    'epsilon', 0.3)       
    struct('Lambda', [0 1015 485], 'Rho', [0 0 0 0 697],    'epsilon', 0.4)       
};

epsilon_list = logspace(-2, log10(0.5), 50);
sim_iterations = 100;

num_ldpc = length(ldpc_configurations);

irregular_erasure_rates = zeros(num_ldpc, length(epsilon_list));
irregular_failure_rates = zeros(num_ldpc, length(epsilon_list));


% Simulation loop for each LDPC configuration
for ldpc_index = 1:num_ldpc
    Lambda = ldpc_configurations{ldpc_index}.Lambda;
    Rho = ldpc_configurations{ldpc_index}.Rho;
    ldpc_epsilon = ldpc_configurations{ldpc_index}.epsilon

    % Create LDPC matrix and generator matrix
    [H, G] = createLdpcFromPoly(Lambda, Rho);

    % Simulation loop over epsilon values
    for i = 1:length(epsilon_list)
        epsilon = epsilon_list(i);
        
        % Simulate LDPC for current configuration and epsilon
        [erasure_rate, failure_rate] = simulateLdpc(H, G, epsilon, sim_iterations);
        
        % Store results in respective arrays
        irregular_erasure_rates(ldpc_index, i) = erasure_rate;
        irregular_failure_rates(ldpc_index, i) = failure_rate;
    end


end

% Legend in latex format
legends_string = arrayfun( @(ldpc_index) sprintf("$\\epsilon$=%.1f", ldpc_configurations{ldpc_index}.epsilon) , 1:num_ldpc) ;

% Log scale 
figure;
hold on
set(gca, 'YScale', 'log');
for ldpc_index = 1:num_ldpc
    plot(epsilon_list, irregular_erasure_rates(ldpc_index,:));
end
xlabel('Channel Erasure Probability');
ylabel('BER');
title('BER comparison for different  LDPC codes');
legend(legends_string,'interpreter','latex','Location','best');


% Log scale 
figure;
hold on
for ldpc_index = 1:num_ldpc
    plot(epsilon_list, irregular_erasure_rates(ldpc_index,:));
end
xlabel('Channel Erasure Probability');
ylabel('BER');
title('BER comparison for different  LDPC codes');
legend(legends_string,'interpreter','latex','Location','best');


