function [G , H , d_min] = createGeneratorMatrix(n,k)
%UNTITLED12 Summary of this function goes here
%   Detailed explanation goes here
   
    arguments
        n               (1,1) {mustBeInteger, mustBePositive}
        k               (1,1) {mustBeInteger, mustBePositive, mustBeGreaterThanOrEqual(k,2)}
    end

    % Generate systematic generator matrix G with a large minimum Hamming distance
    
    I_k = eye(k); % Identity matrix of size k
    
    % Create a matrix P with rows carefully chosen to maximize minimum Hamming distance
    P = generatePMatrix(n, k );  % k x (n-k) dimentions
    
    % Generate the systematic generator matrix G
    G = [I_k, P];
    

    d_min = findMinHammingDistance(G);

    % Add this ! 
    H = 0; 

end