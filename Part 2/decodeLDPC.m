function x = decodeLDPC(H, y, max_iter, interactive)
    % decodeLDPC - Decoder for irregular LDPC codes in the binary erasure channel
    % 
    %   x = decodeLDPC(H, y, max_iter, interactive) decodes the received vector y
    %   using the parity check matrix H. The decoding is done using an iterative
    %   message passing algorithm. The algorithm is stopped if either the algorithm
    %   converges or the maximum number of iterations is reached.
    %   If interactive is true, the decoding process is visualized in a GUI.
    %
    % Parameters:
    %   H: parity check matrix
    %   y: received vector (erasures are represented by NaNs)
    %   max_iter: maximum number of iterations
    %   interactive: if true, allows interactive stepping through iterations
    % 
    % Output:
    %   x: decoded vector
    %    If decoding is successful, x is a vector of 0s and 1s.
    %    If decoding fails, x is NaN.
    % 
    % Example:
    % H =  [1 1 0 0 1 0;
    %       0 1 1 0 0 1;
    %       1 0 0 1 0 1];
    % y = [NaN; 1; 0; NaN; 1; 0];
    % x = decodeLDPC(H, y, 10, true);

    arguments 
            H               (:,:)   double      {mustBeMember(H, [0, 1])}
            y               (:,1)   double      {}
            max_iter        (1,1)   double      {mustBeInteger, mustBePositive}
            interactive     (1,1)   logical  
    end

    % Initialization
    [m, n] = size(H);

    % If visualizing, keep history of y values
    if interactive
        y_history = zeros(max_iter, n);  
        y_history(1, :) = y;
    end

    % Decoding iterations
    for iter = 1:max_iter
        %  Do one iteration of decoding
        [y_next, has_updated] = decodeIteration(H, y);
        y = y_next;
        
        % If no updates, then decoding is done
        if ~has_updated
            break;
        end

        % Update history
        if interactive
            y_history(iter+ 1 , :) = y;
        end
    end

    if interactive
        % Truncate y_history to the number of iterations
        y_history = y_history(1:iter, :);
        % Visualize
        createLDPCDecodingPlot(H, y_history);
    end

    % Final output
    if sum(isnan(y)) > 0
        x = NaN;
    else
        x = y;
    end
end


% Function to do single iteration of decoding
function [y_next, has_updated ] = decodeIteration(H, y)

    arguments (Input)
            H               (:,:)   double      {mustBeMember(H, [0, 1])}
            y               (:,1)   double      {}
    end
    arguments (Output)
        y_next          (:,1)   double      {}
        has_updated     (1,1)   logical  
    end

    [m, n] = size(H);
    has_updated = false;
    y_next = y;

    % Iterate over check nodes (rows of H)
    for i = 1:m
        edges = find(H(i, :) == 1);
        % If only one incoming erased message (NaN), then set the outgoing
        % message to mod-2 sum of the incoming messages
        idx = isnan(y(edges));
        if sum(idx) == 1
            y_next(edges(idx)) = mod(sum(y(edges(~idx))), 2);
            has_updated = true;
        end
    end
end


function createLDPCDecodingPlot(H, y_history)
    [m, n] = size(H);
    [G, variableNodes, checkNodes] = createBipartiteGraph(H);

    current_iter = 1;
    max_iter = size(y_history, 1);

    % Setup the figure and GUI elements
    fig = figure(1);
    clf(fig);
    
    prevButton = uicontrol(fig, 'Style', 'pushbutton', 'String', 'Previous', 'Position', [20 20 50 20], 'Callback', @prevnextCallback);
    nextButton = uicontrol(fig, 'Style', 'pushbutton', 'String', 'Next',    'Position', [100 20 50 20], 'Callback', @prevnextCallback);

    function prevnextCallback(t1,~)
        if t1.String == "Previous"
            current_iter = max(1, current_iter - 1);
            % if current_iter > 1
            %     current_iter = current_iter - 1;
            %     plotGraph(current_iter);
            % end
        elseif t1.String == "Next"
            current_iter = min(current_iter + 1, max_iter);
            % if current_iter < max_iter
            %     current_iter = current_iter + 1;
            %     plotGraph(current_iter);
            % end
        end
        plotGraph(current_iter);
    end

    % Initial Plot
    plotGraph(current_iter);

    % Function to plot the graph
    function plotGraph(iter)
        y = y_history(iter, :);
        % Manually calculate x-y coordinates and create the plot
        yData = [(0:n-1)/(n-1), (0:m-1)/(m-1)];
        xData = [zeros(1, n), ones(1, m)];
        h = plot(G, 'XData', xData, 'YData', yData);
        title(sprintf('LDPC Decoding - Iteration %d', iter-1));
        
        % Iterate over variable nodes to add colors and line styles
        for i = 1:n
            % Get node number in the graph
            node = variableNodes(i);
            % Get all edges connected to this node
            edges = outedges(G, node);
            if isnan(y(i))
                % Erased node: red, dashed edges
                highlight(h, node, 'NodeColor', [1 0 0]);
                highlight(h, 'Edges', edges, 'LineStyle', '--');
            elseif y(i) == 0
                % y==0: thin gray edges
                highlight(h, 'Edges', edges, 'LineWidth', 1, 'EdgeColor', [0.5 0.5 0.5]);
            else
                % y==1: thick black edges
                highlight(h, 'Edges', edges, 'LineWidth', 1.5, 'EdgeColor', [0 0 0]);
            end
        end

        % Label variable nodes with their values
        h.NodeLabel(1:n) = arrayfun(@(x) sprintf('%d', x), y, 'UniformOutput', false);
        h.NodeLabel(n+1:n+m) = arrayfun(@(x) sprintf('C%d', x), 1:m, 'UniformOutput', false);
        
        drawnow;
    end
end

function [G, variableNodes, checkNodes] = createBipartiteGraph(H)
    % Create a bipartite graph from the parity check matrix H
    % Returns the graph, and the variable and check nodes' indices
    [m, n] = size(H);
    G = graph();
    variableNodes = 1:n;
    checkNodes = n+1:n+m;
    G = addnode(G, n+m);
    for i = 1:m
        for j = 1:n
            if H(i,j) == 1
                G = addedge(G, checkNodes(i), variableNodes(j));
            end
        end
    end
end