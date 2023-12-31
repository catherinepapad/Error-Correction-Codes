function P = generatePMatrix_old(n, k, target_dmin , maxAttempts)
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
%       target_dmin - Target minimum Hamming distance (positive integer, default is 2).
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
%   Example:
%       n = 7;
%       k = 4;
%       target_dmin = 3;
%       maxAttempts = 1000;
%       P = generatePMatrix(n, k, target_dmin, maxAttempts);
%
%   See also:
%       findMinHammingDistance


    arguments
        n               (1,1) {mustBeInteger,mustBePositive}
        k               (1,1) {mustBeInteger,mustBePositive,mustBeGreaterThanOrEqual(k,2)}
        target_dmin     (1,1) {mustBeInteger,mustBePositive} = 2
        maxAttempts     (1,1) {mustBeInteger,mustBePositive} = 500
    end

    % If n==k then the code is just I_k and thus P is empty 
    if ( n == k )
        P = [];
        return 
    end

    % The minus 2 at the end is because we check only for the matrix P 
    if target_dmin == 2 
        % Find an upper bound for the best dmin 
        if k <= 2 
            % This is a special case 
            Singleton_bound = n - 2 ;
        else
            Singleton_bound = n-k+1 -2 ;
        end
    else
        % This is from the function argument
        Singleton_bound = target_dmin - 2 ; 
    end

    % % Perform row operations to maximize minimum Hamming distance
    % P = rref(P);  % This might also be a fancy idea

    bestP = [];
    best_dmin = -1;

    for attempt = 1:maxAttempts
        % Generate a random matrix
        currentP = randi([0, 1], k, n - k);
            
        current_dmin = findMinHammingDistance(currentP) ; 

        % Update the best solution if the current one is better
        if current_dmin > best_dmin
            best_dmin = current_dmin;
            bestP = currentP;
            if best_dmin == Singleton_bound 
                disp("The code is perfect <============================") %This means that it reaches the upper bound 
                break
            end
        end
    end

    % Return the best solution found
    P = bestP;
end
