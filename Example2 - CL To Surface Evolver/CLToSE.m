% This example shows how the coordinate points of the contact line can be used to create a Surface Evolver simulation
% file that will find the shape of the droplet.
% This example makes use of CLpoints.mat, which is calculated in Example 1.

%% Generate Surface Evolver simulation script *.fe
clc; clear all;

load('CLpoints.mat'); % XY points that define the CL in image coordinates.

% Convert CL points from image space to real-world coordinates.
imageCenter = [744.61 697.18]; % Determined from image calibration.
imgCal = 0.746366*10^-6; % m/px - Image calibration for the microscope camera used to obtain
Npts = 500; % Number of points to render CL with.

CLpoints2 = (CLpoints - imageCenter) * imgCal;
CLpoints3 = CLpoints2(round(linspace(1, length(CLpoints2), Npts)),:); % Reduce number of points representing the CL to Npts

gm = 72e-3; % N/m - Surface tension of water.
rd = 511e-6; % m - Radius of the droplet holding disk.
V  = 0.47763e-9; % m^3 - Volume of the droplet. (0.5e-9 m^3 == 1.5 µL) Determined, e.g., from side-view machine vision.
h  = 622e-6; % m - Height of the droplet, i.e. distance from disk to the sample.

%> WettingLibrary.SEPrepDiskToSample('frame1000.fe', CLpoints3, 0, rd, h, V, V, gm) % Run this manually to create SE file.

% Visualize
figure(41);
clf;
scatter(CLpoints2(:,1)*10^6, CLpoints2(:,2)*10^6);
pbaspect([1 1 1]);
xline(0);
yline(0);

xlabel("X (µm)");
ylabel("Y (µm)");


%% Read and plot results
clc; clear all;

calcData = readmatrix('frame1000_Output.txt'); % Retrieve data from Surface Evolver calculation.

ca = calcData(:,8);
phi = linspace(0, 360, length(ca));

figure(41);
plot(phi, ca);
xlim([0 360]);
ylim([-inf 180]);
xlabel('Azimuthal angle (°)');
ylabel('Contact angle');


















