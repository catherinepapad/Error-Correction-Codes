function [H, G] = createLdpcFromPoly(v_poly, c_poly, n, k)
    % createLdpcFromPoly - Create a LDPC code (H, G) from polynomials v_poly and c_poly
    %
    %  [H, G] = createLdpcFromPoly(v_poly, c_poly, n, k) creates a (n, k) LDPC code based on polynomials v_poly and c_poly
    % 
    % Inputs:
    %    v_poly - vector of polynomial coefficients for LDPC variable nodes.
    %       polynomial is given in the form [a_0, a_1, ..., a_n], where a_i is the coefficient of x^i
    %       coefficient a_i is equal to the number of variable nodes with degree i
    %    c_poly - vector of polynomial coefficients for LDPC check nodes.
    %       polynomial is given in the form [a_0, a_1, ..., a_n], where a_i is the coefficient of x^i
    %       coefficient a_i is equal to the number of check nodes with degree i
    %    n - length of the codeword
    %    k - length of the message
    %
    % Outputs:
    %    H - (n-k, n) parity check matrix
    %    G - (k, n) generator matrix
    %
    % Example:
    %    [H, G] = createLdpcFromPoly([0 2 2], [0 0 1 0 1], 4, 2)
    %  % creates a (4, 2) LDPC code with v polynomial 2x^1 + 2x^2 and c polynomial x^2 + x^4
    %


    % Explanation:
    %   The algorithm works as follows:
    %     1. Create two pools, one for variable nodes and one for check nodes. Each entry in the pool is a node index,
    %       and represents a connection in the Tanner graph.
    %     2. Add the indices to the pools according to the polynomials. The coefficient determines the amount of nodes
    %       with the same degree. 
    %       For example, if the v_poly is [0 2 1 3], then the pool will contain 2 nodes with degree 1,
    %       1 node with degree 2, and 3 nodes with degree 3, like so: [1 2 3 3 4 4 4 5 5 5 6 6 6]
    %     3. Shuffle each pool, and connect the nodes in the order they appear in the pools, creating H and G.
    %

    % validate the input
    % The amount of edges described by the polynomials must be equal
    n_v = sum(v_poly .* (0:length(v_poly) - 1));
    n_c = sum(c_poly .* (0:length(c_poly) - 1));
    if n_v ~= n_c
        error('The amount of edges described by the polynomials must be equal');
    end


    
    % fill v_pool with the variable nodes, according to their degrees/coefficients in v_poly
    v_pool = [];
    v_idx = 1;
    for i = 1:length(v_poly)
        % Let 'coeff' be the coefficient of x^i in the polynomial
        % and 'degree' be the degree of x^i in the polynomial
        % Then create 'coeff' nodes with degree 'degree'
        coeff = v_poly(i);
        degree = i - 1;
        for j = 1:coeff
            v_pool = [v_pool, ones(1, degree) * v_idx];
            v_idx = v_idx + 1;
        end
    end

    % fill c_pool with the check nodes, according to their degrees/coefficients in c_poly
    c_pool = [];
    c_idx = 1;
    for i = 1:length(c_poly)
        % Let 'coeff' be the coefficient of x^i in the polynomial
        % and 'degree' be the degree of x^i in the polynomial
        % Then create 'coeff' nodes with degree 'degree'
        coeff = c_poly(i);
        degree = i - 1;
        for j = 1:coeff
            c_pool = [c_pool, ones(1, degree) * c_idx];
            c_idx = c_idx + 1;
        end
    end

    % shuffle the pools
    v_pool = v_pool(randperm(length(v_pool)));
    c_pool = c_pool(randperm(length(c_pool)));

    % create the parity check matrix
    H = zeros(n - k, n);

    % connect the nodes
    for i = 1:length(v_pool)
        H(c_pool(i), v_pool(i)) = H(c_pool(i), v_pool(i)) + 1;
    end

    % Make H binary
    H = mod(H, 2);

    % create the generator matrix (G = [I_k | P])
    P = H(:, 1:k)';
    G = [eye(k), P];
    
end