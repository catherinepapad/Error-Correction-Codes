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
    leg = legend('Location', 'eastoutside');
    title(leg,'bps')
    grid on;
end


%% Plotting BER before ECC on subplots with logarithmic scale and markers
f2 = figure("Name",'BER before ECC');
tt = tiledlayout(length(n_array), 1, "TileSpacing","tight");
title(tt,'BER before ECC' )
for j = 1:length(n_array)
    nexttile
    for i = 1:length(bits_per_symbol_array)
        semilogy(SNR_db_array, squeeze(ALL_BER_non_ECC(:, i, j)), 'x-', 'DisplayName', num2str(bits_per_symbol_array(i)));
        hold on;
    end
    title(['Codeword length - n: ', num2str(n_array(j))]);
    xlabel('SNR (dB)');
    ylabel('BER');
    leg = legend('Location', 'eastoutside');
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


%% Plotting BER ratio with ECC vs before on subplots with markers
f4 = figure("Name",'BER ratio [before ECC / after ECC]');
tt = tiledlayout(length(n_array), 1, "TileSpacing","tight") ;
title(tt,'BER ratio [before ECC / after ECC]')
for j = 1:length(n_array)    
    nexttile

    min_val = inf;
    max_val = -inf;
    for i = 1:length(bits_per_symbol_array)        
        data_points_to_plot = squeeze(ALL_BER_non_ECC(:, i, j))./squeeze(ALL_BER_with_ECC(:, i, j)) ; 
        semilogy(SNR_db_array, data_points_to_plot , 'x-', 'DisplayName', num2str(bits_per_symbol_array(i)) );
        hold on;

        % Replace inf values with NaN
        data_points_to_plot(isinf(data_points_to_plot)) = NaN;        

        min_val = min(min_val , min(data_points_to_plot, [] ,"all" ,'omitnan')) ;
        max_val = max(max_val , max(data_points_to_plot, [] ,"all" ,'omitnan')) ;
    end
    title(['Codeword length - n: ', num2str(n_array(j))]);
    xlabel('SNR (dB)');
    ylabel('BER');
    aa = floor(log(min_val));
    bb = ceil(log(max_val));
    if ( bb - aa + 1 ) > 3 
        yticks(logspace(aa, bb , bb - aa + 1));
    end

    leg = legend('Location', 'eastoutside');
    title(leg,'bps')
    grid on;
end



if save_BER_plots
    for figure_id = [f1 f2 f3 f4]
        file_name = strrep( figure_id.Name, ' ', '_') ; 
        file_name = strrep( file_name, '/', '') ; 
        save_plots(main_folder, "BER_plots", file_name , save_formats , figure_id );
    end

end

clear f1 f2 f3 f4 figure_id
