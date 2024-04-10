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

% Normalizoval som expoziciu na rozsah 0 - 255 kedze obrazok tento rozsah,
% toto som sa pomylil. rozsah ktory sa pouziva pri ohraniceni
% preexponovanych a podexponovanych pixeloch sa berie zo somotneho bitDepth
% obrazka ako 2/98 percent z max value!!!!!!!!!!!!!
% vo formate TIFF
%normalized_exposure = 255 * (exposure_values - exposure_values(1)) ./ (exposure_values(end) - exposure_values(1));
% normalized_exposure = exposure_values./(exposure_values(1));
% Nastavil som hranicnebodi pre a pod exponovanosti
% min_limit = 0.02 * normalized_exposure(end);  
% max_limit = 0.98 * normalized_exposure(end);

relative_times = exposure_values./mean(exposure_values);

normalized_intensity = zeros(size(imageList(1)));
count = zeros(size(imageList(1)));

%% Prechadza napriec vsetkymi LDR obrazkami
for i = 1:numel(imageList)
    ldr_image = imageList{i};
    info_ldr_image = imageList2{i};
  
    % Kazdy LDR obrazok ma svoju vlastnu prislusnu expoziciu
    %relative_exposure = exposure_values(i);
    

    % Ziska rozmery obrazka a tiez kolko ma vrstiev, dalej ziska bitdepth
    % aby vedel urcit rozsah v ktorom sa nachadza obrazok (unit
    [rows, cols, channels] = size(info_ldr_image);
    bitDepth = channels*str2double(regexp(class(info_ldr_image),'\d+','match'));
    bitsPerSample = bitDepth / channels;
    
    maxVal = 2^bitsPerSample-1;
    min_limit = round(0.02 * maxVal);
    max_limit = round((1-0.02) * maxVal);

    % triedi pixely podla hornej a dolnej hranice ne pre/pod expon.
    under_exposed = ldr_image < min_limit;
    over_exposed = ldr_image > max_limit;
  
    % Vytvori masku pixelov bez tych za min/max hranicou
    reliable_pixels = ~under_exposed;
    reliable_pixels = reliable_pixels & ~over_exposed;
  
    % pouzije masku na LDR obrazok
    adjusted_image = ldr_image .* reliable_pixels;
    % ldr_image(~reliable_pixels) = 0;
    % adjusted_image = ldr_image;
  
    % normalizuje intenzitu pomocou relativnej expozicie aby dostal obrazok
    % do rozsahu HDR pre kazdy vstupny obrazok podle jeho vlastneho
    % expozicneho casu
    normalized_intensity = normalized_intensity + adjusted_image ./ relative_times(i);

    % pocita kolko spolahlivych pixelov na mieste kazdeho pixelu napriec
    % obrackami vstupujucimi do for cyklu, neskorpouzite vahovane
    % premerovanie podla prispevkov do vysledneho HDR obrazka
    count = count + reliable_pixels;
end

% Pocita vahovany priemer normalizovanej intenzity pixelov
hdr_custom = normalized_intensity ./ (count);

%% Fungovalo mi to aj bez tejto casti, pridal som ju tam z makehdr, porovnam a nebol v tom rozdiel

% % pridava maximalnu hodnotu spomedzi spolahlivych pixelov vysledneho HDR
% % obrazka na miesta kde boli len pre-exponovane pixely
% maxValuePost = max(hdr_image(reliable_pixels));
% if ~isempty(maxValuePost)
%     hdr_image(over_exposed & ~under_exposed & ~reliable_pixels) = maxValuePost;
% end
% 
% % pridava minimalnu hodnotu spomedzi spolahlivych pixelov vysledneho HDR
% % obrazka na miesta kde boli len pod-exponovane pixely.
% % podmienka if je tam na to nech skusi ci vobec existuje taka hodnota ale to
% % by znamenalo ze obrazok su same nuly
% minValuePost = min(hdr_image(reliable_pixels));
% if ~isempty(minValuePost)
%     hdr_image(~over_exposed & under_exposed & ~reliable_pixels) = minValuePost;
% end
% 
% % Vyplni pixely ktore boli po cely cas len pre/pod-exponovane. skusa
% % podmienku ci nieco vyhovuje fillMask, ak ano spravi to pre privy kanal ,
% % ten by bol pre sedotonovy len jeden. Ak je to obrazok RGB skusa ci je to
% % matica a potom vyplni aj ostatne vrstvy G,B pomocou funkcie regionfill
% fillMask = under_exposed & over_exposed & ~reliable_pixels;
% if any(fillMask(:))
%     hdr_image(:,:,1) = regionfill(hdr_image(:,:,1), fillMask(:,:,1));
%     if ~ismatrix(hdr_image)
%         hdr_image(:,:,2) = regionfill(hdr_image(:,:,2), fillMask(:,:,2));
%         hdr_image(:,:,3) = regionfill(hdr_image(:,:,3), fillMask(:,:,3));
%     end
% end

rgb = tonemap(hdr_custom);
imshow(rgb)

hdr_auto = makehdr(imageList,'RelativeExposure',relative_times); %tu vstupuje relativna expozicia 

rgb_auto = tonemap(hdr);

% imshow(hdr_image)

% tiledlayout(2,3)
% nexttile
% imshow(rgb)
% title('Tonemapped hdr')
% nexttile
% imshow(hdr_image)
% title('hdr bez tonemappingu')
% nexttile
% imshow(adjusted_image)
% title('adjusted image')
% nexttile
% imshow(double(over_exposed))
% title('over exposed')
% nexttile
% imshow(double(reliable_pixels))
% title('reliable pixels')

saveFolder = 'C:\Users\Martin\Documents\Vzdelanie\Inzinierske FEI\ZS2rocnik\DP\Matlab_vsetko\MatlabProjekt\Saved_Output';
tonemappedFilename = fullfile(saveFolder, [pictureName '_custom_HDR_NormalizationDiff.png']);
imwrite(rgb, tonemappedFilename);

% montage(imageList);
% 
% % normalize exposure times relative to the first exposure time
% hdr = makehdr(imageList,'RelativeExposure',exposure_times./exposure_times(1));
% 
% rgb = tonemap(hdr);
% imshow(rgb)
