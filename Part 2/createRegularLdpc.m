
function [Lambda,Rho] = createRegularLdpc(n, k, r_max, l_max)
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