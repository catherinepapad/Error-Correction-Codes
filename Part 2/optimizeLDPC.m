function [rho_correct,lambda_correct] = optimizeLDPC(r,r_avg,l_max,epsilon,interval)
    % rho_correct starts from rho_1 
    % lambda starts from lambda_1
    % coefficient with index 1 corresponds to x^0

    % Polynomial rho(x)
    rho = zeros(1,r+1);
    rho(2) = r*(r+1-r_avg)/r_avg;
    rho(1) = (r_avg - r*(r+1-r_avg))/r_avg;
    
    % Create a symbolic variable
    syms y;

    % Create the symbolic polynomial using the coefficients
    symbolic_rho = poly2sym(rho, y);
    
    % Flip rho(x) to have the coefficients in the correct order
    rho_correct = flip(rho);
    
    % Create the derivative of rho
    rho_dot = rho_correct(:,2:r+1);
    
    % rho_dot(1) = sum of all rho_dot coefficients
    rho_dot_1 = 0;
    
    for i=1:r
        rho_dot(i) = rho_dot(i)*i;
        rho_dot_1 = rho_dot_1 + rho_dot(i);
    end
    
    
    %% Optimization problem for finding optimal lambda(x)
    % Objective function
    f = arrayfun(@(x) -1/(x+1), 1:l_max-1);
    
    % Constraint 1
    Aeq = ones(1,l_max-1); 
    beq = 1;
    

    % Constraint 2
    [A,b,x] = constraint2(epsilon,symbolic_rho,l_max,interval);

    
    % Additional constraint
    A_size = size(A);
    A(A_size(1)+1,1) = 1;
    A(end+1,1) = 1;
    b(end+1) = 1/(epsilon*rho_dot_1); 
    
    
    % Constraint 3
    for i=1:l_max-1
        A(end+1,i)=-1;
        b(end+1) = 0;
    end
    
    
    % Bounds on decision variables
%     lb = [];
    lb = zeros(1,l_max-1);
%     ub = [];
%     ub = zeros(1,l_max-1)+0.33;
    ub = ones(1,l_max-1);
    
    
    % Solve with linprog to find polynomial lambda(x)
    lambda = linprog(f, A, b, Aeq, beq, lb, ub);
    disp('Optimal solution:');
    disp(lambda);
    
    % For validation purposes
    any(sum(A(1:length(x),:)*lambda ,2) > x'./epsilon,'all')
    
    
    % Add a zero so lambda(x) starts from lambda_1
    lambda_correct = [0; lambda];
    
    
   
end


%% FUnction for contraint No2
function [A,b,x] = constraint2(epsilon,symbolic_rho,l_max,interval)
    % Create a symbolic variable
    syms y; 

    % Split (0,1) to equal parts by interval 
    x = [];
    for i=0:interval:1  
        x = [x, i];
    end
    
    x = linspace(0,1,1000);
%     x = logspace(-10,0,1000);
    
    if (length(x) < 3)
        error('Insufficient discretization')
    else
        x = x(:,2:end-1);
    end
    
    % Length of x matrix
    len = length(x);
    
    % Initialize contraint matrix A
    A = zeros(len,l_max-1);
    b = zeros(1,len);
    
    % Fill A
    for j=1:len
            for i=1:l_max-1 
                A(j,i) =  ( 1 - subs(symbolic_rho, y, 1-x(j)) )^i;
            end
            b(j) = x(j) / epsilon;
    end
    
end