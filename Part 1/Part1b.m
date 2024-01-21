% Linear Block Code Simulation


k = 4;  % Message length
n_arr = 5:10;  % Codeword length

% p1 = 0.1 ; % Set the error rate for the simulated communication channel 1
% p2 = 0.2 ; % Set the error rate for the simulated communication channel 2

p_arr = repmat(0.05, length(n_arr),1); % [0.1 0.1 0.1 0.1 ] ; 

% The 'p' variable represents the probability of a bit being flipped
% during the transmission through a simulated communication channel. In this context,
% it is assumed that 2% of the transmitted bits will be affected by errors.
% This variable is used in simulations to model the noise or errors introduced
% during data transmission and is typically employed in error analysis or testing scenarios.

print_code_info = false;

% Set the initial length of transmitted data
transmitted_data_length = 10^6; 

% Adjust the length to be a multiple of 'k' 
transmitted_data_length = transmitted_data_length + k - mod(transmitted_data_length, k);

% The purpose of the adjustment is to ensure that the length of the transmitted data
% is a multiple of 'k', which can be important in certain communication or coding scenarios.
% The expression 'k - mod(transmitted_data_length, k)' calculates the number of bits
% needed to make the length a multiple of 'k', and this value is added to the initial length.
% The final 'transmitted_data_length' will be the smallest multiple of 'k' greater than or equal to
% the initially specified length.

figure ; 


for i = 1:length(n_arr)
    n = n_arr(i);
    p = p_arr(i);
    % Define the generator matrix G
    % Define the parity check matrix H
    [G , H , d_min] = createGeneratorMatrix(n,k);
    
    
    fprintf("Dmin = %d\n", d_min);
    if print_code_info
            % % Display the matrix G
            % fprintf('G = \n');
            % disp(G);
        
            % Display the matrix G
            fprintf('G = \n');
            disp(num2str(G, '%d')) ;
        
            % Add an extra empty line 
            fprintf('\n');
        
            % Generate all possible binary vectors of length k
            binary_vectors = dec2bin(0:2^k-1, k) - '0';
        
            % Generate all possible codewords
            all_codewords= mod(binary_vectors*G,2) ;
            
            % Create a table
            T = table(dec2bin(0:2^k-1, k), repmat('=>',2^k,1) ,  num2str(all_codewords, '%d'), 'VariableNames', {'words',' ', 'codewords'});
            
            % Display the table
            disp(T);
        
    end
    
    % Message to be encoded
    message = randi([0, 1], 1, transmitted_data_length );
    
    % Encode the message using the linear block code
    encodedMessage = encode(message, n, k, 'linear/binary', G);
    
    
    % Change random bits with a 'error_rate' probability
    noise_index = rand(size(encodedMessage)) < p;
    percentage_of_changed_bits = sum(noise_index) / length(encodedMessage);
    
    % Display the percentage of bits changed
    fprintf('Percentage of bits changed: %.2f%%\n', percentage_of_changed_bits * 100);
    
    % Invert the bits at the selected noise_index
    encodedMessage(noise_index) = ~encodedMessage(noise_index);
    
    
    % Decode the received codeword using the linear block code
    % decodedMessage = decode(encodedMessage, n, k, 'linear/binary', G);
    uselles_output = evalc("decodedMessage = decode(encodedMessage, n, k, 'linear/binary', G);");
                
    
    
    % Compare the original and demodulated symbols
    [~,BER] = biterr(message,decodedMessage) ;



    fprintf("n %d  p %.3f \n" , n , p );
    disp(['BER_with_ECC: '  num2str(100*BER) '%']);

    block_message = reshape(message, [],k) ;
    block_decoded_message = reshape(decodedMessage, [],k) ;


    % [~,block_BER] = biterr(block_message,block_decoded_message) ;
    b = any(block_message ~= block_decoded_message,2);
    block_ER = sum(b) / length(b);

    disp(['block_BER_with_ECC: '  num2str(100*block_ER) '%']);


    % disp(['ratio: '  num2str(block_BER/BER) ]);

    rate = 10^-6 ; 
    T_ack = logspace(-10 , 3 , 15);

    meanX = 1/(1-block_ER) ; 
    T = (n*rate)*meanX + T_ack * (meanX-1) ;
    fprintf("E(T) = %.9f \n\n" , T);

    scatter(n,T);
    hold on ; 
    set(gca, 'YScale', 'log');
    title(sprintf("n %d  p %.3f \n" , n , p ));
end




















