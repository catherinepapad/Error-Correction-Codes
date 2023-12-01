% close all
% Parameters
M = 4; % Modulation order
SNR_dB = 25; % Signal-to-noise ratio in dB
initial_phase = 0; % Initial phase in radians

% Generate Gray-coded PAM signal with specified initial phase
gray_data = randi([0, M-1], 10^3, 1);
binary_data = de2bi(gray_data, log2(M), 'left-msb'); % Convert to binary
symbols = pammod(gray_data, M, initial_phase, 'gray');

% Add noise
noisy_symbols = awgn(symbols, SNR_dB, 'measured');

% Demodulate
demodulated_data = pamdemod(noisy_symbols, M, initial_phase, 'gray');

% Convert demodulated data to binary
demodulated_binary = de2bi(demodulated_data, log2(M), 'left-msb');

% Evaluate performance
bit_error_rate = biterr(binary_data, demodulated_binary) / numel(binary_data);
disp(['Bit Error Rate: ', num2str(bit_error_rate)]);

% Plot Constellation
figure;
subplot(2,1,1);
plot(real(symbols), imag(symbols), 'bo'); % Original constellation
xlim([-40 40]);
axis equal
title('Gray-coded PAM Constellation');

% Plot Constellation with Noise
subplot(2,1,2);
plot(real(noisy_symbols), imag(noisy_symbols), 'ro'); % Constellation with noise
hold on ;
plot(real(symbols), imag(symbols), 'bx'); % Original constellation
xlim([-40 40]);
axis equal
title('Noisy Gray-coded PAM Constellation');

% Show plots
sgtitle('Gray-coded PAM Constellation and Noisy Constellation');
