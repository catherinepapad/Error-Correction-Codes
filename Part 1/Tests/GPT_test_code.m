% Parameters
M = 4; % Modulation order
SNR_dB = 10; % Signal-to-noise ratio in dB

% Generate PAM signal
data = randi([0, M-1], 10000, 1);
symbols = pammod(data, M);

% Add noise
noisy_symbols = awgn(symbols, SNR_dB, 'measured');

% Demodulate
demodulated_data = pamdemod(noisy_symbols, M);

% Evaluate performance
bit_error_rate = biterr(data, demodulated_data) / numel(data);
disp(['Bit Error Rate: ', num2str(bit_error_rate)]);
