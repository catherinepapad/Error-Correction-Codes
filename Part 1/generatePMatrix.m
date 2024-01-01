function P = generatePMatrix(n, k, options)
% generatePMatrix - Generate a matrix P for linear block code with maximum
%                   minimum Hamming distance.
%
%   P = generatePMatrix(n, k, 'target_dmin', target_dmin, 'maxAttempts', maxAttempts)
%   generates a binary matrix P of size k-by-(n-k) for a systematic linear
%   block code with codeword length n and message length k. The function aims
%   to maximize the minimum Hamming distance between codewords, subject to the
%   constraints specified by the target_dmin and maxAttempts parameters.
%
%   Parameters:
%       n           - Codeword length (positive integer).
%       k           - Message length (positive integer, greater than or equal to 2).
%   options:
%       'target_dmin' - Target minimum Hamming distance (positive integer,
%                      default is n - k + 1).
%       'maxAttempts' - Maximum number of attempts to generate P (positive
%                      integer, default is 500).
%
%   Output:
%       P           - Binary matrix of size k-by-(n-k) representing the matrix
%                     P in the systematic generator matrix [I_k | P].
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
%       P = generatePMatrix(n, k, 'target_dmin', target_dmin, 'maxAttempts', maxAttempts);
%
%   Example2:
%       % Example: Generating a Systematic Generator Matrix with a Large Minimum
%       % Hamming Distance
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
%       P = generatePMatrix(n, k, 'maxAttempts', 500);
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
%       % Generate all possible binary vectors of length k
%       binary_vectors = dec2bin(0:2^k-1, k) - '0';
%       % Generate all possible codewords
%       all_codewords = mod(binary_vectors*G,2) ;
% 
%       % Calculate the minimum Hamming distance of the generated code
%       d_min = findMinHammingDistance(all_codewords);
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
        n                       (1,1)   double  {mustBeInteger, mustBePositive}
        k                       (1,1)   double  {mustBeInteger, mustBePositive, mustBeGreaterThanOrEqual(k,2)}
        options.target_dmin     (1,1)   double  {mustBeInteger, mustBePositive} = n - k + 1  %getTargetDmin(n, k)
        options.maxAttempts     (1,1)   double  {mustBeInteger, mustBePositive} = 500
    end
    
    % If n==k then the code is just I_k and thus P is empty 
    if (n == k)
        P = [];
        return;
    end    
    
    
    bestP = [];
    best_dmin = -1;

    % Identity matrix of size k
    I_k = eye(k); 
    % Generate all possible binary vectors of length k
    binary_vectors = dec2bin(0:2^k-1, k) - '0';
    
    for attempt = 1:options.maxAttempts
        % Generate a random matrix P
        currentP = randi([0, 1], k, n - k);
    
        % Generate the systematic generator matrix G
        G = [I_k, currentP];
        % Generate all possible codewords
        all_codewords = mod(binary_vectors*G,2) ;

        % Calculate the minimum Hamming distance of the generated code
        current_dmin = findMinHammingDistance(all_codewords) ; 
    
        % Update the best solution if the current one is better
        if current_dmin > best_dmin
            best_dmin = current_dmin;
            bestP = currentP;
            if best_dmin == options.target_dmin
                % disp("The code is perfect!") %This means that it reaches the upper bound 
                break
            end
        end
    end
    
    % Return the best solution found
    P = bestP;
    
end


% function Singleton_bound = getTargetDmin(n, k)
%     % Use the Singleton bound as the default target_dmin
%     % Calculate the Singleton bound    
%     Singleton_bound = n - k + 1 ;
% end
