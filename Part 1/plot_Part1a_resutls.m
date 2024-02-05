% Assuming you have already computed values for the matrices
% ALL_BER_with_ECC    
% ALL_BER_non_ECC    
% ALL_Rb_code       

%% Plotting BER with ECC on subplots with logarithmic scale and markers
f1 = figure("Name",'BER with ECC');
tt = tiledlayout(length(n_array), 1, "TileSpacing","tight") ;
title(tt,'BER with ECC')
for j = 1:length(n_array)    
    nexttile
    for i = 1:length(bits_per_symbol_array)
        semilogy(SNR_db_array, squeeze(ALL_BER_with_ECC(:, i, j)), 'x-', 'DisplayName', num2str(bits_per_symbol_array(i)) );
        hold on;
    end
    title(['Codeword length - n: ', num2str(n_array(j))]);
    xlabel('SNR (dB)');
    ylabel('BER');
    leg = legend;
    title(leg,'bps')
    grid on;
end


%% Plotting BER without ECC on subplots with logarithmic scale and markers
f2 = figure("Name",'BER before ECC');
tt = tiledlayout(length(n_array), 1, "TileSpacing","tight");
title(tt,'BER without ECC' )
for j = 1:length(n_array)
    nexttile
    for i = 1:length(bits_per_symbol_array)
        semilogy(SNR_db_array, squeeze(ALL_BER_non_ECC(:, i, j)), 'x-', 'DisplayName', num2str(bits_per_symbol_array(i)));
        hold on;
    end
    title(['Codeword length - n: ', num2str(n_array(j))]);
    xlabel('SNR (dB)');
    ylabel('BER');
    leg = legend;
    title(leg,'bps')
    grid on;
end



%% Plotting Code Rates on the same graph for all bits per symbol values with markers
f3 = figure("Name",'Code Rate Comparison');
for i = 1:length(bits_per_symbol_array)
    plot(n_array, ALL_Rb_code(i, :), 'o-', 'DisplayName', num2str(bits_per_symbol_array(i)));
    hold on;
end
title('Code Rate Comparison');
xlabel('n');
xticks(n_array);
ylabel('Code Rate');
leg = legend;
title(leg,'bps')
grid on;




if save_BER_plots
    for figure_id = [f1 f2 f3]
        file_name = strrep( figure_id.Name, ' ', '_') ; 
        save_plots(main_folder, "BER_plots", file_name , save_formats , figure_id );
    end

end

clear f1 f2 f3 figure_id
