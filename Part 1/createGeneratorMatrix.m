function [G , H , d_min] = createGeneratorMatrix(n,k, options)
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
   
    % Input validation
    arguments (Input)
        n                       (1,1)   double  {mustBeInteger, mustBePositive}
        k                       (1,1)   double  {mustBeInteger, mustBePositive, mustBeGreaterThanOrEqual(k,2)}
        options.maxAttempts     (1,1)   double  {mustBeInteger, mustBePositive}
    end

    % Output validation
    arguments (Output)
        G                       (:,:)   double  {mustBeMember(G, [0, 1])} 
        H                       (:,:)   double  {mustBeMember(H, [0, 1])} 
        d_min                   (1,1)   double  {mustBeInteger, mustBePositive} 
    end

    if ( n < k )
        error("n should be larger than k");
    end

    % Generate systematic generator matrix G with a large minimum Hamming distance
    
    I_k = eye(k); % Identity matrix of size k
    
    % Create a matrix P with rows carefully chosen to maximize minimum Hamming distance
    P = generatePMatrix(n, k );  % k x (n-k) dimentions
    
    % Generate the systematic generator matrix G
    G = [I_k, P];    

    % Generate the parity check matrix H
    H = [ P'  eye(n-k) ];


    % Generate all possible binary vectors of length k
    binary_vectors = dec2bin(0:2^k-1, k) - '0';
    % Generate all possible codewords
    all_codewords = mod(binary_vectors*G,2) ;

    % Calculate the minimum Hamming distance of the generated code
    d_min = findMinHammingDistance(all_codewords);

    % pdist(all_codewords, 'hamming') * size(all_codewords, 2)

end