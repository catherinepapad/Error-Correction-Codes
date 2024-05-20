function [H, G] = createLdpcFromPoly(lambda_poly, rho_poly)
    % createLdpcFromPoly - Create a LDPC code (H, G) from polynomials lambda_poly and rho_poly
    %
    %  [H, G] = createLdpcFromPoly(lambda_poly, rho_poly) creates an LDPC code based on polynomials lambda_poly and rho_poly
    % 
    % Inputs:
    %    lambda_poly - vector of polynomial coefficients for LDPC variable nodes.
    %       polynomial is given in the form [a_0, a_1, ..., a_n], where a_i is the coefficient of x^i
    %       coefficient a_i is equal to the number of variable nodes with degree i
    %    rho_poly - vector of polynomial coefficients for LDPC check nodes.
    %       polynomial is given in the form [a_0, a_1, ..., a_n], where a_i is the coefficient of x^i
    %       coefficient a_i is equal to the number of check nodes with degree i
    %
    % Outputs:
    %    H - (n-k, n) parity check matrix
    %    G - (k, n) generator matrix
    %
    % Example:
    %    [H, G] = createLdpcFromPoly([0 2 2], [0 0 1 0 1])
    %  % creates a (4, 2) LDPC code with lambda polynomial 2x^1 + 2x^2 and rho polynomial x^2 + x^4
    %


    % Explanation:
    %   The algorithm works as follows:
    %     1. Create two pools, one for variable nodes and one for check nodes. Each entry in the pool is a node index,
    %       and represents a connection in the Tanner graph.
    %     2. Add the indices to the pools according to the polynomials. The coefficient determines the amount of nodes
    %       with the same degree. 
    %       For example, if the lambda_poly is [0 2 1 3], then the pool will contain 2 nodes with degree 1,
    %       1 node with degree 2, and 3 nodes with degree 3, like so: [1 2 3 3 4 4 4 5 5 5 6 6 6]
    %     3. Shuffle each pool, and connect the nodes in the order they appear in the pools, creating H and G.
    %

    % Validate arguments
    arguments (Input)
        lambda_poly (:, 1) double {mustBeInteger, mustBeNonnegative}
        rho_poly    (:, 1) double {mustBeInteger, mustBeNonnegative}
    end
    % Output validation
    arguments (Output)
        H            (:,:) double {mustBeMember(H, [0, 1])} 
        G            (:,:) double {mustBeMember(G, [0, 1])} 
    end

    % The amount of edges described by the polynomials must be equal
    n_lambda = sum(lambda_poly .* (1:length(lambda_poly)).' );
    n_rho = sum(rho_poly .* (1:length(rho_poly)).' );
    if n_lambda ~= n_rho
        error('The amount of edges described by the polynomials must be equal');
    end

    num_edges = n_lambda;
   
    n = sum(lambda_poly);
    k = n - sum(rho_poly);

    % n-k must be positive
    if n-k <= 0
        error('n-k must be positive');
    end


    
    % fill l_pool with the variable nodes, according to their degrees/coefficients in lambda_poly
    l_pool = [];
    l_idx = 1;
    for i = 1:length(lambda_poly)
        % Let 'coeff' be the coefficient of x^i in the polynomial
        % and 'degree' be the degree of x^i in the polynomial
        % Then create 'coeff' nodes with degree 'degree'
        coeff = lambda_poly(i);
        degree = i;
        for j = 1:coeff
            l_pool = [l_pool, repmat(l_idx, 1, degree)];
            l_idx = l_idx + 1;
        end
    end

    % fill r_pool with the check nodes, according to their degrees/coefficients in rho_poly
    r_pool = [];
    r_idx = 1;
    for i = 1:length(rho_poly)
        % Let 'coeff' be the coefficient of x^i in the polynomial
        % and 'degree' be the degree of x^i in the polynomial
        % Then create 'coeff' nodes with degree 'degree'
        coeff = rho_poly(i);
        degree = i;
        for j = 1:coeff
            r_pool = [r_pool, repmat(r_idx, 1, degree)];
            r_idx = r_idx + 1;
        end
    end

    % shuffle the pools
    l_pool = l_pool(randperm(num_edges));
    r_pool = r_pool(randperm(num_edges));

    % create the parity check matrix
    H = zeros(n - k, n);

    % Iterate over the edges, and increment the corresponding entry in H
    % This will make H a adjacency matrix of the Tanner graph, where H(x,y) 
    % indicates the amount of edges connecting variable node x to check node y
    duplicate_list = [];
    for i = 1:num_edges
        % If the edge already exists, add it to the duplicate list
        if H(r_pool(i), l_pool(i)) == 1
            duplicate_list = [duplicate_list, [r_pool(i); l_pool(i)]];
        else % Otherwise, increment the corresponding entry in H
            H(r_pool(i), l_pool(i)) = 1;
        end
    end

    if(size(duplicate_list, 2) > 0)
        % fprintf('Duplicates found: %d\n', size(duplicate_list, 2));

        % For the duplicates, first shuffle the list so that nodes are connected randomly
        % (just rotating the check node indices by 1 will work), and then add to H
        duplicate_list(1, :) = circshift(duplicate_list(1, :), 1);
    
        for i = 1:size(duplicate_list, 2)
            H(duplicate_list(1, i), duplicate_list(2, i)) = H(duplicate_list(1, i), duplicate_list(2, i)) + 1;
        end

        % Print how many duplicates there are in H (hopefully 0)
        % fprintf('Duplicates dropped from %d to %d\n',  size(duplicate_list, 2), sum(sum(H > 1)));
    end

    % display(H);
    
    % Make H binary
    H = mod(H, 2);

    % create the generator matrix (G = [I_k | P])
    P = H(:, 1:k)';
    G = [eye(k), P];
    
end