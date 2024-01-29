% Linear Block Code Simulation
% with modulation and AWGN

% To suppress warnings about unreachable code
%#ok<*UNRCH>
clear;
close all ;     

%% Simulation parameters 
n_array = 3:4;                      % [array] Codeword length
k = 2;                              % Message length
SNR_db_array = 20 ;                 % [array] SNR in db
bits_per_symbol_array = 4 ;       % [array] Order of modulation (e.g., bits_per_symbol=4 thus M=16 for 16-QAM)
D_number_of_bits_to_send_OG = 10^7 ;   % Number of symbols to send
Ts = 2*10^-6 ;                      % Symbol duration in seconds

gray_encoding = true;
useUnitAveragePower = true; % Set to false if you don't want unit average power

%% Plot parameters 
plot_all = false ; 
plots_noisy_symbols     = plot_all || true ;    
plot_constalletions     = plot_all || false ; 
plots_symbol_hist       = plot_all || true ;
plot_final_results      = plot_all || false ; 

%% Print parameters 
print_all = false;
print_code_info         = print_all || false ; 
print_rates             = print_all || false ;
print_BER               = print_all || false ; 
print_current_status    = print_all || false ; 

%% Save plots parameters 
save_all = true;
save_surf_plots     = save_all || true ;
save_BER_plots      = save_all || true ; 
save_workspace      = save_all || true ; 
save_noisy_symbols  = save_all || true ;
save_histograms     = save_all || true ; 


%% Saves path and plots formats
save_formats = [ "fig" "svg"  "eps" ] ;
base_folder = "Runs";   % Specify the base folder and auto create one run




% Find the first non existand folder to save the results
run_number = 1; 
main_folder = fullfile(base_folder, sprintf('%d', run_number)) ; 
while ( exist( main_folder , 'dir')  )
    run_number = run_number + 1 ;
    main_folder = fullfile(base_folder, sprintf('%d', run_number)) ;     
end

mkdir(main_folder);

% Log console prints
diary(fullfile(main_folder, "logs.txt") );
diary on ;


% ============ ============ ============

% Matrices to store the results
ALL_BER_with_ECC    =  zeros(length(SNR_db_array) , length(bits_per_symbol_array) ,length(n_array) ) ; 
ALL_BER_non_ECC     =  zeros(length(SNR_db_array) , length(bits_per_symbol_array) ,length(n_array) ) ; 
ALL_Rb_code         =  zeros(                       length(bits_per_symbol_array) ,length(n_array) ) ; 


% Create arrays of indices for parallel execution
bits_per_symbol_indices = 1:length(bits_per_symbol_array);
n_indices = 1:length(n_array);
SNR_indices = 1:length(SNR_db_array);


% Encoding scheme 
if gray_encoding
    symbol_encoding = 'gray';
else
    symbol_encoding = 'bin'; 
end

tic 

%% Simulation 
% Iterate over the differend Codeword lengths 
for n_index = 1:length(n_array)
    n = n_array(n_index); 


    if print_current_status 
        fprintf('Codeword length n: %.0f \n', n);
    end

    % Define the generator matrix G
    % Define the parity check matrix H
    [G , H , d_min] = createGeneratorMatrix(n,k);

    if print_code_info
            % % Display the matrix G
            % fprintf('G = \n');
            % disp(G);
        
            % Display the matrix G
            fprintf("Dmin = %d\n", d_min);
            fprintf('G = \n');
            disp(num2str(G, '%d')) ;
        
            % Add an extra empty line 
            fprintf('\n');
        
            % Generate all possible binary vectors of length k
            binary_vectors = dec2bin(0:2^k-1, k) - '0';
        
            % Generate all possible codewords
            all_codewords= mod(binary_vectors*G,2) ;
            
            % Create a table
            T = table(dec2bin(0:2^k-1, k), repmat('=>',2^k,1) ,  num2str(all_codewords, '%d'), 'VariableNames', {'words',' ', 'codewords'});
            
            % Display the table
            disp(T);
        
    end

    % Iterate over the differend Orders of modulations values
    for bits_per_symbol_index = 1:length(bits_per_symbol_array)
        bits_per_symbol = bits_per_symbol_array(bits_per_symbol_index);   

    
        if print_current_status 
            fprintf('bits per symbol: %.0f \n', bits_per_symbol);
        end
    
        % Order of modulation
        M = 2^bits_per_symbol; 
    
        
        % This is used to only plot the constalletion
        if n_index == 1 
            temp_plot_constalletions = plot_constalletions ; 
        else
            temp_plot_constalletions = false ; 
        end
        % Calculate the mean energy of the constalletion
        constellation_points = qammod(0:M-1 , M ,'UnitAveragePower', useUnitAveragePower,'PlotConstellation',temp_plot_constalletions); 
        % constellation_energy = mean(abs(constellation_points).^2) ;  % This is 1 when useUnitAveragePower is true            

    
        
        %% Calculate the 'rate' of the code
        % Calculate bit duration (Tb)
        Tb = Ts / bits_per_symbol;  % [sec/bits]
        
        % Calculate code rate (R) 
        R = k / n;
        
        % Calculate bit rate of the communication channel (Rb) in bits per second
        Rb = 1 / Tb;    % [bits/sec]
        
        % Calculate bit rate of the usefull information (Rb_code) in bits per second
        Rb_code = R * Rb ;  % [bits/sec]

