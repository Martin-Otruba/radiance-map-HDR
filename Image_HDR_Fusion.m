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

montage(imageList);
montageFilename = [pictureName +'_montage.png'];
saveas(gcf, montageFilename);

relative_times = exposure_times./mean(exposure_times);

hdr = makehdr(imageList,'RelativeExposure',relative_times); %tu vstupuje relativna expozicia 

rgb = tonemap(hdr);

%imshow(rgb)
imshow(hdr)


%folder where images are saved, !!explore, difference btw imwrite and
%hdrwrite/read functions
saveFolder = 'C:\Users\Martin\Documents\Vzdelanie\Inzinierske FEI\ZS2rocnik\DP\Matlab_vsetko\MatlabProjekt\Saved_Output';
tonemappedFilename = fullfile(saveFolder, [pictureName '_HDR_RL_mean.png']);
tonemappedFilename_HDR = fullfile(saveFolder, [pictureName '_HDRwrite.png']);
imwrite(rgb, tonemappedFilename);
hdrwrite(im2double(rgb), 'blabla');
blablaHDR = hdrread('blabla');




