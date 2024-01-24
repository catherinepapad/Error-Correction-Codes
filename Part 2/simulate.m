
% Clear the workspace
% clear all; close all; clc;

% Create irregular LDPC code
r_avg = 4.5;
r = floor(r_avg);
l_max = 10;
epsilon = 0.05;
interval = 0.01;

[rho, lambda] = optimizeLDPC(r, r_avg, l_max, epsilon, interval);


n = 32;
[Lambda,Rho] = findLdpcPolynomials(rho, lambda, n);


LDPC_iterations = 100;
sim_iterations = 10000;

failure_rates = zeros(1,LDPC_iterations);

for i = 1:LDPC_iterations
    failure_rates(i) = simulateLdpcSingle(Lambda, Rho, epsilon, sim_iterations);
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


function failure_rate = simulateLdpcSingle(Lambda, Rho, epsilon, sim_iterations)
    % Simulates a single LDPC code with given parameters
    % Returns the bit error rate
    failure_rate = 0;
    [H, G] = createLdpcFromPoly(Lambda, Rho);
    for i = 1:sim_iterations
        % Create random message
        message = randi([0 1], 1, size(G,1));

        % Encode message
        codeword = mod(message*G, 2);

        % Create binary erasure channel with erasure probability epsilon
        received = simulateBinaryErasureChannel(codeword, epsilon);

        % Decode received message
        decoded = decodeLDPC(H, received, 1000, false);

        n_erasures = sum(isnan(decoded));
        if n_erasures > 0
            failure_rate = failure_rate + 1;
        end
    end
    failure_rate = failure_rate/sim_iterations;
end

function x = simulateBinaryErasureChannel(y, epsilon)
    % Given a vector y, returns a vector x where each element of y is
    % replaced with a NaN (erasure) with probability epsilon
    x = y;
    for i = 1:length(y)
        if rand < epsilon
            x(i) = NaN;
        end
    end
end



