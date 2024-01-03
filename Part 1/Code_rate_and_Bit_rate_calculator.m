% Given symbol duration (Ts), modulation order (M), n, and k
Ts = 10^-6; % Symbol duration in seconds
bits_per_symbol = 5 ;  
M = 2^bits_per_symbol;  % Modulation order
n = 10;  % Total number of bits in a codeword
k = 8;  % Number of information bits


% Calculate bit duration (Tb)
Tb = Ts / bits_per_symbol;  % [sec/bits]

% Calculate code rate (R) 
R = k / n;

% Calculate bit rate of the communication channel (Rb) in bits per second
Rb = 1 / Tb;    % [bits/sec]

% Calculate bit rate of the usefull information (Rb_code) in bits per second
Rb_code = R * Rb ;  % [bits/sec]


fprintf('Code Rate (R): %.4f\n', R);
fprintf('Code Bit Rate (Rb): %.2f bits/second\n', Rb_code);
fprintf('Bit Rate (Rb):      %.2f bits/second\n', Rb);



