% Michael Omori
% This program, rmsContrast, finds the root mean square contrast of an image

% works for tifs, png, jpg, binary, uint8, cuts into 9 secions and takes rmsContrast
% value for each section, then calculates average rms for the entire image
% contrast values range from 0(low) to 1(high)
% rms value is slightly differnt from taking rms of entire image
% rms values saved in 3x3 matrix, should change some values to allow
% for different number of sections
% converts grayscale with one color channel

    clear;
    clc;
    image = 'Intact_skull_Manual.jpeg';
    imageName = image(1:length(image) - 4)
    imageName_extension = image(length(image) - 3: length(image));
    sections = 9;
    % can crop image to desired width and height
    %userWidth = 700;
    %userHeight = 700;

    a = imread(image);
    aOriginal = a;
    [rowsa, columnsa, ColorChannelsa] = size(a);
    
    if ColorChannelsa == 3
        aOriginal = rgb2gray(a);
    elseif ColorChannelsa == 4
        % shouldn't normally do this, just for these images, the fourth color
        % channel was full of nothing
        atemp = a(:,:,1:3);
        aOriginal = rgb2gray(atemp);
    end
        
    % want to make sure images are same dimensions
    % made them 753 x 753
    %A = aOriginal(1:userHeight,1:userWidth,:);
    A = aOriginal;
    
    % The width, height, and number of color channels of the image
    % Four channels for tif: Cyan, Magenta, Yellow, Black
    % crops the image so the width and heighth are factors of the # of
    % sections
        [rows, columns, ColorChannels] = size(A);
        rowsRem = rem(rows, sections.^(1/2));
        rowsNew = rows - rowsRem;
        rowsNew_divided = rowsNew / (sections.^(1/2));
        columnsRem = rem(columns, sections.^(1/2)); 
        columnsNew = columns - columnsRem;
        columnsNew_divided = columnsNew / (sections.^(1/2));
        totalPixels = rowsNew_divided * columnsNew_divided;
        croppedImage = A(1:rowsNew, 1:columnsNew, :);
        rmsValue = zeros(sections.^(1/2));
        % 9 images cropped from original (works only for 9 images now)
        if(ColorChannels > 1)
            splitImage = mat2cell(croppedImage, [rowsNew_divided rowsNew_divided rowsNew_divided], [columnsNew_divided columnsNew_divided columnsNew_divided], [ColorChannels]);
        else 
            splitImage = mat2cell(croppedImage, [rowsNew_divided rowsNew_divided rowsNew_divided], [columnsNew_divided columnsNew_divided columnsNew_divided]);
        end
    plotNumber = 1;
    for n = 1:(sqrt(sections))
        for m = 1:(sqrt(sections))
        % Convert to double to increase precision, then normalize
        Asplit = (cell2mat((splitImage(n, m))));
        Adouble = double(Asplit);
        %%s is used for strings
        imageFile = sprintf('%s_%dx%d%s', imageName, n, m, imageName_extension);
        Adouble_normal = Adouble / 255;
        % imwrite and imshow can't display 4 channels
        % gets rid of k channel in tif for displaying purposes
        Asplit3 = Asplit;
        if ColorChannels == 4
            Asplit3 = Asplit(:,:,1:3);
        else
            Asplit3 = Asplit(:,:,1:ColorChannels);
        end
       % imwrite(Asplit3, imageFile);
        subplot(sqrt(sections),sqrt(sections), plotNumber), imshow(Asplit3)
        plotNumber = plotNumber + 1;
        % Need to divide by largest value instead of 255 for image with 1s and 0s

        % Variables for rms calculation in for loop
        mean_intensity = mean(Adouble_normal(:));
        runningTotal = 0;

        % Difference between each pixel intenisty and mean, square it.
        % Add these differences to a runningTotal
        % Divide the runningTotal by the totalPixels
        for x = 1:rowsNew_divided
            for y = 1:columnsNew_divided
                pixelIntensities = Adouble_normal(x, y, 1:ColorChannels);
                pixelMean = mean(pixelIntensities);
                runningTotal = (pixelMean - mean_intensity).^2 + runningTotal;
            end
        end
        % 2 scales values between 0 and 1
        rmsValue(n, m) = 2 * (runningTotal / totalPixels).^(1/2);
        end
    end
    rmsValue_average = mean(rmsValue(:))
