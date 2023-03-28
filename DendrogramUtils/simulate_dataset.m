function simulate_dataset()
% Define number of points per line and number of outliers
num_points_per_line = randi([40,120]); % Randomly choose number of points per line between 5 and 10
num_outliers = randi([40,140]); % Randomly choose number of outliers between 5 and 10

% Initialize data and labels matrices
data = [];
labels = [];

% Generate 3 lines crossing each other
for i = 1:3
    % Generate random slope and intercept
    slope = randn()*2;
    intercept = randn()*2;
    
    % Generate x and y coordinates for points on the line
    x = linspace(-1, 1, num_points_per_line);
    y = slope*x + intercept;
    
    % Add noise to y coordinates
    noise = randn(1, num_points_per_line)*0.5;
    y = y + noise;
    
    % Add points to data matrix and assign labels
    data = [data; [x', y']];
    labels = [labels; ones(num_points_per_line,1)*i];
end

% Generate 2 independent and well-separated lines
for i = 4:5
    % Generate random slope and intercept
    slope = randn()*2;
    intercept = randn()*10;
    
    % Generate x and y coordinates for points on the line
    x = linspace(-1, 1, num_points_per_line);
    y = slope*x + intercept;
    
    % Add noise to y coordinates
    noise = randn(1, num_points_per_line)*0.5;
    y = y + noise;
    
    % Add points to data matrix and assign labels
    data = [data; [x', y']];
    labels = [labels; ones(num_points_per_line,1)*i];
end

% Shuffle data and labels
perm = randperm(size(data,1));
data = data(perm,:);
labels = labels(perm);

% Generate outliers
outliers_x = rand(num_outliers, 1)*2 - 1; % Generate random x coordinates between -5 and 5
outliers_y = rand(num_outliers, 1)*2 - 1; % Generate random y coordinates between -5 and 5
outliers = [outliers_x, outliers_y];
data = [data; outliers];
labels = [labels; zeros(num_outliers,1)]; % Assign label 0 to outliers

% Set the axis limits to ensure all lines are visible
axis_limits = [-1, 1, -1, 1];

% Plot data and labels
figure;
scatter(data(:,1), data(:,2), 30, labels, 'filled');
axis(axis_limits);
xlabel('x');
ylabel('y');
title('Generated Dataset');


end

