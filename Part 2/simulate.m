
% Create irregular LDPC code
r_avg = 6.5;
l_max = 6;
epsilon = 0.05;

% Get the distribution of the degree polynomials
[rho, lambda] = optimizeLDPC(r_avg, l_max, epsilon);

% Find the degree polynomials for given codeword length (n)
n = 210;
[Lambda,Rho] = findLdpcPolynomials(rho, lambda, n);

% Create a regular LDPC code with the same rate and codeword 
% length as the irregular code
k = n-sum(Rho);
rmax = find(rho, 1, 'last');
lmax = find(lambda, 1, 'last');
desired_code_rate = k/n;
[Reg_Lambda, Reg_Rho] = createRegularLdpc(n, desired_code_rate, rmax, lmax);
Reg_n = sum(Reg_Lambda);
Reg_k = Reg_n-sum(Reg_Rho);

% Simulate the performance of the irregular and regular LDPC codes
LDPC_iterations = 20;
sim_iterations = 1000;

irregular_failure_rates = zeros(LDPC_iterations, 1);
irregular_erasure_rates = zeros(LDPC_iterations, 1);
for i = 1:LDPC_iterations
    [irregular_erasure_rates(i), irregular_failure_rates(i)] = simulateLdpcRandom(Lambda, Rho, epsilon, sim_iterations);
end

regular_failure_rates = zeros(LDPC_iterations, 1);
regular_erasure_rates = zeros(LDPC_iterations, 1);
for i = 1:LDPC_iterations
    [regular_erasure_rates(i), regular_failure_rates(i)] = simulateLdpcRandom(Reg_Lambda, Reg_Rho, epsilon, sim_iterations);
end

% Plots!
Irregular_Lambda_string = polyToString(Lambda);
Irregular_Rho_string = polyToString(Rho);

Regular_Lambda_string = polyToString(Reg_Lambda);
Regular_Rho_string = polyToString(Reg_Rho);

% Plot the distribution of the erasure rates for irregular and regular LDPC
figure;
histogram(irregular_erasure_rates, 'Normalization', 'probability');
hold on;
histogram(regular_erasure_rates, 'Normalization', 'probability');
title( ... 
    sprintf('epsilon=%g\n IrrLDPC(%d,%d): IrrLambda = %s , IrrRho = %s\n RegLDPC(%d,%d): RegLambda = %s , RegRho = %s\n LDPCs=%d, %d simulations each', ...
    epsilon, n, k, Irregular_Lambda_string, Irregular_Rho_string, Reg_n, Reg_k, Regular_Lambda_string, Regular_Rho_string, LDPC_iterations, sim_iterations));
xlabel('Erasure rate');
ylabel('Probability');
legend('Irregular', 'Regular');

% Plot the distribution of the failure rates for irregular and regular LDPC
figure;
histogram(irregular_failure_rates, 'Normalization', 'probability');
hold on;
histogram(regular_failure_rates, 'Normalization', 'probability');
title( ... 
    sprintf('epsilon=%g\n IrrLDPC(%d,%d): IrrLambda = %s , IrrRho = %s\n RegLDPC(%d,%d): RegLambda = %s , RegRho = %s\n LDPCs=%d, %d simulations each', ...
    epsilon, n, k, Irregular_Lambda_string, Irregular_Rho_string, Reg_n, Reg_k, Regular_Lambda_string, Regular_Rho_string, LDPC_iterations, sim_iterations));
xlabel('Failure rate');
ylabel('Probability');
legend('Irregular', 'Regular');


function poly_string = polyToString(poly)
    % Create a string for the polynomial in the form 1 + x^a + x^b + ...
    poly_string = sprintf('%dx^{%d}', poly(find(poly, 1)), find(poly, 1));
    for i = find(poly, 1)+1:length(poly)
        if poly(i) == 0
            continue
        end
        poly_string = strcat(poly_string, sprintf(' + %dx^{%d}', poly(i), i));
    end
end

function [erasure_rates, failure_rates] = simulateLdpcAll(Lambda, Rho)
    % Simulates the performance of a single LDPC code by simulating all
    % possible erasure permutations

    [H, G] = createLdpcFromPoly(Lambda, Rho);

    [k, n] = size(G);

    failure_rates = ones(1, n);
    erasure_rates = ones(1, n);
    for i = 1:n
        NaNs_arrays = nchoosek(1:n, i);
        exit_flag = true;
        n_failures = 0;
        n_erasures = 0;
        for NaNs = NaNs_arrays'
            % Create random message
            message = zeros(1, k);

            % Encode message
            codeword = mod(message*G, 2);

            codeword(NaNs) = NaN;

            % Decode received message
            decoded = decodeLDPC(H, codeword, 1000, false);

            new_erasures = sum(isnan(decoded));
            n_erasures = n_erasures + new_erasures;
            if new_erasures > 0
                n_failures = n_failures + 1;
            else
                exit_flag = false;
            end
        end
        if (exit_flag)
            i
            break
        end
        failure_rates(i) = n_failures / length(NaNs_arrays);
        erasure_rates(i) = n_erasures / (length(NaNs_arrays) * n);
    end
end

% Uses random simulation, currently unused
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
    for i = 1:sim_iterations
        % Create codeword
        codeword = zeros(1, n);

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
        decoded = decodeLDPC(H, received, 1000, false);

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
