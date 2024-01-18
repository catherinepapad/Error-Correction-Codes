function [Lambda,Rho] = findLdpcPolynomials(rho,lambda,r,l_max)
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