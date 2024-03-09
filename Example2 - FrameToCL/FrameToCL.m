% This example shows how to obtain the shape of the contact-line from a grayscale image of the wetting interface.

%% Single frame
clc; clear all;

% The image imported shows the wetting interface as seen from top-view camera 
VR = VideoReader('BSiD_corrected.mp4');
frame = rgb2gray(read(VR, 500));

CLmask = WettingLibrary.GetFrameCLmask_Nanograss(frame, 0.33); % Calculate mask that segments the droplet contact area.

points = bwboundaries(CLmask);
points2 = unique(points{1}, 'rows', 'stable'); % Remove duplicates
CLpoints(:,2) = points2(:,1);
CLpoints(:,1) = points2(:,2);

%> save('CLpoints.mat', 'CLpoints') % Executed manually to avoid overriding data.

% Visualize results
figure(351);
clf;
imshow(frame);
hold on;
scatter(CLpoints(:,1), CLpoints(:,2), '.');
hold off;


%% Whole video
% The same principle can be used for a all the frames in a video.
clc; clear all;

% The image imported shows the wetting interface as seen from top-view camera 
VR = VideoReader('BSiD_corrected.mp4');

figure(351);
clf;
for iframe = 1:VR.NumFrames
    fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\bframe: %4d of %4d', iframe, VR.NumFrames);
    frame = rgb2gray(read(VR, iframe));

    CLmask = WettingLibrary.GetFrameCLmask_Nanograss(frame, 0.33); % Calculate mask that segments the droplet contact area.

    points = bwboundaries(CLmask);
    points2 = unique(points{1}, 'rows', 'stable'); % Remove duplicates
    CLpoints{iframe}(:,2) = points2(:,1);
    CLpoints{iframe}(:,1) = points2(:,2);
    
    imshow(frame);
    hold on;
    scatter(CLpoints{iframe}(:,1), CLpoints{iframe}(:,2), '.');
    hold off;
    drawnow;

end

%> save('CLpointsVideo.mat', 'CLpoints') % Executed manually to avoid overriding data.

% Visualize results






































