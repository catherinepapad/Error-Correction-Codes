
% Create irregular LDPC code
r_avg = 6;
l_max = 10;
epsilon = 0.4;
n_list = [20 100 200 500];

for n = n_list

    % Get the distribution of the degree polynomials
    [rho, lambda] = optimizeLDPC(r_avg, l_max, epsilon);

    % Find the degree polynomials for given codeword length (n)
    [Lambda,Rho] = findLdpcPolynomials(rho, lambda, n);

    % Create regular LDPC codes with the same codeword 
    % length and similar rate as the irregular code
    k = n-sum(Rho);
    rmax = find(rho, 1, 'last');
    lmax = find(lambda, 1, 'last');
    desired_code_rate = k/n;
    [Reg_Lambdas, Reg_Rhos] = createRegularLdpc(n, desired_code_rate, rmax, lmax);

    % Simulate the performance of the irregular and regular LDPC codes
    LDPC_iterations = 40;
    sim_iterations = 200;


    irregular_failure_rates = zeros(LDPC_iterations, 1);
    irregular_erasure_rates = zeros(LDPC_iterations, 1);
    for i = 1:LDPC_iterations
        [irregular_erasure_rates(i), irregular_failure_rates(i)] = simulateLdpcRandom(Lambda, Rho, epsilon, sim_iterations);
    end

    code_rate = (n-sum(Rho))/n;
    ldpc_string = cellstr(['Λ(x) = ' polyToString(Lambda), newline, 'Ρ(x) = ', polyToString(Rho), newline, 'Rate: ', num2str(code_rate)]);

    LDPC_idx = [1];
    LDPC_Lambda_list = [{polyToString(Lambda)}];
    LDPC_Rho_list = [{polyToString(Rho)}];
    LDPC_rate_list = [code_rate];
    LDPC_str_list = [ldpc_string];
    LDPC_type_list = [{'Irregular'}];
    Erasure_list = irregular_erasure_rates;
    Failure_list = irregular_failure_rates;

    for i = 1:size(Reg_Lambdas, 1)
        regular_failure_rates = zeros(LDPC_iterations, 1);
        regular_erasure_rates = zeros(LDPC_iterations, 1);
        Reg_Lambda = Reg_Lambdas(i, :);
        Reg_Rho = Reg_Rhos(i, :);
        for j = 1:LDPC_iterations
            [regular_erasure_rates(j), regular_failure_rates(j)] = simulateLdpcRandom(Reg_Lambda, Reg_Rho, epsilon, sim_iterations);
        end
        
        code_rate = (n-sum(Reg_Rho))/n;
        ldpc_string = cellstr(['Λ(x) = ' polyToString(Reg_Lambda), newline, 'Ρ(x) = ', polyToString(Reg_Rho), newline, 'Rate: ', num2str(code_rate)]);
        
        LDPC_idx = [LDPC_idx; i+1];
        LDPC_Lambda_list = [LDPC_Lambda_list; {polyToString(Reg_Lambda)}];
        LDPC_Rho_list = [LDPC_Rho_list; {polyToString(Reg_Rho)}];
        LDPC_rate_list = [LDPC_rate_list; code_rate];
        LDPC_str_list = [LDPC_str_list; ldpc_string];
        LDPC_type_list = [LDPC_type_list; {'Regular'}];
        Erasure_list = [Erasure_list; regular_erasure_rates];
        Failure_list = [Failure_list; regular_failure_rates];
    end

    % Create a summary table
    table_vals = [];
    for i = LDPC_idx'
        Lambda = LDPC_Lambda_list(i);
        Rho = LDPC_Rho_list(i);
        rate = LDPC_rate_list(i);
        erasures = Erasure_list(LDPC_iterations*(i-1)+1:LDPC_iterations*i);
        failures = Failure_list(LDPC_iterations*(i-1)+1:LDPC_iterations*i);
        mean_erasure = mean(erasures);
        best_erasure = min(erasures);
        mean_failure = mean(failures);
        best_failure = min(failures);
        table_vals = [table_vals; Lambda, Rho, rate, mean_erasure, best_erasure, mean_failure, best_failure];
    end
    table_var_names = {'Λ(x)', 'Ρ(x)', 'Rate', 'Mean_Erasure_Rate', 'Best_Erasure_Rate', 'Mean_Failure_Rate', 'Best_Failure_Rate'};
    table = array2table(table_vals, 'VariableNames', table_var_names);
    disp(table);



    figure;
    title(sprintf('Erasure Rate for LDPC codes, n = %d, r_{avg} = %d, l_{max} = %d, ε = %.2f', n, r_avg, l_max, epsilon));
    hold on;
    x_tick_labels = [];

    for i = LDPC_idx'
        Lambda = LDPC_Lambda_list(i);
        Rho = LDPC_Rho_list(i);
        rate = LDPC_rate_list(i);
        erasures = Erasure_list(LDPC_iterations*(i-1)+1:LDPC_iterations*i);
        failures = Failure_list(LDPC_iterations*(i-1)+1:LDPC_iterations*i);
        x_tick_labels = [x_tick_labels; LDPC_type_list(i)];
        % Place a small horizontal line where the mean is
        plot([i-0.2, i+0.2], [mean(erasures), mean(erasures)], 'k', 'HandleVisibility','off')
        if string(LDPC_type_list(i)) == "Irregular"
            swarmchart(repmat(i, size(erasures)), erasures, "filled", "MarkerFaceAlpha", 0.5);
        else
            swarmchart(repmat(i, size(erasures)), erasures, "MarkerFaceAlpha", 0.5);
        end
        
    end

    ylabel('Erasure Rate');
    ylim([0, inf]);
    xticks(LDPC_idx);
    xticklabels(x_tick_labels);
    legend(LDPC_str_list, 'Location', 'best');
    hold off;
    drawnow;
