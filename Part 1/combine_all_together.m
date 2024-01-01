% Linear Block Code Simulation
% with modulation and AWGN

% To suppress warnings about unreachable code
%#ok<*UNRCH>
% close all ; 

% Simulation parameters 
n = 5;                  % Codeword length
k = 3;                  % Message length
SNR_db = 30 ;           % SNR in db
D_number_of_bits_to_send = 10^5 ;   % Number of symbols to send
bits_per_symbol = 10 ;   % Order of modulation (e.g., bits_per_symbol=4 thus M=16 for 16-QAM)

gray_encoding = true;


if gray_encoding
    symbol_encoding = 'gray';
else
    symbol_encoding = 'bin'; 
end


useUnitAveragePower = true; % Set to false if you don't want unit average power

% Output parameters
make_plots = true ; 

% Auto generated parameters
M = 2^bits_per_symbol;  % Order of modulation (e.g., 16 for 16-QAM)


D_min = k  * bits_per_symbol / gcd(n, bits_per_symbol);
D_number_of_bits_to_send = ceil(D_number_of_bits_to_send / D_min) * D_min;

% The purpose of the adjustment is to ensure that the length of the transmitted data
% is a multiple of 'D_min', which is important.
% The expression 'ceil(D_number_of_bits_to_send / D_min) * D_min' calculates the number of bits
% needed to make the length a multiple of 'D_min'.
% The final 'D_number_of_bits_to_send' will be the smallest multiple of 'D_min' greater than or equal to
% the initially specified length.


message_in_bits = randi([0 1], D_number_of_bits_to_send, 1); % Generate random symbols


% Calculate the mean energy of the constalletion
constellation_points = qammod(0:M-1 , M ,'UnitAveragePower', useUnitAveragePower,'PlotConstellation',make_plots); 
constellation_energy = mean(abs(constellation_points).^2) ; 
disp(['Constalletion mean energy: ', num2str(constellation_energy)])



% ============ Start of simulation ============

% Define the generator matrix G
% Define the parity check matrix H
[G , H , d_min] = createGeneratorMatrix(n,k);


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
disp(['BER with no ECC: '  num2str(100*BER_non_ECC) '%'])


% Decode the received codewords using the linear block code
decodedMessage = decode(encoded_demodulated_signal, n, k, 'linear/binary', G);


% Compare the original and demodulated symbols after ECC 
[~,BER_with_ECC] = biterr(message_in_bits,decodedMessage) ;
disp(['BER with ECC: '  num2str(100*BER_with_ECC) '%'])



% ============ END of simulation ============


if make_plots
    % Plot only the Constellation with Noise
    figure; 
    plot(real(noisy_symbols), imag(noisy_symbols), 'ro'); % Constellation with noise
    hold on ;
    plot(real(constellation_points), imag(constellation_points), 'bx'); % Original constellation
    axis equal
    title( sprintf('Noisy Gray-coded QAM constellation SNR: %.2f db', SNR_db) );
end


% =================== Original ideas ===================

% % Calculate D based on the provided formula
% D_min = k  * bits_per_symbol / gcd(n, bits_per_symbol);
% 
% % Check the conditions
% condition1 = mod(D_min, k) == 0;
% condition2 = mod(D_min * n / k, bits_per_symbol) == 0;


