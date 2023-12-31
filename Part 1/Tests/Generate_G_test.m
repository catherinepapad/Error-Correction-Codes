



% Define parameters
n = 6; % Length of codeword
k = 3; % Message length

% Generate systematic generator matrix G with a large minimum Hamming distance

I_k = eye(k); % Identity matrix of size k

% Create a matrix P with rows carefully chosen to maximize minimum Hamming distance
P = generatePMatrix(n, k );  % k x (n-k) dimentions

% Generate the systematic generator matrix G
G = [I_k, P]

d_min = findMinHammingDistance(G)

