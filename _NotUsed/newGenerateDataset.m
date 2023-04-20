function P = newGenerateDataset(data)
    plot(data(1, :), data(2, :), "o")
    i = 1;
    P = zeros(0, 2);
    % Loop over each line to fit
    while true
        % Wait for user to select points for line
        [x_line, y_line] = ginput;

        % Fit line to selected points
        P(i, :) = polyfit(x_line, y_line, 1);

        % Ask user if they want to fit another line
        button = questdlg('Fit another line?', 'Line Fit', 'Yes', 'No', 'No');

        % If user does not want to fit another line, exit loop
        if strcmp(button, 'No')
            break;
        end
        i = i + 1;
    end
    
end

