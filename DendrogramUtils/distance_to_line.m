function distance = distance_to_line(a, b, c, X, Y)
% Computes the distance between a line and a set of points
% specified by their x and y coordinates.

% Compute the denominator of the distance formula
denom = sqrt(a^2 + b^2);

% Compute the signed distance between each point and the line
signed_distance = (a*X + b*Y + c) / denom;

% Take the absolute value of the signed distance to get the distance
distance = abs(signed_distance);
end
