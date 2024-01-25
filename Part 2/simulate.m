
% Clear the workspace
% clear all; close all; clc;

% Create irregular LDPC code
r_avg = 5.5;
l_max = 5;
epsilon = 0.25;

interval = 0.01;

[rho, lambda] = optimizeLDPC(r_avg, l_max, epsilon, interval);


n = 16;
[Lambda,Rho] = findLdpcPolynomials(rho, lambda, n);

% rate = (n-sum(Rho))/n
% RhoReg = [0 ]

LDPC_iterations = 2;

failure_rates = zeros(1,LDPC_iterations);

for i = 1:LDPC_iterations
    failure_rates(i) = simulateLdpcSingle(Lambda, Rho);
end



% We are interested in the distribution of the BER for a given LDPC code

figure;
histogram(failure_rates, 'Normalization', 'probability');
% Create a string for the polynomial in the form 1 + x^a + x^b + ...
Lambda_string = sprintf('%dx^{%d}', Lambda(find(Lambda, 1)), find(Lambda, 1));
for i = find(Lambda, 1)+1:length(Lambda)
    if Lambda(i) == 0
        continue
    end
    Lambda_string = strcat(Lambda_string, sprintf(' + %dx^{%d}', Lambda(i), i));
end
Rho_string = sprintf('%dx^{%d}', Rho(find(Rho, 1)), find(Rho, 1));
for i = find(Rho, 1)+1:length(Rho)
    if Rho(i) == 0
        continue
    end
    Rho_string = strcat(Rho_string, sprintf(' + %dx^{%d}', Rho(i), i));
end
title( sprintf('LDPC(%d,%d), epsilon=%g\n Lambda = %s , Rho = %s\n LDPCs=%d, %d simulations each', n, n-r, epsilon, Lambda_string, Rho_string, LDPC_iterations, sim_iterations));
xlabel('Failure rate');
ylabel('Probability');


function failure_rate = simulateLdpcSingle(Lambda, Rho)
    error("FIX WHAT THIS RETURNS")
    % Simulates a single LDPC code with given parameters
    % Returns the bit error rate
    failure_rate = 0;
    [H, G] = createLdpcFromPoly(Lambda, Rho);

    n = size(G,1);

    for i = 1:n
        NaNs_arrays = nchoosek(1:n, i);
        exit_flag = true;

        for NaNs = NaNs_arrays'
            % Create random message
            message = zeros(1, n);

            % Encode message
            codeword = mod(message*G, 2);

            codeword(NaNs) = NaN;

            % Decode received message
            decoded = decodeLDPC(H, codeword, 1000, false);

            n_erasures = sum(isnan(decoded));
            if n_erasures > 0
                failure_rate = failure_rate + 1;
                decoded = decodeLDPC(H, codeword, 1000, true);
            else
                exit_flag = false;
            end
        end
        if (exit_flag)
            i
            break
        end
    end

end

