clear all
close all

%% toto je replikacia algoritmu makehdr
% Folder kam exportuje Ximea
folder = 'C:\Users\Martin\Desktop\Ximea_test_Python\Pictures';

% Nazov aktualne vyzadovaneho exportu
pictureName = 'xi_stripLED';

% Nacita obrazky zo zlozky kam exportuje kamera so specifickou castou nazvu
pattern1 = [pictureName, '*.TIFF'];
fileList = dir(fullfile(folder, pattern1));
imageList = cell(1, numel(fileList));

for i = 1:numel(fileList)
    filename = fullfile(folder, fileList(i).name);
    imageList{i} = char(imread(filename));
    imageList2{i} = (imread(filename));
end

% Nacita prislusny zoznam Expozicnych casov
pattern2 = [pictureName, '*.txt'];
fileListTxt = dir(fullfile(folder, pattern2));
filenameTxt = fullfile(folder, fileListTxt(1).name);
exposure_values = load(filenameTxt)';

relative_times = exposure_values./exposure_values(1);
%./mean(exposure_values);

normalized_intensity = zeros(size(imageList(1)));
count = zeros(size(imageList(1)));
position_over_exposed = zeros(size(imageList(1)));
position_under_exposed = zeros(size(imageList(1)));
position_reliable_exposed = zeros(size(imageList(1)));

%% Prechadza napriec vsetkymi LDR obrazkami
for i = 1:numel(imageList)
    ldr_image = imageList{i};
    info_ldr_image = imageList2{i};
  
    % Ziska rozmery obrazka a tiez kolko ma vrstiev, dalej ziska bitdepth
    % aby vedel urcit rozsah v ktorom sa nachadza obrazok (unit8/16) ak by
    % som mal ine formaty najde sposob ako ziskat dimenziu.
    [rows, cols, channels] = size(info_ldr_image);
    bitDepth = channels*str2double(regexp(class(info_ldr_image),'\d+','match'));
    bitsPerSample = bitDepth / channels;
    
    maxVal = 2^bitsPerSample-1;
    min_limit = round(0.02 * maxVal);
    max_limit = round((1-0.02) * maxVal);

    % triedi pixely podla hornej a dolnej hranice ne pre/pod expon.
    under_exposed = ldr_image < min_limit;
    position_under_exposed = position_under_exposed | under_exposed;
    
    % ku kazdemu si pamata kde sa nachadzaju pozicie pixelov napriec celym
    % for cyklom
    over_exposed = ldr_image > max_limit;
    position_over_exposed = position_over_exposed | over_exposed;

    % Vytvori masku pixelov bez tych za min/max hranicou
    reliable_pixels = ~(under_exposed | over_exposed);
    position_reliable_exposed = position_reliable_exposed | reliable_pixels;
  
    % pouzije masku na LDR obrazok
    adjusted_image = ldr_image .* reliable_pixels;
  
    % normalizuje intenzitu pomocou relativnej expozicie aby dostal obrazok
    % do rozsahu HDR a zaroven prisposobil to ze tmave casti budu viac
    % prispievat k vyslednemu obrazku z nad exponovaneho LDR a svetlejsie z
    % podexponovaneho 
    normalized_intensity = normalized_intensity + adjusted_image ./ relative_times(i);

    % pocita kolko spolahlivych pixelov na mieste kazdeho pixelu napriec
    % obrackami vstupujucimi do for cyklu, neskorpouzite vahovane
    % premerovanie podla prispevkov do vysledneho HDR obrazka
    count = count + reliable_pixels;
    count(count == 0) = 1;
end

% Pocita vahovany priemer normalizovanej intenzity pixelov
hdr_custom = normalized_intensity ./ count;

%% Fungovalo mi to aj bez tejto casti, pridal som ju tam z makehdr, porovnam a nebol v tom rozdiel

