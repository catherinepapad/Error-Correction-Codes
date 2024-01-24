function [n, BER_with_ECC, percentage_of_changed_bits,G,H,dmin] = Find_n_to_achive_BER_for_p( k, p, BER_Threshold,options)
% Description


    % Input validation
    arguments (Input)
        k                                   (1,1)   double  {mustBeInteger, mustBePositive, mustBeGreaterThanOrEqual(k,2)}
        p                                   (1,1)   double  {mustBeInRange(p,0,1)}
        BER_Threshold                       (1,1)   double  {mustBeInRange(BER_Threshold,0,1)}
        options.n_min                       (1,1)   double  {mustBeInteger, mustBePositive, mustBeGreaterThanOrEqual(options.n_min,3)}  = k + 1
        options.n_max                       (1,1)   double  {mustBeInteger, mustBePositive, mustBeGreaterThanOrEqual(options.n_max,3)}  = 23
        options.transmitted_data_length     (1,1)   double  {mustBeInteger, mustBePositive} = 10/BER_Threshold
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