end

% figs = findobj('Type', 'figure'); % Finds all open figure windows
% for i = 1:length(figs)
%     figure(figs(i)); % Makes the i-th figure current
%     ylim([0 0.4]); % Set your desired y-axis limits
% end



function poly_string = polyToString(poly)
    % Create a string for the polynomial in the form 1 + x^a + x^b + ...
    poly_string = sprintf('%dx^{%d}', poly(find(poly, 1)), find(poly, 1));
    for i = find(poly, 1)+1:length(poly)
        if poly(i) == 0
            continue
        end
        poly_string = strcat(poly_string, sprintf(' + %dx^{%d}', poly(i), i));
    end
end



function [erasure_rate, failure_rate] = simulateLdpcRandom(Lambda, Rho, epsilon, sim_iterations)
    % Simulates a single LDPC code with given parameters
    % Returns the bit erasure rate and the word failure rate (% of words 
    % received with at least one erasure)
    n_erasures = 0;
    n_failures = 0;
    n_erasures_EC = 0;
    n_failures_EC = 0;
    [H, G] = createLdpcFromPoly(Lambda, Rho);
    [k, n] = size(G);
    for i = 1:sim_iterations
        % Create codeword
        % codeword = randi([0, 1], [1, n]);
        codeword =  zeros(1, n);

        % Simulate binary erasure channel with erasure probability epsilon
        received = codeword;
        received(rand(size(received)) < epsilon) = NaN;

        % Count received erasures
        received_erasures = sum(isnan(received));
        if received_erasures > 0
            n_erasures = n_erasures + received_erasures;
            n_failures = n_failures + 1;
        end

        % Decode received message
        decoded = decodeLDPC(H, received, false);

        % If no erasures, the codeword can be decoded (calculate syndrome etc.)
        % (matlab 'decode' function can do this)
        % If there are erasures, the codeword cannot be decoded

        % Count erasures after error correction
        decoded_erasures = sum(isnan(decoded));
        if decoded_erasures > 0
            n_erasures_EC = n_erasures_EC + decoded_erasures;
            n_failures_EC = n_failures_EC + 1;
        end
    end
    
    erasure_rate = n_erasures_EC / (sim_iterations * n);
    failure_rate = n_failures_EC / sim_iterations;

end
