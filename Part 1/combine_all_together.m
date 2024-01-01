

% data = randi([0 1], 10, 1)
% qammod(data,2^5,'InputType','bit','UnitAveragePower', false,'PlotConstellation',true)



% Sample code
x = 1;

n = 13 ;
k = 5 ;
bits_per_symbol = 7 ;

% Calculate D based on the provided formula
D_min = k  * bits_per_symbol / gcd(n, bits_per_symbol)

% Check the conditions
condition1 = mod(D_min, k) == 0;
condition2 = mod(D_min * n / k, bits_per_symbol) == 0;


N = 10^2 

N_corrected = ceil(N / D_min) * D_min
