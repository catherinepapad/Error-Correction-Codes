% Parameters
close all
M = 16; % Modulation order for 4-QAM
EbNo = 10; % Eb/No in dB

% Hamming (7,4) Code Generator Matrix
G = [1 0 0 0 1 0 1; 0 1 0 0 1 1 1; 0 0 1 0 1 1 0; 0 0 0 1 0 1 1];

% Hamming (7,4) Parity-Check Matrix
H = [1 1 1; 1 1 0; 1 0 1; 0 1 1; 1 0 0; 0 1 0; 0 0 1];

% Generate random bits
data = randi([0 1], 4, 1);

% Encoding
encodedData = mod(data'*G, 2);

% Modulation
modulatedData = qammod(encodedData, M, 'InputType', 'bit', 'UnitAveragePower', true);

% Plotting the constellation diagram for the modulated data
% figure;
scatterplot(modulatedData);
title('Constellation Diagram (Before Noise)');

% Adding AWGN
receivedSignal = awgn(modulatedData, EbNo, 'measured');

% Plotting the constellation diagram for the received signal
% figure;
scatterplot(receivedSignal);
title('Constellation Diagram (After Noise)');

% Demodulation
demodulatedData = qamdemod(receivedSignal, M, 'OutputType', 'bit', 'UnitAveragePower', true);

% Decoding
syndrome = mod(demodulatedData * H, 2);
errorPattern = bi2de(syndrome, 'left-msb');
correctedData = demodulatedData;

% Correct one-bit errors
for i = 1:length(errorPattern)
    if errorPattern(i) ~= 0
        correctedData(i) = xor(correctedData(i), 1);
    end
end

% Extract original data
originalData = correctedData(1:4);

% Display results
disp('Original Data: ');
disp(data');
disp('Received Data: ');
disp(originalData);