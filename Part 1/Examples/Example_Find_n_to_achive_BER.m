% Find the Codeword length [n] to achive the desired [BER] (after the ECC) 
% with the Linear Block Code for a given Message length [k] and
% probability of a bit being flipped [p]

k = 2 ;         % Message length
n_min = 3 ;     % Min Codeword length (were to start the search)
n_max = 21 ;    % Max Codeword length (were to start the search
p = 0.05 ;      % Probability of a bit being flipped

transmitted_data_length = 10^6; % Set the initial length of transmitted data
BER_Threshold = 10^-3 ; 

[n, BER_with_ECC, percentage_of_changed_bits,G,H,dmin] = Find_n_to_achive_BER_for_p( k, p, BER_Threshold, ...
    transmitted_data_length=transmitted_data_length ,n_min=n_min , n_max=n_max) ;

%% Results
fprintf("\n\n======== Results ========\n\n"); 
fprintf("k=%d n=%d  p=%.3f \n" ,k, n , p );        
fprintf('Percentage of bits changed: %.2f%%\n', percentage_of_changed_bits * 100);        
disp(['BER_with_ECC: '  num2str(100*BER_with_ECC) '%']);




