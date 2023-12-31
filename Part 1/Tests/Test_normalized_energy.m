% Parameters
close all ; 
SNR_db = 15 ;           % SNR in db
symbols_send = 10^5 ;   % Number of symbols to send
bits_per_symbol = 4 ;   % Order of modulation (e.g., bits_per_symbol=4 thus M=16 for 16-QAM)
M = 2^bits_per_symbol;  % Order of modulation (e.g., 16 for 16-QAM)

make_plots = false ; 

symbols = randi([0 M-1], symbols_send, 1); % Generate random symbols

% Modulation
useUnitAveragePower = true; % Set to false if you don't want unit average power

% Calculate the mean energy of the constalletion
constellation_points = qammod(0:M-1 , M ,'UnitAveragePower', useUnitAveragePower,'PlotConstellation',make_plots); 
constellation_energy = mean(abs(constellation_points).^2) ; 
% disp(['Constalletion mean energy: ', num2str(constellation_energy)])



% ============ Start of simulation ============

% Modulate the symbols
modulated_signal = qammod(symbols, M, 'UnitAveragePower', useUnitAveragePower);


% Adding AWGN
noisy_symbols = awgn(modulated_signal, SNR_db, 'measured'); % The  'measured' is not needed if we normalize the constellation

% Demodulation
demodulated_signal = qamdemod(noisy_symbols, M, 'UnitAveragePower', useUnitAveragePower);



% Compare the original and demodulated symbols
[~,SER] = symerr(symbols,demodulated_signal) ;
[~,BER] = biterr(symbols,demodulated_signal) ;
disp(['SER: '  num2str(100*SER) '%'])
disp(['BER: '  num2str(100*BER) '%'])


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


