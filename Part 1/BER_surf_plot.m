% Assuming you have calculated BER values and stored them in ALL_BER_with_ECC

% Choose an index for the SNR value you want to plot (e.g., the first SNR in the array)
% snr_index = 1;

for snr_index = 1:length(SNR_db_array)
    
    % Create a 3D meshgrid for bits_per_symbol and n
    [bits_per_symbol_mesh, n_mesh] = meshgrid(bits_per_symbol_array, n_array);
    
    % Plot the 3D surface with logarithmic scale for BER and colors
    figure;

    % BER = 10*log10(squeeze(ALL_BER_with_ECC(snr_index,:,:))); % If we want to measure in (db)
    BER = (squeeze(ALL_BER_with_ECC(snr_index,:,:)));    
    surf(bits_per_symbol_mesh, n_mesh, BER, 'EdgeColor', 'interp', 'FaceColor', 'interp');
    hold on;
    
    % Reshape meshgrid and BER matrix for scatter plot
    bits_per_symbol_vector = bits_per_symbol_mesh(:);
    n_vector = n_mesh(:);
    BER_vector = BER(:);
    
    % Add markers ('x') at each point
    scatter3(bits_per_symbol_vector, n_vector, BER_vector, 'r*');
    
    xlabel('Bits per Symbol');
    ylabel('n');
    zlabel('BER');
    title(['Bit Error Rate vs. Bits per Symbol and n, SNR = ' num2str(SNR_db_array(snr_index))]);
    
    % Apply logarithmic scale to the color and Z-axis
    set(gca, 'ZScale', 'log');
    set(gca, 'ColorScale', 'log');
    
    % Add colorbar for reference
    colorbar;
    
    % Customize the plot as needed
    hold off;

end
