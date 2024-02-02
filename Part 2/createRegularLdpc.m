
function [Lambdas,Rhos] = createRegularLdpcs(n, desired_code_rate, r_max, l_max)
    % Create a set of regular LDPC codes with n variable nodes with maximum 
    % degrees r_max and l_max and with code rates as close as
    % possible to desired_code_rate.

    % In a regular LDPC code, there are n variable nodes of degree l
    % and n-k check nodes of degree r
    % the equation must hold: n*l = (n-k)*r where l,r are integers

    % For increasing l (variable node degree), calculate k such that n-k
    % (number of check nodes) is a divisor of l*n (number of edges) while 
    % being as close as possible to the desired code rate and r<=rmax.
    
    ldpcs = [];
    for l = 2:l_max
        
        n_edges = n*l;

        % z = n-k should be a divisor of n_edges (and also < n)
        candidate_z_vals = divisors(n_edges);
        candidate_z_vals = candidate_z_vals(candidate_z_vals<n);

        
        candidate_k_vals = n - candidate_z_vals;

        % Also r should be < r_max
        candidate_k_vals = candidate_k_vals( (n-candidate_k_vals)./n < r_max );

        if(candidate_k_vals == 0)
            continue
        end


        % Choose the divisor that gives the code rate closest to the desired
        % code rate
        [~, idx] = min(abs(candidate_k_vals/n - desired_code_rate));
        k = candidate_k_vals(idx);

        % Store best result (n l k r) in array
        ldpcs = [ldpcs; n, l, k, n_edges/(n-k)];
    end

    if isempty(ldpcs)
        error('Could not find a suitable regular LDPC code');
    end

    % Construct polynomials
    n_ldpcs = size(ldpcs, 1);
    Lambdas = zeros(n_ldpcs, l_max);
    Rhos = zeros(n_ldpcs, r_max);
    for i = 1:size(ldpcs, 1)
        n = ldpcs(i, 1);
        l = ldpcs(i, 2);
        k = ldpcs(i, 3);
        r = ldpcs(i, 4);
        Lambdas(i, l) = n;
        Rhos(i, r) = n-k;
    end

end



% Currently unused. Preserves n and k, but has difficulty achieving the
% constraints r<=r_max and l<=l_max
function [Lambda,Rho] = createRegularLdpc2(n, k, r_max, l_max)
    % Create a regular LDPC code with n variable nodes and n-k check nodes
    % with maximum degree r_max and l_max respectively.
    
    % In a regular LDPC code, there are n variable nodes of degree l
    % and n-k check nodes of degree r
    % the equation must hold: n*l = (n-k)*r where l,r are integers

    n_edges = lcm(n, n-k);
    l_base = n_edges/n;
    r_base = n_edges/(n-k);

    if l_base > l_max
        warning('Regular LDPC has l > l_max');
    end
    if r_base > r_max
        warning('Regular LDPC has r > r_max');
    end

    l = l_base;
    r = r_base;
    
    % Investigate higher multiples of l_base and r_base
    while l + l_base <= l_max && r + r_base <= r_max
        l = l + l_base;
        r = r + r_base;
    end

    Lambda = zeros(1, l);
    Lambda(l) = n;
    Rho = zeros(1, r);
    Rho(r) = n-k;

end
