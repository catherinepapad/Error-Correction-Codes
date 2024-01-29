

k = 4 ;
n = 8 ; 
[G,~,dmin] = createGeneratorMatrix(n,k);


% Generate all possible binary vectors of length k
binary_vectors_k = dec2bin(0:2^k-1, k) - '0';
% Generate all possible codewords
all_codewords = mod(binary_vectors_k*G,2) ;


p = rand(1,n) / 3 ;  %
% p = repmat(0.02,1,n) 
% p = [0.5 0.5 0.5 0.5 ]

decode_table = decode_table_multi_p(G, p);


% [B,BG] = groupcounts(decode_table');

BG = 1:2^k ;
B = zeros(1,2^k) ; 

for c  = decode_table 
    B(c{1}) = B(c{1}) + 1/ length(c{1}) ;     
end




%% Create a pie plot
figure;
pie(B);
% Add a legend
l = legend((arrayfun(@int2str, BG-1,UniformOutput =false)), 'Location', 'Best'); 
% l = legend((arrayfun(@int2str, BG-1,UniformOutput =false))); 
title(l,"Codeword id")
title('Percentage of codeword preference');

% sprintf("p_%d %g",1:n , p)