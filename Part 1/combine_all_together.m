% Linear Block Code Simulation
% with modulation and AWGN

% To suppress warnings about unreachable code
%#ok<*UNRCH>
clear;
close all ; 

% Simulation parameters 
n_array = 7:10;              % Codeword length
k = 4;                      % Message length
SNR_db_array = 10:2:20 ;          % SNR in db
bits_per_symbol_array = 3:6 ;               % Order of modulation (e.g., bits_per_symbol=4 thus M=16 for 16-QAM)
D_number_of_bits_to_send = 10^5 ;   % Number of symbols to send
Ts = 2*10^-6 ;  % Symbol duration in seconds

gray_encoding = true;
useUnitAveragePower = true; % Set to false if you don't want unit average power

% Output parameters
make_plots = false ; 
print_code_info = false ; 
print_rates = false;
print_BER = false ; 
print_current_status = false ; 
% ============ ============ ============

% Matrices to store the results
ALL_BER_with_ECC    =  zeros(length(SNR_db_array) , length(bits_per_symbol_array) ,length(n_array) ) ; 
ALL_BER_non_ECC     =  zeros(length(SNR_db_array) , length(bits_per_symbol_array) ,length(n_array) ) ; 
ALL_Rb_code         =  zeros(                       length(bits_per_symbol_array) ,length(n_array) ) ; 


% Auto generated parameters
if gray_encoding
    symbol_encoding = 'gray';
else
    symbol_encoding = 'bin'; 
end

% Iterate over the differend Orders of modulations values
for bits_per_symbol_index = 1:length(bits_per_symbol_array)
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
        

    % Iterate over the differend Codeword lengths 
    for n_index = 1:length(n_array)
        n = n_array(n_index); 

    
        if print_current_status 
            fprintf('Codeword length n: %.0f \n', n);
        end
        
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
        D_number_of_bits_to_send = ceil(D_number_of_bits_to_send / D_min) * D_min;
        
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
        
        for SNR_index = 1:length(SNR_db_array)
            SNR_db = SNR_db_array(SNR_index); 

            if print_current_status 
                fprintf('SNR: %.2f db\n', SNR_db);
            end
        
            % ============ Start of simulation ============
            
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
            decodedMessage = decode(encoded_demodulated_signal, n, k, 'linear/binary', G);
            
            
            % Compare the original and demodulated symbols after ECC 
            [~,BER_with_ECC] = biterr(message_in_bits,decodedMessage) ;
        
            
% Store results to plot later
            ALL_BER_non_ECC(SNR_index,bits_per_symbol_index,n_index)  = BER_non_ECC;
            ALL_BER_with_ECC(SNR_index,bits_per_symbol_index,n_index) = BER_with_ECC ; 

            % ============ END of simulation ============
        
            
            if make_plots
                % Plot only the Constellation with Noise
                figure; 
                plot(real(noisy_symbols), imag(noisy_symbols), 'ro'); % Constellation with noise
                hold on ;
                plot(real(constellation_points), imag(constellation_points), 'bx'); % Original constellation
                axis equal
                title( sprintf('Noisy %s-coded %d QAM constellation SNR: %.2f db',symbol_encoding, M, SNR_db) );
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



% Do some plots !!!!!!!!!

% Plotting BER with and without ECC on subplots with logarithmic scale and markers
for i = 1:length(bits_per_symbol_array)
    figure;
    for j = 1:length(n_array)
        subplot(length(n_array), 1, j);
        semilogy(SNR_db_array, squeeze(ALL_BER_with_ECC(:, i, j)), 'o-', 'DisplayName', 'BER with ECC');
        hold on;
        semilogy(SNR_db_array, squeeze(ALL_BER_non_ECC(:, i, j)), 'o-', 'DisplayName', 'BER without ECC');
        title(['BER Comparison - bps: ', num2str(bits_per_symbol_array(i)), ', n: ', num2str(n_array(j))]);
        xlabel('SNR (dB)');
        ylabel('BER');
        legend;
        grid on;
    end
end

% Plotting Code Rates on the same graph for all bits per symbol values with markers
figure;
for i = 1:length(bits_per_symbol_array)
    plot(n_array, ALL_Rb_code(i, :), 'o-', 'DisplayName', ['bps: ', num2str(bits_per_symbol_array(i))]);
    hold on;
end
title('Code Rate Comparison');
xlabel('n');
ylabel('Code Rate');
legend;
grid on;






