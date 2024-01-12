% Linear Block Code Simulation
% with modulation and AWGN

% To suppress warnings about unreachable code
%#ok<*UNRCH>
clear;
close all ;     

%% Simulation parameters 
n_array = 4;                      % [array] Codeword length
k = 2;                              % Message length
SNR_db_array = 10:2:20 ;            % [array] SNR in db
bits_per_symbol_array = 3 ;       % [array] Order of modulation (e.g., bits_per_symbol=4 thus M=16 for 16-QAM)
D_number_of_bits_to_send_OG = 10^5 ;% Number of symbols to send
Ts = 2*10^-6 ;                      % Symbol duration in seconds

gray_encoding = true;
useUnitAveragePower = true; % Set to false if you don't want unit average power
% Set the boolean variable to control parallel/serial execution
useParallel = false;  % Set to false for serial execution

%% Output parameters
print_all = true;
make_plots              = print_all || false ; 
print_code_info         = print_all || false ; 
print_rates             = print_all || false ;
print_BER               = print_all || false ; 
print_current_status    = print_all || false ; 
% ============ ============ ============

% Matrices to store the results
ALL_BER_with_ECC    =  zeros(length(SNR_db_array) , length(bits_per_symbol_array) ,length(n_array) ) ; 
ALL_BER_non_ECC     =  zeros(length(SNR_db_array) , length(bits_per_symbol_array) ,length(n_array) ) ; 
ALL_Rb_code         =  zeros(                       length(bits_per_symbol_array) ,length(n_array) ) ; 


% Create arrays of indices for parallel execution
bits_per_symbol_indices = 1:length(bits_per_symbol_array);
n_indices = 1:length(n_array);
SNR_indices = 1:length(SNR_db_array);


% Auto generated parameters
if gray_encoding
    symbol_encoding = 'gray';
else
    symbol_encoding = 'bin'; 
end

if useParallel
    % Use parallel execution with the maximum number of workers
    pool = gcp();  % Get the current parallel pool
    Workers = pool.NumWorkers;  % Set M to the maximum number of workers in the pool
else
    % Use serial execution
    Workers = 0;
end

tic
ticBytes(gcp('nocreate'));
%% Iterate over the differend Orders of modulations values
for bits_per_symbol_index = bits_per_symbol_indices % 34.569885 seconds
    bits_per_symbol = bits_per_symbol_array(bits_per_symbol_index);   


    if print_current_status 
        fprintf('bits per symbol: %.0f \n', bits_per_symbol);
    end

    % Order of modulation
    M = 2^bits_per_symbol; 

    % Calculate the mean energy of the constalletion
    constellation_points = qammod(0:M-1 , M ,'UnitAveragePower', useUnitAveragePower,'PlotConstellation',make_plots); 
    constellation_energy = mean(abs(constellation_points).^2) ; 
    % disp(['Constalletion mean energy: ', num2str(constellation_energy)]);
        

    %% Iterate over the differend Codeword lengths 
    for n_index = n_indices %29.368215 seconds
        n = n_array(n_index); 

    
        if print_current_status 
            fprintf('Codeword length n: %.0f \n', n);
        end
        
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
        
        
        
        
        % Define the generator matrix G
        % Define the parity check matrix H
        [G , H , d_min] = createGeneratorMatrix(n,k);

        %% Print information about the linear block code
        if print_code_info
            % % Display the matrix G
            % fprintf('G = \n');
            % disp(G);
        
            % Display the matrix G
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
        
        %% Iterate over the differend SNR values
        parfor (SNR_index = SNR_indices , Workers) % 15.939097 seconds
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
            if make_plots
                % Plot only the Constellation with Noise
                figure; 
                plot(real(noisy_symbols), imag(noisy_symbols), 'ro'); % Constellation with noise
                hold on ;
                plot(real(constellation_points), imag(constellation_points), 'bx'); % Original constellation
                axis equal
                title( sprintf('Noisy %s-coded %d QAM constellation SNR: %.2f db Codeword length: %d',symbol_encoding, M, SNR_db,n) );
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

tocBytes(gcp('nocreate'));
toc

%% Call other scripts that make plots
plot_resutls;
if length(bits_per_symbol_array) > 1 &&  length(n_array) > 1
    BER_surf_plot;
end

