% Michael Omori
% This program, rmsContrast, finds the root mean square contrast of an image
% Output: rmsContrast value of an image
% Inputs: image, varargin(number of sections to split the image into)

% TO DO: create error message if not the right number of inputs

function rmsValue = rmsContrast(image, varargin)
    % required input image, optional input sections, currently only one
    numvarargs = length(varargin);
    % default value for number of sections
    optargs = {1};
    % set user value for number of sections
    optargs(1:numvarargs) = varargin;
    % save input in sections
    [sections] = optargs{:};

    A = imread(image);

    % The width, height, and number of color channels of the image
    % Four channels for tif: Cyan, Magenta, Yellow, Black
        [rows, columns, ColorChannels] = size(A);
        %[maxVal,maxInd] = max(A(:));
        totalPixels = rows * columns;

    % Convert to double to increase precision, then normalize
    Adouble = double(A);
    Adouble_normal = Adouble / 255;
    % Need to divide by largest value instead of 255 for image with 1s and 0s

    % Variables for rms calculation in for loop
    mean_intensity = mean(Adouble_normal(:));
    runningTotal = 0;

    % Difference between each pixel intenisty and mean, square it.
    % Add these differences to a runningTotal
    % Divide the runningTotal by the totalPixels
    for x = 1:rows
        for y = 1:columns
            pixelIntensities = Adouble_normal(x, y, 1:ColorChannels);
            pixelMean = mean(pixelIntensities);
            runningTotal = (pixelMean - mean_intensity).^2 + runningTotal;
        end
    end
    % 2 scales values between 0 and 1
    rmsValue = 2 * (runningTotal / totalPixels).^(1/2);

end
