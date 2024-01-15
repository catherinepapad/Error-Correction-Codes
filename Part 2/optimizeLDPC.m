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
    f = zeros(1,l_max-1);

    for i=1:l_max-1
      f(i) = -1/(i+1);  
    end
    
    % Constraint 1
    Aeq = ones(1,l_max-1); 
    beq = 1;
    
    % Constraint 3
    [A,b] = constraint3(epsilon,symbolic_rho,l_max,interval);

    % Constraint 2
    A_size = size(A);
    for i=1:l_max-1
        A(A_size(1)+i,i)=-1;
        b(A_size(1)+i) = 0;
    end
    
    % Additional constraint
    A_size = size(A);
    A(A_size(1)+1,1) = 1;
    b(A_size(1)+1) = 1/(epsilon*rho_dot_1); 
    
    % Bounds on decision variables
%     lb = [];
    lb = zeros(1,l_max-1);
%     ub = [];
    ub = ones(1,l_max-1);
    
    % Solve with linprog to find polynomial lambda(x)
    lambda = linprog(f, A, b, Aeq, beq, lb, ub);
    disp('Optimal solution:');
    disp(lambda);
    
    
    % Add a zero so lambda(x) starts from lambda_1
    lambda_correct = [0; lambda];
end


%% FUnction for contraint No3
function [A,b] = constraint3(epsilon,symbolic_rho,l_max,interval)
    % Create a symbolic variable
    syms y; 

    % Split [0,1] to equal parts by interval
    x = [];
    for i=0:interval:1  
        x = [x, i];
    end
    
    % Length of x matrix
    length = 1/interval + 1;
    
    if (length < 4)
        error('Insufficient discretization')
    else
        x = x(:,2:length-1);
        length = length  - 2;
    end
    
    % Initialize contraint matrix A
    A = zeros((l_max-1)*length,l_max-1);
    b = zeros(1,(l_max-1)*length);
    
    % Fill A
    for i=1:l_max-1
            for j=1:length 
%                 A(j+length*(i-1),i) = epsilon*(1-subs(symbolic_rho, y, 1-x(j)))^i;
                A(j+length*(i-1),i) = (1-subs(symbolic_rho, y, 1-x(j)))^i;
                b(j+length*(i-1)) = x(j) / epsilon;
            end
    end
end