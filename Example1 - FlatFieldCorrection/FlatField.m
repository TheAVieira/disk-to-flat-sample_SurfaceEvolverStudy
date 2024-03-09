% This examples showcases how the frames from a video can be corrected with a flat-field image.
% If the image quality of your video is already good and the contact line is clearly visible then this step can be
% skipped.
%
% What is Flat-field correction? Optical systems always have imperfections. These could be dust particles on lens
% surfaces or over the CCD itself that prevent light from reaching the surface. This hinders the ability of the optical
% system to reproduce an accurate image of the object.
% However, in some cases it is possible correct the images acquired, e.g. by brightnening the areas there are too dark.
% To do this we first aim the camera at an uniformly lit surface that should show an uniform image. This image is then
% operated with images of an actual measurement to remove such imperfections.

% In this example the images acquired in video 2023-05-22_10-52-38_camTopBW_Apr21-BSi-D-L1.mp4 are obtained by imaging
% through a 1 mm diameter SU-8 disk. This disk holds a 0.5µL droplet which is pressed and dragged along a 
% superhydrophobic surface. The disk has imperfections associated its manufacturing that cast shadows onto the wetting
% interface.

% The FlatField_100umPress.mat contains an image which was obtained by imaging a piece of flat silicon under the same
% conditions as in the experiment. The distance between the sample and the droplet is also the same as during the
% experiment of video 2023-05-22_10-52-38_camTopBW_Apr21-BSi-D-L1.mp4.

%% On a single frame
clc; clear all;

iframe = 727;
VR = VideoReader('2023-05-22_10-52-38_camTopBW_Apr21-BSi-D-L1.mp4');
load('FlatField_100umPress.mat');

FF = WettingLibrary.PrepFlatField(F, 0.4); % Segments mask to region of interest within the disk.

figure(41);
frame = VR.read(iframe);
frameC = WettingLibrary.ApplyFlatFied(frame, FF, [-24 -24], [1 120]);
imshow(frameC);


%% Create a flat-field corrected video
% Creates a raw *.avi video with flat-field corrected images.
% The video can then be compressed with ffmpeg, by running AviToMp4.bat. ffmpeg produces better compression while
% preserving quality, better than configuring Matlab's VideoWriter to compress.

clc; clear all;


VR = VideoReader('2023-05-22_10-52-38_camTopBW_Apr21-BSi-D-L1.mp4');
load('FlatField_100umPress.mat');

FF = WettingLibrary.PrepFlatField(F, 0.4); % Segments mask to region of interest within the disk.
frange = 727:1580; % Region of interest. While dragging and wetting interface shape has stabilized.

VW = VideoWriter('BSiD_corrected.avi','Uncompressed AVI');

open(VW);
for iframe = frange
    fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\bframe: %4d of %4d', iframe-frange(1), range(frange));
    frame = VR.read(iframe);
    frameC = WettingLibrary.ApplyFlatFied(frame, FF, [-24 -24], [1 120]);
    writeVideo(VW, frameC);
end

close(VW);







