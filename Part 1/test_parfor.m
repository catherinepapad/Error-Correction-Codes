
% Matrices to store the results
ALL_BER_with_ECC    =  zeros(length(SNR_db_array) , length(bits_per_symbol_array) ,length(n_array) ) ; 
ALL_BER_non_ECC     =  zeros(length(SNR_db_array) , length(bits_per_symbol_array) ,length(n_array) ) ; 
ALL_Rb_code         =  zeros(                       length(bits_per_symbol_array) ,length(n_array) ) ; 


tic
% Iterate over the differend Orders of modulations values
parfor bits_per_symbol_index = 1:length(bits_per_symbol_array)
    bits_per_symbol = bits_per_symbol_array(bits_per_symbol_index);   


    % Iterate over the differend Codeword lengths 
    for n_index = 1:length(n_array)
        n = n_array(n_index); 

    

% Store result to plot later
        ALL_Rb_code(bits_per_symbol_index,n_index) = rand() ;
                      
               
        for SNR_index = 1:length(SNR_db_array)
            SNR_db = SNR_db_array(SNR_index); 

            
% Store results to plot later
            ALL_BER_non_ECC (SNR_index,bits_per_symbol_index,n_index) = rand();
            ALL_BER_with_ECC(SNR_index,bits_per_symbol_index,n_index) = rand() ; 

            
        end

    end

end
toc