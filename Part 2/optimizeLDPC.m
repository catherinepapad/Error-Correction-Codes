function [rho,lambda] = optimizeLDPC(r,r_avg,l_max,epsilon,interval)
    % Polynomial rho(x)
    rho = zeros(1,r+1);
    rho(2) = r*(r+1-r_avg)/r_avg;
    rho(1) = (r_avg - r*(r+1-r_avg))/r_avg;
    
    % Polynomial lambda(x)
    lambda = zeros(l_max-1,1);
    
    
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
    A = constraint3(epsilon,rho,l_max,interval);

    % Constraint 2
    A_size = size(A);
    for i=1:l_max-1
        A(A_size(1)+i,i)=-1;
%         A(i,i)=-1;
    end
    
    % b matrix
    A_size = size(A);
    b = zeros(1,A_size(1));
    
    % No bounds on decision variables
    lb = [];
    ub = [];
    
    % Solve with linprog
%     x = linprog(f, A, b, Aeq, beq, lb, ub);
    x = linprog(f, A, b, Aeq, beq);
    disp('Optimal solution:');
    disp(x);
    
end


%% FUnction for contraint No3
function A = constraint3(epsilon,rho,l_max,interval)
    % Split [0,1] to equal parts by interval
    x = [];
    for i=0:interval:1  
        x = [x, i];
    end
    
    % Length of x matrix
    length = 1/interval + 1;
    
    if (length < 4)
        disp('Insufficient discretization')
        return
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
    
    % Fill A
    for i=1:l_max-1
            for j=1:length 
                A(j+length*(i-1),i) = epsilon*(1-subs(symbolic_rho, y, 1-x(j)))^i;
            end
    end
end