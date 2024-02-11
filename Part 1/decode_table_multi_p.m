function [max_likelihood] = decode_table_multi_p(G,p)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

    arguments 
        G       (:,:)   double  {mustBeMember(G, [0, 1])} 
        p       (1,:)   double  {mustBeInRange(p,0,1)}
    end

    if size(G,2) ~= length(p)
        error("The number of columns of G should be the same as p")
    end

    [k, n] = size(G) ; 
    max_likelihood = cell(1,2^n);

    % Generate all possible binary vectors of length k
    binary_vectors_k = dec2bin(0:2^k-1, k) - '0';
    % Generate all possible codewords
    all_codewords = mod(binary_vectors_k*G,2) ;

    % binary_vectors_n = dec2bin(0:2^n-1, n) - '0'

    prob = zeros(1,2^k);
    for j = 1:2^n
        received_codeword = dec2bin(j-1, n) - '0' ;

        for i = 1:2^k
            decode_to_this = all_codewords(i,:);
            % Find changed bits
            mask = received_codeword ~= decode_to_this;

            prob(i) = prod( mask .* p + (~mask) .* (1-p) );

        end

        % p(r_j) = sum(prob) / (2^k)
        % p(t_i) = 1  / (2^k)
        % p(r_j | t_i) = prob(i) 
        % p(t_i | r_j) = p(r_j | t_i) * p(t_i) / p(r_j)
        %               = prob(i) / sum(prob)

        % argmax_i ( p(t_i | r_j) ) = argmax_i ( prob(i) )   

        temp = max( prob ) ;

        max_likelihood(j) = {find(prob==temp)};



    end

        

end


