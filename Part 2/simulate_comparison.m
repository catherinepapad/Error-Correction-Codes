
% Create irregular LDPC code
r_avg_list = [5 6 7 8 9 10 11 12 13 14];
l_max = 15;
epsilon = 0.3;
n = 1500;

LDPC_idx = [];
LDPC_Lambda_list = {};
LDPC_Rho_list = {};
LDPC_rate_list = [];
LDPC_str_list = {};
LDPC_type_list = {};
Erasure_list = [];
Failure_list = [];

% LDPC_idx = zeros(size(r_avg_list,2),1);
% LDPC_Lambda_list = cell(size(r_avg_list,2),1);
% LDPC_Rho_list = cell(size(r_avg_list,2),1);
% LDPC_rate_list = zeros(size(r_avg_list,2),1);
% LDPC_str_list = cell(size(r_avg_list,2),1);
% LDPC_type_list = cell(size(r_avg_list,2),1);
% Erasure_list = zeros(size(r_avg_list,2),1);
% Failure_list = zeros(size(r_avg_list,2),1);

LDPC_iterations = 50;
sim_iterations = 100;


for i=1:1:size(r_avg_list,2)
    try
        r_avg = r_avg_list(i);
    
        % Get the distribution of the degree polynomials
        [rho, lambda] = optimizeLDPC(r_avg, l_max, epsilon);
    
        % Find the degree polynomials for given codeword length (n)
        [Lambda,Rho] = findLdpcPolynomials(rho, lambda, n);
    
        irregular_failure_rates = zeros(LDPC_iterations, 1);
        irregular_erasure_rates = zeros(LDPC_iterations, 1);
        parfor j = 1:LDPC_iterations
            [irregular_erasure_rates(j), irregular_failure_rates(j)] = simulateLdpcRandom(Lambda, Rho, epsilon, sim_iterations);
        end
    
        code_rate = (n-sum(Rho))/n;
        ldpc_string = cellstr(['Λ(x) = ' polyToString(Lambda), newline, 'Ρ(x) = ', polyToString(Rho), newline, 'Rate: ', num2str(code_rate), newline, 'r_{avg}: ', num2str(r_avg)]);
    
        LDPC_idx = [LDPC_idx; i];
        LDPC_Lambda_list = [LDPC_Lambda_list; {polyToString(Lambda)}];
        LDPC_Rho_list = [LDPC_Rho_list; {polyToString(Rho)}];
        LDPC_rate_list = [LDPC_rate_list; code_rate];
        LDPC_str_list = [LDPC_str_list; ldpc_string];
        LDPC_type_list = [LDPC_type_list; {'Irregular'}];
        Erasure_list = [Erasure_list; mean(irregular_erasure_rates)];
        Failure_list = [Failure_list; mean(irregular_failure_rates)];
    catch ME
        disp('An error occurred:');
        disp(ME.message);
    end

end

figure;
title(sprintf('Erasure Rate for LDPC codes, n = %d, l_{max} = %d, ε = %.2f', n, l_max, epsilon));
hold on;

for i = 1:1:size(LDPC_idx,1)
    Lambda = LDPC_Lambda_list(i);
    Rho = LDPC_Rho_list(i);
    rate = LDPC_rate_list(i);
    % erasures = Erasure_list(LDPC_iterations*(i-1)+1:LDPC_iterations*i);
    % failures = Failure_list(LDPC_iterations*(i-1)+1:LDPC_iterations*i);
    erasures = Erasure_list(i);
    failures = Failure_list(i);
    % Place a small horizontal line where the mean is
    plot([i-0.2, i+0.2], [erasures, erasures], 'k', 'HandleVisibility','off')
    swarmchart(repmat(i, 1), erasures, "filled", "MarkerFaceAlpha", 0.5);    
end


ylabel('Erasure Rate');
ylim([0, inf]);
xticks(LDPC_idx);
xticklabels(LDPC_type_list);
legend(LDPC_str_list, 'Location', 'best');
hold off;
drawnow;