% Store result to plot later
        ALL_Rb_code(bits_per_symbol_index,n_index) = Rb_code ;
              
        
        
        % Minimum number of bits needed to send to be able to create code words and symbols without zero padding
        D_min = k  * bits_per_symbol / gcd(n, bits_per_symbol);
        D_number_of_bits_to_send = ceil(D_number_of_bits_to_send_OG / D_min) * D_min;
        
        % The purpose of the adjustment is to ensure that the length of the transmitted data
        % is a multiple of 'D_min', which is important.
        % The expression 'ceil(D_number_of_bits_to_send / D_min) * D_min' calculates the number of bits
        % needed to make the length a multiple of 'D_min'.
        % The final 'D_number_of_bits_to_send' will be the smallest multiple of 'D_min' greater than or equal to
        % the initially specified length.
        
        % The information we want to send in bits
        message_in_bits = randi([0 1], D_number_of_bits_to_send, 1); % Generate random symbols

        
                
        %% Iterate over the differend SNR values
        for SNR_index = SNR_indices
            SNR_db = SNR_db_array(SNR_index); 

            if print_current_status 
                fprintf('SNR: %.2f db\n', SNR_db);
            end
        
            %% ============ Start of simulation ============
            
            % Encode the message using the linear block code
            encodedMessage = encode(message_in_bits, n, k, 'linear/binary', G);
            
            % Modulate to symbols using QAM
            modulated_signal = qammod(encodedMessage, M,symbol_encoding,'InputType','bit', 'UnitAveragePower', useUnitAveragePower);
            
            % Adding AWGN
            noisy_symbols = awgn(modulated_signal, SNR_db, 'measured'); % The  'measured' is not needed if we normalize the constellation
            
            % Demodulation
            encoded_demodulated_signal = qamdemod(noisy_symbols, M, symbol_encoding, 'OutputType', 'bit','UnitAveragePower', useUnitAveragePower);
            
            % Compare the original and demodulated symbols before ECC
            [~,BER_non_ECC] = biterr(encodedMessage,encoded_demodulated_signal) ;
            
            
            % Decode the received codewords using the linear block code
            % Use the "evalc" function to capture the output from the "disp" function calls that are from the "syndtable" function that the "decode" function calls
            % uselles_output = evalc("decodedMessage = decode(encoded_demodulated_signal, n, k, 'linear/binary', G);");
            decodedMessage = decode(encoded_demodulated_signal, n, k, 'linear/binary', G);
            
            
            % Compare the original and demodulated symbols after ECC 
            [~,BER_with_ECC] = biterr(message_in_bits,decodedMessage) ;
        
            
% Store results to plot later
            ALL_BER_non_ECC (SNR_index,bits_per_symbol_index,n_index) = BER_non_ECC;
            ALL_BER_with_ECC(SNR_index,bits_per_symbol_index,n_index) = BER_with_ECC ; 

            % ============ END of simulation ============
        
            %% Plots and prints
            % Plot only the Constellation with Noise
            if plots_noisy_symbols
                figure; 
                plot(real(noisy_symbols), imag(noisy_symbols), 'ro'); % Constellation with noise
                hold on ;
                plot(real(constellation_points), imag(constellation_points), 'bx'); % Original constellation
                axis equal
                temp_title = sprintf('Noisy %s-coded %d QAM constellation SNR: %.2f db Codeword length: %d',symbol_encoding, M, SNR_db,n) ; 
                title( temp_title );

                if save_noisy_symbols
                    % Save the plot
                    file_name = strrep( temp_title , ' ', '_') ; 
                    file_name = strrep( file_name , '.', '_') ; 
                    file_name = strrep( file_name , ':', '') ; 
                    save_plots(main_folder, "noisy_symbols", file_name , save_formats  ) ;
                end

            end
            
            % Histogram     Percentages for each symbol
            if plots_symbol_hist && SNR_index == 1
                figure;
                % Set the edges to cover integers from 0 to M-1
                edges = -0.5:1:(M - 0.5);
                symbols_ids = bit2int(reshape(encodedMessage, bits_per_symbol ,[] ),bits_per_symbol ) ; 
                histogram(symbols_ids,edges ,Normalization="probability");
                xticks(0:M-1);
                ylabel("Percentage of symbols");
                xlabel("Symbol id");      
                temp_title = sprintf("Percentages for each symbol k=%d  n=%d  bps=%d (M=%d) Total symbols = %d " ,k ,n, bits_per_symbol,M,length(encodedMessage)/bits_per_symbol) ;
                title(temp_title);
                
                if save_histograms 
                    % Save the plot
                    file_name = strrep( temp_title , ' ', '_') ; 
                    save_plots(main_folder, "histograms_PoS", file_name , save_formats  ) ;
                end

            end
            
            if print_BER
                disp(['BER with no ECC: '  num2str(100*BER_non_ECC) '%']);
                disp(['BER with ECC:    '  num2str(100*BER_with_ECC) '%']);
            end

            if print_rates
                fprintf('Code Rate (R): %.4f\n', R);
                fprintf('Code Bit Rate (Rb): %.2f bits/second\n', Rb_code);
                fprintf('Bit Rate (Rb):      %.2f bits/second\n', Rb);
            end
        
        end

    end

end

toc

%% Call other scripts that make plots
if plot_final_results
    plot_Part1a_resutls;
    if length(bits_per_symbol_array) > 1 &&  length(n_array) > 1
        plot_Part1a_surfs;
    end
end


if save_workspace
    clear message_in_bits encodedMessage modulated_signal noisy_symbols encoded_demodulated_signal decodedMessage symbols_ids
    save(fullfile( main_folder,"workspace_variables"));

end


diary off ;
