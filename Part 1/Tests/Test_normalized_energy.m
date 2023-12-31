% Parameters
close all ; 
symbols_send = 10^3 ; 
bits_per_symbol = 5 ;   
M = 2^bits_per_symbol; % Order of modulation (e.g., 16 for 16-QAM)

symbols = randi([0 M-1], symbols_send, 1); % Generate random symbols

% Modulation
useUnitAveragePower = true; % Set to false if you don't want unit average power

% Calculate the mean energy of the constalletion
constalletion_points = qammod(0:M-1 , M ,'UnitAveragePower', useUnitAveragePower,'PlotConstellation',true); 
constalletion_energy = sqrt(mean(abs(constalletion_points).^2)) ; 
disp(['Constalletion mean energy: ', num2str(constalletion_energy)])


modulated_signal = qammod(symbols, M, 'UnitAveragePower', useUnitAveragePower);

% Demodulation
demodulated_signal = qamdemod(modulated_signal, M, 'UnitAveragePower', useUnitAveragePower,'NoiseVariance',100);

% Compare the original and demodulated symbols
disp(['SER:'  sum(symbols~=demodulated_signal) * 100 / symbols_send '%'])
disp(sum(symbols~=demodulated_signal) * 100 / symbols_send)
disp(sum(symbols~=demodulated_signal))

