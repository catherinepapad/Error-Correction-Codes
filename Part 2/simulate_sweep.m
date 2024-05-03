% r_avg_list = [3.5 4 5 6 7 8];
% epsilon_list = [0.01 0.05:0.05:0.5];
r_avg_list = [8 10];
epsilon_list = [0.3 0.4];
l_max = 10;
n = 100;

min_erasure_rates = zeros(length(r_avg_list), length(epsilon_list));
min_failure_rates = zeros(length(r_avg_list), length(epsilon_list));
code_rates = zeros(length(r_avg_list), length(epsilon_list));


for i = 1:length(r_avg_list)
    for j = 1:length(epsilon_list)
        r_avg = r_avg_list(i);
        epsilon = epsilon_list(j);
    
        % Get the distribution of the degree polynomials
        [rho, lambda] = optimizeLDPC(r_avg, l_max, epsilon);

        % Find the degree polynomials for given codeword length (n)
        [Lambda,Rho] = findLdpcPolynomials(rho, lambda, n);

        code_rates(i, j) = (n - sum(Rho)) / n;

        % Simulate the performance of the irregular and regular LDPC codes
        LDPC_iterations = 100;
        sim_iterations = 200;

        irregular_failure_rates = zeros(LDPC_iterations, 1);
        irregular_erasure_rates = zeros(LDPC_iterations, 1);
        parfor ii = 1:LDPC_iterations
            [irregular_erasure_rates(ii), irregular_failure_rates(ii)] = simulateLdpcRandom(Lambda, Rho, epsilon, sim_iterations);
        end

        min_erasure_rates(i, j) = min(irregular_erasure_rates);
        min_failure_rates(i, j) = min(irregular_failure_rates);
    end

end

% Plot the results, y-axis is the minimum erasure rate, x-axis is the
% erasure probability, and each line is a different r_avg value
figure;
for i = 1:length(r_avg_list)
    plot(epsilon_list, min_erasure_rates(i, :), 'DisplayName', sprintf('r_{avg} = %d', r_avg_list(i)));
    hold on;
end
% Plot diagonal
plot(epsilon_list, epsilon_list, 'DisplayName', 'y = x', 'LineStyle', '--');
xlabel('Channel erasure probability');
ylabel('Erasure rate');
title('Erasure rate of best irregular LDPC instance for different r_{avg} values');
legend('show');

% Same but for y-axis being the code rate
figure;
for i = 1:length(r_avg_list)
    plot(epsilon_list, code_rates(i, :), 'DisplayName', sprintf('r_{avg} = %d', r_avg_list(i)));
    hold on;
end
xlabel('Erasure probability');
ylabel('Code rate');
title('Code rate of irregular LDPC for different r_{avg} values');
legend('show');
