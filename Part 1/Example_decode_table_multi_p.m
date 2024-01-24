

k = 2 ;
n = 4 ; 
[G,~,dmin] = createGeneratorMatrix(n,k);


% Generate all possible binary vectors of length k
binary_vectors_k = dec2bin(0:2^k-1, k) - '0';
% Generate all possible codewords
all_codewords = mod(binary_vectors_k*G,2) ;


p = rand(1,n) / 3 ;  %
p = repmat(0.01,1,n) ;

decode_table = decode_table_multi_p(G, p);


[B,BG] = groupcounts(decode_table');




%% Create a pie plot
figure;
pie(B);
% Add a legend
% l = legend((arrayfun(@int2str, BG-1,UniformOutput =false)), 'Location', 'Best'); 
l = legend((arrayfun(@int2str, BG-1,UniformOutput =false))); 
title(l,"Codeword id")
title('Percentage of codeword preference');

% sprintf("p_%d %g",1:n , p)