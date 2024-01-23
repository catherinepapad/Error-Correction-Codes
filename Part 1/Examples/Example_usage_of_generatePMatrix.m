% Example: Generating a Systematic Generator Matrix with a Large Minimum Hamming Distance

% Assuming you are in the Subfolder
parentFolder = fileparts(pwd);  % Get the path of the parent folder

% Add the AnotherFolder to the path temporarily
% addpath(fullfile(parentFolder, 'AnotherFolder'));
addpath(parentFolder);


% Define parameters
n = 8; % Codeword length
k = 4; % Message length

disp('Parameters:')
disp(['n: ' num2str(n)]);
disp(['k: ' num2str(k)]);

% Generate a systematic generator matrix G with a large minimum Hamming distance

% Step 1: Generate the matrix P
disp('Generating matrix P:');
P = generatePMatrix(n, k, 'maxAttempts', 500);

% Display the generated matrix P
disp('Generated matrix P:');
disp(P);

% Step 2: Create the identity matrix I_k
I_k = eye(k);

% Step 3: Combine I_k and P to form the systematic generator matrix G
disp('Generating the systematic generator matrix G:');
G = [I_k, P];

% Display the systematic generator matrix G
disp('Generated systematic generator matrix G:');
disp(G);

% Generate all possible binary vectors of length k
binary_vectors = dec2bin(0:2^k-1, k) - '0';
% Generate all possible codewords
all_codewords = mod(binary_vectors*G,2) ;

% Calculate the minimum Hamming distance of the generated code
d_min = findMinHammingDistance(all_codewords);
disp(['Minimum Hamming Distance (d_min): ' num2str(d_min)]);

% Additional information
disp('Note: The code is generated to maximize the minimum Hamming distance.');
disp('The function uses a randomized approach with a default maximum number of attempts (500).');


% Remove the AnotherFolder from the path to avoid clutter
rmpath(parentFolder);

