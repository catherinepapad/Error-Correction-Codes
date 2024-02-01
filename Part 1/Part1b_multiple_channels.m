% Multiple Channels
% For each channel find the Codeword length [n] to achive the desired [BER] (after the ECC) 
% with the Linear Block Code for a given Message length [k] and
% probability of a bit being flipped [p]
% Then find the rate of each code/channel to decide what portion of the
% information will be sent through that channel 


channels = 10 ; 
desired_BER = 10^-2 ;
k_arr = repmat(2, 1, channels ) ;
p_arr =  linspace(0.002,0.05,channels);
% p_arr =   repmat(0.002, 1, channels ) ;
Capacity_arr = linspace( 10^6 , 10^6, channels ) ; % [bits/sec] capacity of each channel 

save_pie_plot = true ; 

% Find optimal 
[n_cell_arr, BER_with_ECC_cell_arr, ~, G_cell_arr, ~, dmin_cell_arr] = arrayfun(@(x) Find_n_to_achive_BER_for_p(k_arr(x), p_arr(x), desired_BER),1:channels ...
                                                                            ,UniformOutput =false);


% Calculate code rate (R) for each channel
R = k_arr ./ cell2mat (n_cell_arr);

% Calculate "useful" bitrate of each channel 
Chanel_bitrate = R .* Capacity_arr ; 

% Find percentage of info to send through each channel
data_portion = Chanel_bitrate / sum(Chanel_bitrate);


%% Print results
% Create a table
result_table = table((1:channels)', k_arr', cell2mat(n_cell_arr)', p_arr', cell2mat(dmin_cell_arr)', R', data_portion',Chanel_bitrate', cell2mat(BER_with_ECC_cell_arr)', ...
    'VariableNames', {'Channel','k','n', 'p', 'dmin', 'R', 'Data_Portion', 'Bitrate','BER with ECC'});


fprintf("\n\nDesired BER %g \n\n" , desired_BER);
disp(result_table);



%% Create a pie plot
figure;
pie(data_portion);
% Add a legend
l = legend((arrayfun(@int2str, 1:channels,UniformOutput =false)), 'Location', 'Best'); 
title(l,"Channel")
title('Percentage of data to send through each channel');



% Save plots and tables

main_folder = 'Runs\\Part1b\\Pie_plots_multiple_channels' ;
excel_file_name = 'Multiple_Channels.xlsx' ;

full_relative_name = fullfile(main_folder,excel_file_name) ;

% Check if the directory exists, if not, create it
if ~exist(main_folder, 'dir')
    mkdir(main_folder);
end

% Determine to witch sheet to write 
if exist(full_relative_name,'file') == 2
    number_of_sheets = length(sheetnames(full_relative_name));
else
    number_of_sheets = 0;
end


name = sprintf("Run_%d_Chanells_%d_BER_%g",number_of_sheets+1, channels, desired_BER  ) ; 


if save_pie_plot  
    plot_name = strrep( name, '.', '_') ; 
    save_plots(main_folder, "", plot_name , ["fig"  "svg"]  );  

end


% Save the table to an Excel file
writetable(result_table, full_relative_name, 'Sheet',name  );






