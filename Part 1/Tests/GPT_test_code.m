% Parameters
M = 4; % Modulation order
SNR_dB = 10; % Signal-to-noise ratio in dB

% Generate PAM signal
data = randi([0, M-1], 100, 1);
symbols = pammod(data, M);

% Add noise
noisy_symbols = awgn(symbols, SNR_dB, 'measured');

% Demodulate
demodulated_data = pamdemod(noisy_symbols, M);

% Evaluate performance
bit_error_rate = biterr(data, demodulated_data) / numel(data);
disp(['Bit Error Rate: ', num2str(bit_error_rate)]);

% Plot Constellation
figure;
subplot(2,1,1);
plot(symbols, 'bo'); % Original constellation
title('PAM Constellation');

% Plot Constellation with Noise
subplot(2,1,2);
plot(noisy_symbols, 'ro'); % Constellation with noise
title('Noisy PAM Constellation');

% Show plots
sgtitle('PAM Constellation and Noisy Constellation');
