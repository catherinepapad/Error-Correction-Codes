% Assuming you have already computed values for the matrices
% ALL_BER_with_ECC    
% ALL_BER_non_ECC    
% ALL_Rb_code       

% Plotting BER with ECC on subplots with logarithmic scale and markers
figure("Name",'BER with ECC');
sgtitle('BER with ECC') 
for j = 1:length(n_array)
    
    subplot(length(n_array), 1, j);
    for i = 1:length(bits_per_symbol_array)
        semilogy(SNR_db_array, squeeze(ALL_BER_with_ECC(:, i, j)), 'x-', 'DisplayName', ['bps: ', num2str(bits_per_symbol_array(i))]);
        hold on;
    end
    title(['Codeword length - n: ', num2str(n_array(j))]);
    xlabel('SNR (dB)');
    ylabel('BER');
    legend;
    grid on;
end


% Plotting BER without ECC on subplots with logarithmic scale and markers
figure("Name",'BER without ECC');
sgtitle('BER without ECC') 
for j = 1:length(n_array)
    
    subplot(length(n_array), 1, j);
    for i = 1:length(bits_per_symbol_array)
        semilogy(SNR_db_array, squeeze(ALL_BER_non_ECC(:, i, j)), 'x-', 'DisplayName', ['bps: ', num2str(bits_per_symbol_array(i))]);
        hold on;
    end
    title(['Codeword length - n: ', num2str(n_array(j))]);
    xlabel('SNR (dB)');
    ylabel('BER');
    legend;
    grid on;
end



% Plotting Code Rates on the same graph for all bits per symbol values with markers
figure("Name",'Code Rate Comparison');
for i = 1:length(bits_per_symbol_array)
    plot(n_array, ALL_Rb_code(i, :), 'o-', 'DisplayName', ['bps: ', num2str(bits_per_symbol_array(i))]);
    hold on;
end
title('Code Rate Comparison');
xlabel('n');
ylabel('Code Rate');
legend;
grid on;



