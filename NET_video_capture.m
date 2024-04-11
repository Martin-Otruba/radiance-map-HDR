%Spojenie XIMEA Matlab

% info


% Access an image acquisition device
%vidobj = videoinput('gentl', 1, 'BGRA8Packed');
vidobj = videoinput('gentl', 1, 'BayerBG8');
src=getselectedsource(vidobj);
%src.AEAGEnable = 'True';
% List the video input object's configurable properties.vidobj.FramesPerTrigger = 50;
% Open the preview window
preview(vidobj);
% Data acquisition
start(vidobj);
%wait(vidobj);
stop(vidobj);

%  Cleanup the image acquisition object and the MATLAB® workspace delete(vidobj);
clear vidobj;