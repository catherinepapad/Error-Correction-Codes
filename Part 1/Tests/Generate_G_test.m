



% Define parameters
n = 7; % Length of codeword
k = 4; % Message length

% Generate systematic generator matrix G with a large minimum Hamming distance

I_k = eye(k); % Identity matrix of size k

% Create a matrix P with rows carefully chosen to maximize minimum Hamming distance
P = generatePMatrix(n, k);  % k x (n-k) dimentions

% Generate the systematic generator matrix G
G = [I_k, P]

d_min = findMinHammingDistance(G)



function P = generatePMatrix_old(n, k)
    arguments
        n (1,1) {mustBeInteger,mustBePositive}
        k (1,1) {mustBeInteger,mustBePositive}
    end
    if ~(n>k)
        error("n must be greater than k  (n>k)")
    end
    
    % Generate a random matrix
    P = randi([0, 1], k, n - k);


    % % Perform row operations to maximize minimum Hamming distance
    % P = rref(P);  % This might also be a fancy idea

    % Ensure that columns are linearly independent
    while rank(P) < min(k , n - k)
        P = randi([0, 1], k, n - k);
    end
end


function P = generatePMatrix(n, k, maxAttempts)
    arguments
        n               (1,1) {mustBeInteger,mustBePositive}
        k               (1,1) {mustBeInteger,mustBePositive}
        maxAttempts     (1,1) {mustBeInteger,mustBePositive} = 500
    end
    if ~(n > k)
        error("n must be greater than k (n > k)")
    end
    if (k == 1)
        error("k can not be 1, it must be k>1")
    end

    bestP = [];
    best_dmin = -1;



    % The minus 2 at the end is because we check only for the matrix P 
    if k <= 2 
        % This is a special case 
        Singleton_bound = n - 2 ;
    else
        Singleton_bound = n-k+1 -2 ;
    end


    for attempt = 1:maxAttempts
        % Generate a random matrix
        currentP = randi([0, 1], k, n - k);
            
        current_dmin = findMinHammingDistance(currentP) ; 

        % Update the best solution if the current one is better
        if current_dmin > best_dmin
            best_dmin = current_dmin;
            bestP = currentP;
            if best_dmin == Singleton_bound 
                disp("The code is perfect <============================")
                attempt
                break
            end
        end
    end

    % Return the best solution found
    P = bestP;
end



function d_min = findMinHammingDistance(G)
    arguments
        G (:,:) {mustBeInteger}
    end
    % Calculate pairwise Hamming distances using pdist
    distances = pdist(G, 'hamming');

    % Find the minimum Hamming distance
    d_min = min(distances) * size(G, 2);
end






