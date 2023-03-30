function [X, G] = lines2dataset(P)

    % Generate x values for the line
    x = linspace(-1, 1, 100);
    
    X = zeros(2, 0);
    G = [];

    % seed the random number generator with the current time
    rng('shuffle');
    
    for l = 1:length(P)
        % Initialize empty arrays to store the data points
        x_data = [];
        y_data = [];
        noise_level = 0.05 + rand() * 0.05;
        % Generate data points until we have 50 that lie within the range [-0.75, 0.75]
        while length(x_data) < 50
            % Generate a random x value within the range [-0.75, 0.75]
            x_rand = rand(1) * 1.5 - 0.75;

            % Evaluate the corresponding y value on the line with random noise
            y_rand = P(l, 1) * x_rand + P(l, 2) + noise_level * randn();

            % Check if the generated point lies within the range [-0.75, 0.75]
            if abs(x_rand) <= 0.75 && abs(y_rand) <= 0.75
                x_data = [x_data, x_rand];
                y_data = [y_data, y_rand];
            end
        end
        
        X = [X [x_data; y_data]];
        G = [G; l*ones(length(x_data), 1)];
        
    end
    
%     % Add outliers
%     x_out = -0.65 + rand(1, 50) * 1.3;
%     y_out = -0.65 + rand(1, 50) * 1.3;
%     
%     X = [X [x_out; y_out]];
%     G = [G; 0*ones(length(x_out), 1)];
    
end

