function P = generatePMatrix(n, k, target_dmin, maxAttempts)
% generatePMatrix - Generate a matrix P for linear block code with maximum
%                   minimum Hamming distance.
%
%   P = generatePMatrix(n, k, target_dmin, maxAttempts) generates a binary
%   matrix P of size k-by-(n-k) for a systematic linear block code with
%   codeword length n and message length k. The function aims to maximize
%   the minimum Hamming distance between codewords, subject to the
%   constraint specified by the target_dmin parameter.
%
%   Parameters:
%       n           - Codeword length (positive integer).
%       k           - Message length (positive integer, greater than or equal to 2).
%       target_dmin - Target minimum Hamming distance (positive integer,
%                     default is Singleton_bound if not provided).
%       maxAttempts - Maximum number of attempts to generate P (positive integer, default is 500).
%
%   Output:
%       P           - Binary matrix of size k-by-(n-k) representing the
%                     matrix P in the systematic generator matrix [I_k | P].
%
%   Note:
%       If n equals k, the code is trivial (identity matrix I_k), and P is
%       returned as an empty matrix. The function uses a randomized approach
%       to generate P, iteratively attempting to maximize the minimum Hamming
%       distance. The process stops if the specified target_dmin is reached
%       or the maximum number of attempts is exhausted. A message is displayed
%       if the code is found to be perfect, reaching the upper bound for dmin.
%
%   Example1:
%       n = 7; % Codeword length
%       k = 4; % Message length
%       target_dmin = 3;
%       maxAttempts = 1000;
%       P = generatePMatrix(n, k, target_dmin, maxAttempts);
%
%   Example2:
%       % Example: Generating a Systematic Generator Matrix with a Large Minimum Hamming Distance
%
%       % Define parameters
%       n = 8; % Codeword length
%       k = 4; % Message length
%
%       disp('Parameters:')
%       disp(['n: ' num2str(n)]);
%       disp(['k: ' num2str(k)]);
%
%       % Generate a systematic generator matrix G with a large minimum Hamming distance
%
%       % Step 1: Generate the matrix P
%       disp('Generating matrix P:');
%       P = generatePMatrix(n, k);
%
%       % Display the generated matrix P
%       disp('Generated matrix P:');
%       disp(P);
%
%       % Step 2: Create the identity matrix I_k
%       I_k = eye(k);
%
%       % Step 3: Combine I_k and P to form the systematic generator matrix G
%       disp('Generating the systematic generator matrix G:');
%       G = [I_k, P];
%
%       % Display the systematic generator matrix G
%       disp('Generated systematic generator matrix G:');
%       disp(G);
%
%       % Calculate the minimum Hamming distance of the generated code
%       d_min = findMinHammingDistance(G);
%       disp(['Minimum Hamming Distance (d_min): ' num2str(d_min)]);
%
%       % Additional information
%       disp('Note: The code is generated to maximize the minimum Hamming distance.');
%       disp('The function uses a randomized approach with a default maximum number of attempts (500).');
%
%
%   See also:
%       findMinHammingDistance

    arguments
        n               (1,1)   {mustBeInteger, mustBePositive}
        k               (1,1)   {mustBeInteger, mustBePositive, mustBeGreaterThanOrEqual(k,2)}
        target_dmin     (1,1)   {mustBeInteger, mustBePositive} = getTargetDmin(n, k)
        maxAttempts     (1,1)   {mustBeInteger, mustBePositive} = 500
    end
    
    % If n==k then the code is just I_k and thus P is empty 
    if (n == k)
        P = [];
        return;
    end
    
    % Perform row operations to maximize minimum Hamming distance
    % P = rref(P);  % This might also be a fancy idea
    
    bestP = [];
    best_dmin = -1;


    I_k = eye(k); % Identity matrix of size k
    % Generate all possible binary vectors of length k
    binary_vectors = dec2bin(0:2^k-1, k) - '0';
    
    for attempt = 1:maxAttempts
        % Generate a random matrix
        currentP = randi([0, 1], k, n - k);
    
        % Extraaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
        G = [I_k, currentP];
        all_codewords = mod(binary_vectors*G,2) ;

        current_dmin = findMinHammingDistance(all_codewords) ; 
    
        % Update the best solution if the current one is better
        if current_dmin > best_dmin
            best_dmin = current_dmin;
            bestP = currentP;
            if best_dmin == target_dmin
                % disp("The code is perfect!") %This means that it reaches the upper bound 
                break
            end
        end
    end
    
    % Return the best solution found
    P = bestP;
    
end

function target_dmin = getTargetDmin(n, k)
    % Calculate the Singleton bound
    if k <= 2
        % Special case
        Singleton_bound = n ;
    else
        Singleton_bound = n - k + 1 ;
    end
    
    % Use the Singleton bound as the default target_dmin
    target_dmin = Singleton_bound;
end
