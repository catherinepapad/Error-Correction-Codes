function [max_likelihood] = decode_table_multi_p(G,p)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

    if size(G,2) ~= length(p)
        error("Should be same")
    end

    [k, n] = size(G) ; 
    max_likelihood = zeros(1,2^n);

    % Generate all possible binary vectors of length k
    binary_vectors_k = dec2bin(0:2^k-1, k) - '0';
    % Generate all possible codewords
    all_codewords = mod(binary_vectors_k*G,2) ;

    % binary_vectors_n = dec2bin(0:2^n-1, n) - '0'

    prob = zeros(1,2^k);
    for i = 1:2^n
        received_codeword = dec2bin(i-1, n) - '0' ;

        for j = 1:2^k
            decode_to_this = all_codewords(j,:);

            mask = received_codeword ~= decode_to_this;


            prob(j) = prod( mask .* p + (~mask) .* (1-p) );
            % prob(j)

        end

        [~ , max_likelihood(i)] = max(prob) ;
        % with_prob
        % max_likelihood(i)

    end

    
    % max_likelihood = 3 ;
    

end

%   decode_table_multi_p(G,rand(1,size(G,2))); 
%   decode_table_multi_p(G,repmat(0.01,1,size(G,2))); 