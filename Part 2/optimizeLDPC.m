function [rho,lambda] = optimizeLDPC(r,r_avg,l_max,epsilon,interval)
    % Polynomial rho(x)
    rho = zeros(1,r+1);
    rho(2) = r*(r+1-r_avg)/r_avg;
    rho(1) = (r_avg - r*(r+1-r_avg))/r_avg;
    
    
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
    [A,b] = constraint3(epsilon,rho,l_max,interval);

    % Constraint 2
    A_size = size(A);
    for i=1:l_max-1
        A(A_size(1)+i,i)=-1;
        b(A_size(1)+i) = 0;
    end
    
    % Bounds on decision variables
%     lb = [];
    lb = zeros(1,l_max-1);
%     ub = [];
    ub = ones(1,l_max-1);
    
    % Solve with linprog
    lambda = linprog(f, A, b, Aeq, beq, lb, ub);
    disp('Optimal solution:');
    disp(lambda);
    
    rho = flip(rho);
    
end


%% FUnction for contraint No3
function [A,b] = constraint3(epsilon,rho,l_max,interval)
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
    
    % Create a symbolic variable
    syms y;

    % Create the symbolic polynomial using the coefficients
    symbolic_rho = poly2sym(rho, y);
   
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