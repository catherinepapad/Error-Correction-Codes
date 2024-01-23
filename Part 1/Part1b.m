% Linear Block Code Simulation


k = 4;  % Message length
n_arr = 2 * (5:1:10);  % Codeword length

% p1 = 0.1 ; % Set the error rate for the simulated communication channel 1
% p2 = 0.2 ; % Set the error rate for the simulated communication channel 2

p_arr = logspace(-5,log10(0.5),15);
% repmat(0.1, length(n_arr),1); % [0.1 0.1 0.1 0.1 ] ; 

% The 'p' variable represents the probability of a bit being flipped
% during the transmission through a simulated communication channel. In this context,
% it is assumed that 2% of the transmitted bits will be affected by errors.
% This variable is used in simulations to model the noise or errors introduced
% during data transmission and is typically employed in error analysis or testing scenarios.



rate = 10^-6 ; %[sec/bit]
T_ack = 1 ; %logspace(-3 , 6 , 6);

block_error_rate = zeros(length(n_arr) , length(p_arr)  ) ; 

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



for i = 1:length(n_arr)
    n = n_arr(i);

     % Define the generator matrix G
    % Define the parity check matrix H
    [G , H , d_min] = createGeneratorMatrix(n,k);
    
    
    fprintf("Dmin = %d\n", d_min);

    % if print_code_info
    %         % % Display the matrix G
    %         % fprintf('G = \n');
    %         % disp(G);
    % 
    %         % Display the matrix G
    %         fprintf('G = \n');
    %         disp(num2str(G, '%d')) ;
    % 
    %         % Add an extra empty line 
    %         fprintf('\n');
    % 
    %         % Generate all possible binary vectors of length k
    %         binary_vectors = dec2bin(0:2^k-1, k) - '0';
    % 
    %         % Generate all possible codewords
    %         all_codewords= mod(binary_vectors*G,2) ;
    % 
    %         % Create a table
    %         T = table(dec2bin(0:2^k-1, k), repmat('=>',2^k,1) ,  num2str(all_codewords, '%d'), 'VariableNames', {'words',' ', 'codewords'});
    % 
    %         % Display the table
    %         disp(T);
    % 
    % end
 
    % Message to be encoded
    message = randi([0, 1], 1, transmitted_data_length );

    % Encode the message using the linear block code
    encodedMessage_og = encode(message, n, k, 'linear/binary', G);

    for j = 1:length(p_arr)
        p = p_arr(j);

       
        
       encodedMessage = encodedMessage_og ; 
        
        
        
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
        [~,BER_with_ECC] = biterr(message,decodedMessage) ;
    
    
    
        fprintf("n %d  p %.3f \n" , n , p );
        disp(['BER_with_ECC: '  num2str(100*BER_with_ECC) '%']);
    

        b = any(reshape(message ~= decodedMessage , [],k),2);

        block_ER = sum(b) / length(b);
    
        disp(['block_BER_with_ECC: '  num2str(100*block_ER) '%']);

            
        block_error_rate(i,j) = block_ER ; 
    
        % disp(['ratio: '  num2str(block_BER/BER) ]);
    
    
        
    end
end



figure ; 
plot(n_arr , flip(block_error_rate,2) ,Marker="+" , LineWidth=1);
leg = legend(arrayfun(@num2str,flip(p_arr),'UniformOutput',false),Location="best");
title(leg,'p')
xticks(n_arr);
set(gca, 'YScale', 'log');
ylabel("BLER");
xlabel("n")
grid on
title(sprintf("Block Error Rate k=%d" ,k));




figure; 


% T_ack = 100;
meanX = 1./(1-block_error_rate) ;

T_simple = rate * ( repmat(n_arr' , 1, length(p_arr)) .* meanX );
T_with_ack= rate * ( repmat(n_arr' , 1, length(p_arr)) .* meanX ) + T_ack * (meanX-1);

% T = (n*rate)*meanX + T_ack * (meanX-1) ;
% fprintf("E(T) = %.9f \n\n" , T);
% 

plot(n_arr , flip(T_simple,2) ,Marker="+" , LineWidth=1);
leg = legend(arrayfun(@num2str,flip(p_arr),'UniformOutput',false),Location="best");
% hold on ; 
% plot(n_arr , flip(T_with_ack,2) ,Marker="o" , LineWidth=1);
% leg = legend(arrayfun(@num2str,flip(p_arr),'UniformOutput',false),Location="best");

title(leg,'p')
xticks(n_arr);
set(gca, 'YScale', 'log');
ylabel("E(T|n)");
xlabel("n")
grid on


title(sprintf("E(T|n)  k=%d  " ,k ));



figure; 
% plot(n_arr , flip(T_simple,2) ,Marker="+" , LineWidth=1);
% leg = legend(arrayfun(@num2str,flip(p_arr),'UniformOutput',false),Location="best");
% % hold on ; 
plot(n_arr , flip(T_with_ack,2) ,Marker="o" , LineWidth=1);
leg = legend(arrayfun(@num2str,flip(p_arr),'UniformOutput',false),Location="best");

title(leg,'p')
xticks(n_arr);
set(gca, 'YScale', 'log');
ylabel("E(T|n)");
xlabel("n")
grid on


title(sprintf("E(T|n)  k=%d  T_ack = %f" ,k , T_ack));
















