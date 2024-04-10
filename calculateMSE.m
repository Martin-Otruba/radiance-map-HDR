function mse = calculateMSE(image1, image2)
    % Ensure images are of the same size
    assert(isequal(size(image1), size(image2)), 'Images must have the same dimensions.');
    
    % Convert images to double precision
    image1 = im2double(image1);
    image2 = im2double(image2);
    
    % Calculate squared differences for all color channels simultaneously
    squaredError = (image1 - image2).^2;
    
    %   % Ignore non-numeric values and calculate the mean squared error
    % validPixels = ~isnan(squaredError(:)) & ~isinf(squaredError(:));
    % if any(validPixels)
    %     mse = mean(squaredError(validPixels));
    % else
    %     mse = NaN;  % If all pixels are NaN or Inf, return NaN
    % end

    mse = mean(squaredError(:));
end