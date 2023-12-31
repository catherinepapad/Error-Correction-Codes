



figure;

for SNR_db = -5:0.5:20
    Test_normalized_energy
    scatter(SNR_db,SER,"r");
    hold on ; 
    scatter(SNR_db,BER,"b");
    hold on ; 
    
end


set(gca, 'YScale', 'log')

% yscale log % This is from 2023b and later
