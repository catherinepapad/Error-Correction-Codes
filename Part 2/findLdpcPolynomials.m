
function [Lambda,Rho] = findLdpcPolynomials(rho, lambda, n)
    % findLdpcPolynomialsApproximate - Given the rho and lambda distribution polynomials, find the
    % Lambda and Rho polynomials for the LDPC code.
    % 
    % This function uses an approximate method, as the exact method may
    % yield a very large n (codeword length).
    
    % turn rho and lambda into row vectors if they are not already
    if size(rho,1) > size(rho,2)
        rho = rho';
    end
    if size(lambda,1) > size(lambda,2)
        lambda = lambda';
    end
    
    r_max = find(rho,1,'last');
    l_max = find(lambda,1,'last');


    denom = sum( lambda(1:l_max) ./ (1:l_max) );
    L = (lambda(1:l_max) ./ (1:l_max) / denom) * n;
    R = (rho(1:r_max) ./ (1:r_max) / denom) * n;
    L_hat = floor(L);
    R_hat = floor(R);
    A = sum(R - R_hat);


    % Linear optimization problem for sum(x_R_hat - A) >= 0
    % Variables: x_L_hat, x_R_hat (vectors of length l_max and r_max)
    % Minimize: sum(x_R_hat)
    % Subject to:
    %   sum( x_L_hat ) = n - sum( L_hat )
    %   sum(x_L_hat .* (1:l_max)) - sum( x_R_hat .* (1:r_max) ) = sum( R_hat .* (1:r_max) ) - sum( L_hat .* (1:l_max) )
    %   x_L_hat E {0,1}, x_R_hat E {0,1}
    %   sum( x_R_hat ) >= ceil(A)
    % 
    % Linear optimization problem for sum(x_R_hat - A) <= 0
    % Variables: x_L_hat, x_R_hat (vectors of length l_max and r_max)
    % Maximize: sum(x_R_hat)
    % Subject to:
    %   sum( x_L_hat ) = n - sum( L_hat )
    %   sum(x_L_hat .* (1:l_max)) - sum( x_R_hat .* (1:r_max) ) = sum( R_hat .* (1:r_max) ) - sum( L_hat .* (1:l_max) )
    %   x_L_hat E {0,1}, x_R_hat E {0,1}
    %   sum( x_R_hat ) <= floor(A)
    
    f = [zeros(1,l_max), ones(1,r_max)];
    A_ = [zeros(1,l_max), ones(1,r_max)];
    b_ = ceil(A);
    Aeq = [ones(1,l_max), zeros(1,r_max); (1:l_max), -(1:r_max)];
    beq = [n - sum(L_hat); sum(R_hat) - sum(L_hat)];
    lb = zeros(1,l_max+r_max);
    ub = ones(1,l_max+r_max);
    intcon = 1:l_max+r_max;

    x = intlinprog(f,intcon,A_,b_,Aeq,beq,lb,ub);


    f = -[zeros(1,l_max), ones(1,r_max)];
    A_ = [zeros(1,l_max), ones(1,r_max)];
    b_ = -floor(A);
    Aeq = [ones(1,l_max), zeros(1,r_max); (1:l_max), -(1:r_max)];
    beq = [n - sum(L_hat); sum(R_hat) - sum(L_hat)];
    lb = zeros(1,l_max+r_max);
    ub = ones(1,l_max+r_max);
    intcon = 1:l_max+r_max;

    x2 = intlinprog(f,intcon,A_,b_,Aeq,beq,lb,ub);
    
    % One of them should have returned a solution
    if sum(x) == 0
        x = x2;
    end

    Lambda = L_hat + x(1:l_max).';
    Rho = R_hat + x(l_max+1:end).';
    
end

% Currently unused
function [Lambda,Rho] = findLdpcPolynomialsExact(rho,lambda,r,l_max)
    % Find denominator of fractions
    denom = 0;
   
    for i=1:l_max
        denom = denom + lambda(i)/(i);
%         denom = denom + lambda(i)/(i+1);
    end

    % Transform all lambda values to fractions
    lambda_frac = zeros(2,l_max);
    for i=1:l_max
%         num = lambda(i) / ((i+1)*denom);
        num = lambda(i) / ((i)*denom);
        [rationalNumerator, rationalDenominator] = rat(num);
        lambda_frac(1,i) = rationalNumerator;
        lambda_frac(2,i) = rationalDenominator;
    end
    
    % Transform all rho values to fractions
    rho_frac = zeros(2,r+1);
    for i=1:r+1
        num = rho(i) / (i*denom);
        [rationalNumerator, rationalDenominator] = rat(num);
        rho_frac(1,i) = rationalNumerator;
        rho_frac(2,i) = rationalDenominator;
    end
    
    % Gather the denominators of all fractions in an array
    Di = [lambda_frac(2,:), rho_frac(2,:)];
    
    % n is the least common multiple of the denominators
    % Initialize the least common multiple with the first two elements
    n = lcm(Di(1), Di(2));

    % Iterate over the remaining elements to find the overall least common multiple
    for i = 3:length(Di)
        n = lcm(n, Di(i));
    end
    
    % Finally, find the coefficients for Lambda and Rho polynomials
    Lambda = zeros(1,l_max);
    for i=1:l_max
        Lambda(i) = lambda_frac(1,i) * n / lambda_frac(2,i);
    end
    
    Rho = zeros(1,r+1);
    for i=1:r+1
        Rho(i) = rho_frac(1,i) * n / rho_frac(2,i);
    end
    
end