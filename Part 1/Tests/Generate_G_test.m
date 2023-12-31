



% Define parameters
n = 6; % Length of codeword
k = 3; % Message length

% Generate systematic generator matrix G with a large minimum Hamming distance

I_k = eye(k); % Identity matrix of size k

% Create a matrix P with rows carefully chosen to maximize minimum Hamming distance
P = generatePMatrix(n, k );  % k x (n-k) dimentions

% Generate the systematic generator matrix G
G = [I_k, P]

d_min = findMinHammingDistance(G)

% 
% function P = generatePMatrix(n, k, target_dmin , maxAttempts)
%     arguments
%         n               (1,1) {mustBeInteger,mustBePositive}
%         k               (1,1) {mustBeInteger,mustBePositive,mustBeGreaterThanOrEqual(k,2)}
%         target_dmin     (1,1) {mustBeInteger,mustBePositive} = 2
%         maxAttempts     (1,1) {mustBeInteger,mustBePositive} = 500
%     end
% 
%     % If n==k then the code is just I_k and thus P is empty 
%     if ( n == k )
%         P = [];
%         return 
%     end
% 
%     % The minus 2 at the end is because we check only for the matrix P 
%     if target_dmin == 2 
%         % Find an upper bound for the best dmin 
%         if k <= 2 
%             % This is a special case 
%             Singleton_bound = n - 2 ;
%         else
%             Singleton_bound = n-k+1 -2 ;
%         end
%     else
%         % This is from the function argument
%         Singleton_bound = target_dmin - 2 ; 
%     end
% 
%     % % Perform row operations to maximize minimum Hamming distance
%     % P = rref(P);  % This might also be a fancy idea
% 
%     bestP = [];
%     best_dmin = -1;
% 
%     for attempt = 1:maxAttempts
%         % Generate a random matrix
%         currentP = randi([0, 1], k, n - k);
% 
%         current_dmin = findMinHammingDistance(currentP) ; 
% 
%         % Update the best solution if the current one is better
%         if current_dmin > best_dmin
%             best_dmin = current_dmin;
%             bestP = currentP;
%             if best_dmin == Singleton_bound 
%                 disp("The code is perfect <============================") %This means that it reaches the upper bound 
%                 break
%             end
%         end
%     end
% 
%     % Return the best solution found
%     P = bestP;
% end



% function d_min = findMinHammingDistance(G)
%     arguments
%         G (:,:) {mustBeInteger}
%     end
%     % Calculate pairwise Hamming distances using pdist
%     distances = pdist(G, 'hamming');
% 
%     % Find the minimum Hamming distance
%     d_min = min(distances) * size(G, 2);
% end






