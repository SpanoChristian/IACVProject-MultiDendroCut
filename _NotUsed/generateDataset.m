function [X, G] = generateDataset(num_clusters)
    X = [];
    G = [];
    
    figure
    xlim([-1 1])
    ylim([-1 1])
    
    for i = 1:num_clusters+1
        if i == num_clusters+1
            title("Outliers", "FontSize", 15)
            clustLbl = 0;
        else
            title("Cluster " + i, "FontSize", 15)
            clustLbl = i;
        end
        
        % Initialize counter variable
        count = 0;
        
        % Wait for the user to click on the figure
        while count < 50
            [x, y] = ginput(5); % Only wait for one click at a time
            count = count + 5; % Increment counter
            title(sprintf('Number of clicks: %d', count), "FontSize", 15); % Update figure title
        end
        
        h = warndlg("Next Cluster!");
        uiwait(h);
        
        % Number of selected points
        n = length(x);
        
        G = [G; clustLbl*ones(n, 1)];

        % Save X and Y positions as a vector
        X = [X; [x, y]];
    end
    close(gcf);
end

