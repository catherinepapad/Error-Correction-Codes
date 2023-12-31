function d_min = findMinHammingDistance(G)
% findMinHammingDistance - Calculate the minimum Hamming distance for a set of codewords.
%
%   d_min = findMinHammingDistance(G) calculates the minimum Hamming distance
%   between all pairs of distinct codewords represented by the matrix G.
%
%   Parameters:
%       G     - Matrix representing codewords, where each row corresponds
%               to a codeword (must be an integer matrix).
%
%   Output:
%       d_min - Minimum Hamming distance, defined as the minimum number of
%               differing coordinates between any two distinct codewords.
%
%   Note:
%       The function uses the 'hamming' metric with the pdist function to
%       calculate pairwise Hamming distances. The result is then scaled by
%       the size of the codewords to obtain the minimum Hamming distance.
%
%   Example:
%       G = [1 0 1; 0 1 1; 1 1 0]; % Example codewords
%       d_min = findMinHammingDistance(G); % Expected output is 2 
%
%   See also:
%       pdist

    arguments
        G (:,:) {mustBeInteger}
    end
    % Calculate pairwise Hamming distances using pdist
    distances = pdist(G, 'hamming');

    % Find the minimum Hamming distance
    d_min = min(distances) * size(G, 2);
end