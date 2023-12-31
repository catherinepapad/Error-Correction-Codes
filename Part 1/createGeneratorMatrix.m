function [G , H , d_min] = createGeneratorMatrix(n,k)
% createGeneratorMatrix - Generate systematic generator matrix and parity
%                         check matrix for a linear block code.
%
%   [G, H, d_min] = createGeneratorMatrix(n, k) generates a systematic
%   generator matrix G, a parity check matrix H, and calculates the minimum
%   Hamming distance d_min for a linear block code with codeword length n
%   and message length k.
%
%   Parameters:
%       n     - Codeword length (positive integer).
%       k     - Message length (positive integer, greater than or equal to 2).
%
%   Outputs:
%       G     - Systematic generator matrix [I_k | P], where P is chosen
%               to maximize minimum Hamming distance.
%       H     - Parity check matrix [P' | I_(n-k)] for the code.
%       d_min - Minimum Hamming distance of the generated code.
%
%   Example:
%       n = 8;  % Codeword length
%       k = 4;  % Message length
%       [G, H, d_min] = createGeneratorMatrix(n, k);
% 
%   See also:
%       generatePMatrix, findMinHammingDistance
   
    arguments
        n       (1,1)   {mustBeInteger, mustBePositive}
        k       (1,1)   {mustBeInteger, mustBePositive, mustBeGreaterThanOrEqual(k,2)}
    end

    % Generate systematic generator matrix G with a large minimum Hamming distance
    
    I_k = eye(k); % Identity matrix of size k
    
    % Create a matrix P with rows carefully chosen to maximize minimum Hamming distance
    P = generatePMatrix(n, k );  % k x (n-k) dimentions
    
    % Generate the systematic generator matrix G
    G = [I_k, P];    

    % Generate the parity check matrix H
    H = [ P'  eye(n-k) ];

    % Calculate the minimum Hamming distance of the generated code
    d_min = findMinHammingDistance(G);

end