% This example shows how to obtain the shape of the contact-line from a grayscale image of the wetting interface.

clc; clear all;

% The image imported shows the wetting interface as seen from top-view camera 
frame = imread('BSiD_video1_frame1000.png');

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





