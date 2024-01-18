% Matrices to store the results
ALL_BER_with_ECC    = zeros(length(SNR_db_array), length(bits_per_symbol_array), length(n_array));
ALL_BER_non_ECC     = zeros(length(SNR_db_array), length(bits_per_symbol_array), length(n_array));
ALL_Rb_code         = zeros(length(bits_per_symbol_array), length(n_array));

tic
ticBytes(gcp('nocreate'));

% Create arrays of indices for parallel execution
bits_per_symbol_indices = 1:length(bits_per_symbol_array);
n_indices = 1:length(n_array);
SNR_indices = 1:length(SNR_db_array);

% Iterate over the different Orders of modulations values
for bits_per_symbol_index = bits_per_symbol_indices
    bits_per_symbol = bits_per_symbol_array(bits_per_symbol_index);

    % Iterate over the different Codeword lengths
    for n_index = n_indices
        n = n_array(n_index);

        % Store result to plot later
        ALL_Rb_code(bits_per_symbol_index, n_index) = rand();

        % Iterate over SNR indices
        parfor SNR_index = SNR_indices
            SNR_db = SNR_db_array(SNR_index);

            % Store results to plot later
            ALL_BER_non_ECC(SNR_index, bits_per_symbol_index, n_index) = rand();
            ALL_BER_with_ECC(SNR_index, bits_per_symbol_index, n_index) = rand();
        end
    end
end

tocBytes(gcp('nocreate'));
toc