% pridava maximalnu hodnotu spomedzi spolahlivych pixelov vysledneho HDR
% obrazka na miesta kde boli len pre-exponovane pixely
maxValuePost = max(hdr_custom(position_reliable_exposed));
if ~isempty(maxValuePost)
    hdr_custom(position_over_exposed & ~position_under_exposed & ~position_reliable_exposed) = maxValuePost;
end

% pridava minimalnu hodnotu spomedzi spolahlivych pixelov vysledneho HDR
% obrazka na miesta kde boli len pod-exponovane pixely.
% podmienka if je tam na to nech skusi ci vobec existuje taka hodnota ale to
% by znamenalo ze obrazok su same nuly
minValuePost = min(hdr_custom(position_reliable_exposed));
if ~isempty(minValuePost)
    hdr_custom(~position_over_exposed & position_under_exposed & ~position_reliable_exposed) = minValuePost;
end

% Vyplni pixely ktore boli po cely cas len pre/pod-exponovane. skusa
% podmienku ci nieco vyhovuje fillMask, ak ano spravi to pre privy kanal ,
% ten by bol pre sedotonovy len jeden. Ak je to obrazok RGB skusa ci je to
% matica a potom vyplni aj ostatne vrstvy G,B pomocou funkcie regionfill
fillMask = position_under_exposed & position_over_exposed & ~position_reliable_exposed;
if any(fillMask(:))
    hdr_custom(:,:,1) = regionfill(hdr_custom(:,:,1), fillMask(:,:,1));
    if ~ismatrix(hdr_custom)
        hdr_custom(:,:,2) = regionfill(hdr_custom(:,:,2), fillMask(:,:,2));
        hdr_custom(:,:,3) = regionfill(hdr_custom(:,:,3), fillMask(:,:,3));
    end
end

rgb_custom = tonemap(hdr_custom, "AdjustSaturation",2,"NumberOfTiles",[2,2]);
rgb_custom_u8 = double(rgb_custom);
hdr_auto = makehdr(imageList2,'RelativeExposure',relative_times);
rgb_auto = tonemap(hdr_auto, "AdjustSaturation",2,"NumberOfTiles",[16,16]);
rgb_auto_u8 = double(rgb_auto);
hdr_auto_u8 = double(hdr_auto);

compareHdr1 = calculateMSE(hdr_custom,hdr_auto_u8)
compareHdr2_immse = immse(hdr_custom,hdr_auto_u8)
compareRgb1 = calculateMSE(rgb_custom,rgb_auto)
compareRgb2_immse = immse(rgb_custom_u8,rgb_auto_u8)
% montage(imageList);

t = tiledlayout(2,2);
t.TileSpacing = 'tight';
nexttile
imshow(hdr_custom)
title(['custom hdr obrazok bez tonemappingu MSE = ', num2str(compareHdr1)])
nexttile
imshow(rgb_custom)
title(['Tonemapped custom image MSE = ', num2str(compareRgb1)])
nexttile
imshow(hdr_auto)
title(['automaticky hdr bez tonemappingu MSE = ', num2str(compareHdr2_immse)])
nexttile
imshow(rgb_auto)
title(['Tonemapped auto image MSE = ', num2str(compareRgb2_immse)])
% nexttile
% imshow(single(position_over_exposed(:,:,1)))
% title('All over exposed')
% nexttile
% imshow(single(position_under_exposed(:,:,1)))
% title('All under exposed')
% nexttile
% imshow(single(position_reliable_exposed(:,:,1)))
% title('Reliable exposed pixels')

saveFolder = 'C:\Users\Martin\Documents\Vzdelanie\Inzinierske FEI\ZS2rocnik\DP\Matlab_vsetko\MatlabProjekt\Saved_Output';
tonemappedFilename_custom = fullfile(saveFolder, [pictureName '_HDR_custom_mean.png']);
imwrite(rgb_custom, tonemappedFilename_custom);

tonemappedFilename_auto = fullfile(saveFolder, [pictureName '_HDR_auto_mean.png']);
imwrite(rgb_auto, tonemappedFilename_auto);
