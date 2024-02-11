

save_pie_plot = false ; 


k = 2 ;
n = 4 ; 
[G,~,dmin] = createGeneratorMatrix(n,k);


% Generate all possible binary vectors of length k
binary_vectors_k = dec2bin(0:2^k-1, k) - '0';
% Generate all possible codewords
all_codewords = mod(binary_vectors_k*G,2) ;


p = rand(1,n) / 3 ;  %
% p = repmat(0.1,1,n) 
% p = repmat(0.5,1,n) 

fprintf("p =")
fprintf("   %f" , p )
fprintf("\n")


decode_table = decode_table_multi_p(G, p);


% [B,BG] = groupcounts(decode_table');

BG = 1:2^k ;
B = zeros(1,2^k) ; 

for c  = decode_table 
    B(c{1}) = B(c{1}) + 1/ length(c{1}) ;     
end


% Create a table for the code
T1 = table(dec2bin(0:2^k-1, k), repmat('=>',2^k,1) ,  num2str(all_codewords, '%d'), 'VariableNames', {'words',' ', 'codewords'});
disp(T1)

% Create a table for the decode
if all(cellfun(@(x) numel(x) == 1, decode_table))
    TT2_1 = all_codewords(cell2mat(decode_table),:);
    TT2_2 = binary_vectors_k( cell2mat(decode_table) , : ) ; 
    T2 = table(dec2bin(0:2^n-1, n), repmat('=>',2^n,1) ,  num2str(TT2_1, '%d'), repmat('=>',2^n,1) ,  num2str(TT2_2, '%d'), ...
        'VariableNames', {'codeword received',' ', 'codeword estimated','  ', 'word'});
    disp(T2)
end



%% Create a pie plot
figure;
pie(B);
% Add a legend
l = legend((arrayfun(@int2str, BG-1,UniformOutput =false)), 'Location', 'northeastoutside'); 
% l = legend((arrayfun(@int2str, BG-1,UniformOutput =false))); 
title(l,"Codeword id")
title('Percentage of codeword preference');



name = sprintf("k=%d_n=%d__",k,n) + sprintf("p%d=%.2g__", [1:n ; p]);

% Save plot
main_folder = 'Runs\\Part1b\\Pie_plots_decode_multi_p' ;

% Check if the directory exists, if not, create it
if ~exist(main_folder, 'dir')
    mkdir(main_folder);
end


if save_pie_plot  
    plot_name = strrep( name, '.', '_') ; 
    save_plots(main_folder, "", plot_name , ["fig"  "svg"]  );  

end




