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
