clc; clear all; close all;
imaqreset;

colorImg_save_path = 'live_demo_data\colorImg_live.mat';
metadata_save_path = 'live_demo_data\metadata_live.mat';
joints_positions_save_path = 'live_demo_data\live_data.txt';

colorVid = videoinput('kinect', 1)
depthVid = videoinput('kinect', 2)

depthSource = getselectedsource(depthVid);
depthSource.EnableBodyTracking = 'on';

% Acquire 100 color and depth frames.
framesPerTrig = 200;
colorVid.FramesPerTrigger = framesPerTrig;
depthVid.FramesPerTrigger = framesPerTrig;

% Start the depth and color acquisition objects.
% This begins acquisition, but does not start logging of acquired data.
%pause(5);
preview(colorVid);
start([depthVid colorVid]);

%set(depthVid,'Timeout',50);
% Get images and metadata from the color and depth device objects.
[colorImg] = getdata(colorVid);
[~, ~, metadata] = getdata(depthVid);
save(metadata_save_path, 'metadata');
closepreview(colorVid);
save(colorImg_save_path, 'colorImg');
% Extract the 90th frame and tracked body information.
lastFrame = framesPerTrig-10;
lastframeMetadata = metadata(lastFrame);

 % Find the indexes of the tracked bodies.
 anyBodiesTracked = any(lastframeMetadata.IsBodyTracked ~= 0);
 trackedBodies = find(lastframeMetadata.IsBodyTracked);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%-----------------------------------------%%%%%%%%
%%%%% Getting the data to use in python for prediction %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%-----------------------------------------%%%%%%%% 

data = metadata; %making copy of data     
m = 1; %iterates when a body is tracked in the frame
clear data_joints_values %clearing the variable 
for n = 1:framesPerTrig %loop runs for number of frames (e.g, 200)
    currentframeMetadata = data(n);
    %we first check if anybody is tracked
    currentframeanyBodiesTracked = any(currentframeMetadata.IsBodyTracked ~= 0);
    %currenttrackedBodies = find(currentframeMetadata.IsBodyTracked);
    if currentframeanyBodiesTracked == 1 %if frame is not empty
        data_joints = data(n).JointPositions; %we get data for each frame
        i = 1; k = 2; l = 3; %iteration for x,y,z positions for first person repectively
        ii = 76; kk = 77; ll = 78; %iteration for x,y,z positions for second person repectively
        for j = 1:25
            %saving data for first person
            data_joints_values(m,i) = data_joints(j,1,trackedBodies(1));
            data_joints_values(m,k) = data_joints(j,2,trackedBodies(1));
            data_joints_values(m,l) = data_joints(j,3,trackedBodies(1));
            
            %saving data for second person
            data_joints_values(m,ii) = data_joints(j,1,trackedBodies(2));
            data_joints_values(m,kk) = data_joints(j,2,trackedBodies(2));
            data_joints_values(m,ll) = data_joints(j,3,trackedBodies(2));
            i = i+3; k = k+3; l = l+3;
            ii = ii + 3; kk = kk + 3; ll  = ll + 3;
        end
            m = m+1;
     end

end

data_save = data_joints_values; %variable to save data
dlmwrite(joints_positions_save_path,data_save, ' ')%saving data in file
