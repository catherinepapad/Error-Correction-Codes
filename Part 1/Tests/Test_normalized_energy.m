% Parameters
close all ; 
SNR_dB = 10 ; 
symbols_send = 10^3 ; 
bits_per_symbol = 4 ;   
M = 2^bits_per_symbol; % Order of modulation (e.g., 16 for 16-QAM)

symbols = randi([0 M-1], symbols_send, 1); % Generate random symbols

% Modulation
useUnitAveragePower = true; % Set to false if you don't want unit average power

% Calculate the mean energy of the constalletion
constalletion_points = qammod(0:M-1 , M ,'UnitAveragePower', useUnitAveragePower,'PlotConstellation',true); 
constalletion_energy = mean(abs(constalletion_points).^2) ; 
disp(['Constalletion mean energy: ', num2str(constalletion_energy)])



% ============ Start of simulation ============

% Modulate the symbols
modulated_signal = qammod(symbols, M, 'UnitAveragePower', useUnitAveragePower);


% Adding AWGN
noisy_symbols = awgn(modulated_signal, SNR_dB, 'measured');

% Demodulation
demodulated_signal = qamdemod(noisy_symbols, M, 'UnitAveragePower', useUnitAveragePower);


% Compare the original and demodulated symbols
disp(['SER:'  num2str(sum(symbols~=demodulated_signal) * 100 / symbols_send) '%'])



% Plot Constellation
figure;
subplot(2,1,1);
plot(real(constalletion_points), imag(constalletion_points), 'bo'); % Original constellation
% xlim([-40 40]);
axis equal
title('Gray-coded QAM Constellation');

% Plot Constellation with Noise
subplot(2,1,2);
plot(real(noisy_symbols), imag(noisy_symbols), 'ro'); % Constellation with noise
hold on ;
plot(real(constalletion_points), imag(constalletion_points), 'bx'); % Original constellation
% xlim([-40 40]);
axis equal
title('Noisy Gray-coded QAM Constellation');

% Show plots
sgtitle('Gray-coded QAM Constellation and Noisy Constellation');

