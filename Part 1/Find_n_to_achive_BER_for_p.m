function [n, BER_with_ECC, percentage_of_changed_bits,G,H,dmin] = Find_n_to_achive_BER_for_p( k, p, BER_Threshold, options)% 
% This MATLAB function is designed to find the minimum block length n needed to achieve a target Bit Error Rate (BER) for a Linear Block Code.
% 
%   Parameters:
%       k: Message length (number of information bits).
%       p: Probability of bit error in the channel.
%       BER_Threshold: Target Bit Error Rate.
%   options:
%       'n_min' - Minimum block length (positive integer, default is k + 1).
%       'n_max' - Maximum block length (positive integer, default is 23).
%       'transmitted_data_length' - Length of transmitted data (positive integer, default is 10/BER_Threshold).
%       'print_code_info' - Flag for printing code information (logical, default is false).
%       'print_progress' - Flag for printing progress information (logical, default is false).
% 
% 
% The output includes:
% 
%     n: Block length.
%     BER_with_ECC: Achieved Bit Error Rate with error correction coding.
%     percentage_of_changed_bits: Percentage of bits changed in the channel during simulations.
%     G: Generator matrix of the linear block code.
%     H: Parity-check matrix of the linear block code.
%     dmin: Minimum distance of the linear block code.
% 
%   See also:
%       createGeneratorMatrix, encode, decode



    % Input validation
    arguments (Input)
        k                                   (1,1)   double  {mustBeInteger, mustBePositive, mustBeGreaterThanOrEqual(k,2)}
        p                                   (1,1)   double  {mustBeInRange(p,0,1)}
        BER_Threshold                       (1,1)   double  {mustBeInRange(BER_Threshold,0,1)}
        options.n_min                       (1,1)   double  {mustBeInteger, mustBePositive, mustBeGreaterThanOrEqual(options.n_min,3)}  = k + 1
        options.n_max                       (1,1)   double  {mustBeInteger, mustBePositive, mustBeGreaterThanOrEqual(options.n_max,3)}  = 23
        options.transmitted_data_length     (1,1)   double  {mustBeInteger, mustBePositive} = 100/BER_Threshold
        options.print_code_info             (1,1)   logical = false
        options.print_progress              (1,1)   logical = false
    end
    
    arguments (Output)
        n                           (1,1)   double  {mustBeInteger, mustBePositive}
        BER_with_ECC                (1,1)   double  {mustBeInRange(BER_with_ECC,0,1)}
        percentage_of_changed_bits  (1,1)   double  {mustBeInRange(percentage_of_changed_bits,0,1)}
        G                           (:,:)   double  {mustBeMember(G, [0, 1])}
        H                           (:,:)   double  {mustBeMember(H, [0, 1])} 
        dmin                        (1,1)   double  {mustBeInteger, mustBePositive} 
    end

    % Load values from options to not have to write "options."
    n_min                   = options.n_min                   ; 
    n_max                   = options.n_max                   ; 
    transmitted_data_length = options.transmitted_data_length ;
    print_code_info         = options.print_code_info         ; 
    print_progress          = options.print_progress          ; 
    
    
    % Adjust the length to be a multiple of 'k' 
    transmitted_data_length = transmitted_data_length + k - mod(transmitted_data_length, k);
    
    % Message to be encoded
    message = randi([0, 1], 1, transmitted_data_length );
    
    BER_with_ECC = 2 ; 
    for n = n_min:n_max
        
        % Define the generator matrix G
        % Define the parity check matrix H
        [G , H , dmin] = createGeneratorMatrix(n,k);
        
        
        if print_code_info
                % Display the matrix G
                fprintf('G = \n');
                disp(num2str(G, '%d')) ;
    
                % Add an extra empty line 
                fprintf('\n');
    
                fprintf("dmin = %d\n\n", dmin);
    
                % Generate all possible binary vectors of length k
                binary_vectors = dec2bin(0:2^k-1, k) - '0';
    
                % Generate all possible codewords
                all_codewords= mod(binary_vectors*G,2) ;
    
                % Create a table
                T = table(dec2bin(0:2^k-1, k), repmat('=>',2^k,1) ,  num2str(all_codewords, '%d'), 'VariableNames', {'words',' ', 'codewords'});
    
                % Display the table
                disp(T);
        end
     
    
        % Encode the message using the linear block code
        encodedMessage = encode(message, n, k, 'linear/binary', G);
    
          
        % Choose random bits with a 'error_rate' probability
        noise_index = rand(size(encodedMessage)) < p;
        percentage_of_changed_bits = sum(noise_index) / length(encodedMessage);
        
        
        % Invert the bits at the selected noise_index
        encodedMessage(noise_index) = ~encodedMessage(noise_index);
        
        
        % Decode the received codeword using the linear block code
        % decodedMessage = decode(encodedMessage, n, k, 'linear/binary', G);
        uselles_output = evalc("decodedMessage = decode(encodedMessage, n, k, 'linear/binary', G);");
                    
        
        
        % Compare the original and demodulated symbols
        [~,BER_with_ECC] = biterr(message,decodedMessage) ;
    
        % 
        % % Calculate BLER (Block Error Rate) the probability that there will an error in a block    
        % b = any(reshape(message ~= decodedMessage , [],k),2);
        % BLER = sum(b) / length(b);
        %         
    
    
        if print_progress
            fprintf("k=%d n=%d  p=%.3f \n" ,k, n , p );            
            fprintf('Percentage of bits changed: %.2f%%\n', percentage_of_changed_bits * 100);        
            disp(['BER_with_ECC: '  num2str(100*BER_with_ECC) '%']);
    
            % disp(['block_BER_with_ECC: '  num2str(100*BLER) '%']);    
            % disp(['ratio BLER/BER_with_ECC: '  num2str(BLER/BER_with_ECC) ]);
        end
        
        
        if BER_with_ECC <= BER_Threshold                         
            break;
        end
    
    end

    if BER_with_ECC > BER_Threshold  
        warning('The desired BER was not reached') ;
    end

end