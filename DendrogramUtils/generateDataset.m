function [X, G] = generateDataset(num_clusters)
    X = [];
    G = [];
    
    for i = 1:num_clusters+1
        if i == num_clusters+1
            title("Outliers")
            clustLbl = 0;
        else
            title("Cluster " + i)
            clustLbl = i;
        end
        
        % Wait for the user to click on the plot
        [x, y] = ginput();
        
        % Number of selected points
        n = length(x);
        
        G = [G; clustLbl*ones(n, 1)];

        % Save X and Y positions as a vector
        X = [X; [x, y]];
    end
    close(gcf);
end

