% Parameters
N = 10^5; % Number of bits to transmit
EbNo = 25; % Eb/No in dB

% Generate random data bits
data = randi([0 1], N, 1);

% Encode using Hamming (7,4) code
encData = encode(data, 7, 4, 'hamming/binary');

% Modulate using BPSK
modData = pskmod(encData, 2);

% Add AWGN noise
rxSig = awgn(modData, EbNo, 'measured');

% Demodulate
demodData = pskdemod(rxSig, 2);

% Decode the received data
decData = decode(demodData, 7, 4, 'hamming/binary');

% Calculate BER
[~, ber] = biterr(data, decData);

% Display results
fprintf('Eb/No: %d dB\n', EbNo);
fprintf('Bit Error Rate: %e\n', ber);