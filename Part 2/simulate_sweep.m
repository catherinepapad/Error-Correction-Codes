r_avg_list = [3.5 4 5 6 7 8];
epsilon_list = [0.01 0.05:0.05:0.5];
% r_avg_list = [8];
% epsilon_list = [0.5];
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


function [erasure_rate, failure_rate] = simulateLdpcRandom(Lambda, Rho, epsilon, sim_iterations)
    % Simulates a single LDPC code with given parameters
    % Returns the bit erasure rate and the word failure rate (% of words 
    % received with at least one erasure)
    n_erasures = 0;
    n_failures = 0;
    n_erasures_EC = 0;
    n_failures_EC = 0;
    [H, G] = createLdpcFromPoly(Lambda, Rho);
    [k, n] = size(G);
    parfor i = 1:sim_iterations
        % Create codeword
        % codeword = randi([0, 1], [1, n]);
        codeword =  zeros(1, n);

        % Simulate binary erasure channel with erasure probability epsilon
        received = codeword;
        received(rand(size(received)) < epsilon) = NaN;

        % Count received erasures
        received_erasures = sum(isnan(received));
        if received_erasures > 0
            n_erasures = n_erasures + received_erasures;
            n_failures = n_failures + 1;
        end

        % Decode received message
        decoded = decodeLDPC(H, received, false);

        % If no erasures, the codeword can be decoded (calculate syndrome etc.)
        % (matlab 'decode' function can do this)
        % If there are erasures, the codeword cannot be decoded

        % Count erasures after error correction
        decoded_erasures = sum(isnan(decoded));
        if decoded_erasures > 0
            n_erasures_EC = n_erasures_EC + decoded_erasures;
            n_failures_EC = n_failures_EC + 1;
        end
    end
    
    erasure_rate = n_erasures_EC / (sim_iterations * n);
    failure_rate = n_failures_EC / sim_iterations;

end
