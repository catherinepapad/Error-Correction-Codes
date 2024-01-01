% Linear Block Code Simulation


n = 6;  % Codeword length
k = 3;  % Message length

error_rate = 0.02 ; % Set the error rate for the simulated communication channel

% The 'error_rate' variable represents the probability of a bit being flipped
% during the transmission through a simulated communication channel. In this context,
% it is assumed that 2% of the transmitted bits will be affected by errors.
% This variable is used in simulations to model the noise or errors introduced
% during data transmission and is typically employed in error analysis or testing scenarios.


% Set the initial length of transmitted data
transmitted_data_length = 10^3; 

% Adjust the length to be a multiple of 'k' 
transmitted_data_length = transmitted_data_length + k - mod(transmitted_data_length, k);

% The purpose of the adjustment is to ensure that the length of the transmitted data
% is a multiple of 'k', which can be important in certain communication or coding scenarios.
% The expression 'k - mod(transmitted_data_length, k)' calculates the number of bits
% needed to make the length a multiple of 'k', and this value is added to the initial length.
% The final 'transmitted_data_length' will be the smallest multiple of 'k' greater than or equal to
% the initially specified length.


% Define the generator matrix G
% Define the parity check matrix H
[G , H , d_min] = createGeneratorMatrix(n,k);


% Message to be encoded
message = randi([0, 1], 1, transmited_data_length );

% Encode the message using the linear block code
encodedMessage = encode(message, n, k, 'linear/binary', G);


% Change random bits with a 'error_rate' probability
noise_index = rand(size(encodedMessage)) < error_rate;
percentage_of_changed_bits = sum(noise_index) / length(encodedMessage);

% Display the percentage of bits changed
fprintf('Percentage of bits changed: %.2f%%\n', percentage_of_changed_bits * 100);

% Invert the bits at the selected noise_index
encodedMessage(noise_index) = ~encodedMessage(noise_index);


% Decode the received codeword using the linear block code
decodedMessage = decode(encodedMessage, n, k, 'linear/binary', G);


% Compare the original and demodulated symbols
[~,BER] = biterr(message,decodedMessage) ;
disp(['BER: '  num2str(100*BER) '%'])























