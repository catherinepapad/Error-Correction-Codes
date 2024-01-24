% Multipule Channels

channels = 4 ; 
desired_BER = 10^-2 ;
k_arr = repmat(2, 1, channels ) ;
p_arr =  linspace(0.002,0.05,channels);

[n_cell_arr, ~, ~, G_cell_arr, ~, dmin_cell_arr] = arrayfun(@(x) Find_n_to_achive_BER_for_p(k_arr(x), p_arr(x), desired_BER),1:channels ...
                                                                            ,UniformOutput =false);



% Calculate code rate (R) for each channel
R = k_arr ./ cell2mat (n_cell_arr);

% Find percentage of info to send throgh each channel
data_portion = R / sum(R);




% Create a table
result_table = table((1:channels)', k_arr', cell2mat(n_cell_arr)', p_arr', cell2mat(dmin_cell_arr)', R', data_portion', ...
    'VariableNames', {'Channel','k','n', 'p', 'dmin', 'R', 'Data_Portion'});


fprintf("\n\nDesired BER %g \n\n" , desired_BER);
disp(result_table);