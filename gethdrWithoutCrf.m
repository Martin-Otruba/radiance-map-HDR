clear all
close all

%folder where images are retrieved from
folder = 'C:\Users\Martin\Desktop\Ximea_test_Python\Pictures';

pictureName = 'xi_stripLED';

% Get a list of all files in the folder matching the pattern 'xi_RGB*'
pattern1 = [pictureName, '*.TIFF'];
fileList = dir(fullfile(folder, pattern1));
imageList = cell(1, numel(fileList));

for i = 1:numel(fileList)
    filename = fullfile(folder, fileList(i).name);
    imageList{i} = imread(filename);
end

% Get a list of exposure times for the image
pattern2 = [pictureName, '*.txt'];
fileListTxt = dir(fullfile(folder, pattern2));
filenameTxt = fullfile(folder, fileListTxt(1).name);
exposure_times = load(filenameTxt)';

%yaciatok funkcie inicializuje prazdne polia plne 0, alebo false
hdr = false(size(imageList(1)));
someUnderExposed = false(size(imageList(1)));
someOverExposed = false(size(imageList(1)));
someProperlyExposed = false(size(imageList(1)));
for p = 1:numel(imageList)
   
    % Convert log2 EV equivalents to decimal values.
    %relExposure = 2 .^ options.ExposureValues(p);

    relExposure = exposure_times(p);

    % Read the LDR image
    ldr = imageList{p};
    
    underExposed = ldr < 0.02 * relExposure(end);
    someUnderExposed = someUnderExposed | underExposed;
    
    overExposed = ldr > 0.98 * relExposure(end);
    someOverExposed = someOverExposed | overExposed;
    
    properlyExposed = ~(underExposed | overExposed);
    someProperlyExposed = someProperlyExposed | properlyExposed;
    
    properlyExposedCount(properlyExposed) = properlyExposedCount(properlyExposed) + 1;
    
    % Remove over- and under-exposed values.
    ldr(~properlyExposed) = 0; %properlyExposed * ldr !!!!!robi to iste
    
    % Bring the intensity of the LDR image into a common HDR domain by
    % "normalizing" using the relative exposure, and then add it to the
    % accumulator.
    hdr = hdr + single(ldr) ./ relExposure;
end
% Average the values in the accumulator by the number of LDR images
% that contributed to each pixel to produce the HDR radiance map.
hdr = hdr ./ max(size(properlyExposed), 1);

% For pixels that were completely over-exposed, assign the maximum
% value computed for the properly exposed pixels.
maxVal = max(hdr(someProperlyExposed));
if ~isempty(maxVal)
    % If maxVal is empty, then none of the pixels are correctly exposed.
    % Don't bother with the rest; hdr will be all zeros.
    hdr(someOverExposed & ~someUnderExposed & ~someProperlyExposed) = maxVal;
end

% For pixels that were completely under-exposed, assign the
% minimum value computed for the properly exposed pixels.
minVal = min(hdr(someProperlyExposed));
if ~isempty(minVal)
    % If minVal is empty, then none of the pixels are correctly exposed.
    % Don't bother with the rest; hdr will be all zeros.
    hdr(someUnderExposed & ~someOverExposed & ~someProperlyExposed) = minVal;
end

% For pixels that were sometimes underexposed, sometimes
% overexposed, and never properly exposed, use regionfill.
fillMask = someUnderExposed & someOverExposed & ~someProperlyExposed;
if any(fillMask(:))
    hdr(:,:,1) = regionfill(hdr(:,:,1), fillMask(:,:,1));
    if ~ismatrix(hdr)
        hdr(:,:,2) = regionfill(hdr(:,:,2), fillMask(:,:,2));
        hdr(:,:,3) = regionfill(hdr(:,:,3), fillMask(:,:,3));
    end
end
