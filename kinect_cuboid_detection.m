function kinect_cuboid_detection()
    % KINECT_CUBOID_DETECTION Connect to CoppeliaSim and detect cuboids from Kinect
    % 
    % This function connects to CoppeliaSim 4.7.0, captures images from a Kinect
    % sensor, detects cuboid objects, and marks their centers with red crosses.
    %
    % Requirements:
    % - CoppeliaSim 4.7.0 running with Remote API enabled
    % - MATLAB Computer Vision Toolbox
    % - CoppeliaSim Remote API files for MATLAB
    
    % Clear workspace
    clear; clc; close all;
    
    % Add CoppeliaSim Remote API path (adjust path as needed)
    % You need to download and add the CoppeliaSim Remote API MATLAB files
    fprintf('Initializing CoppeliaSim connection...\n');
    
    try
        % Initialize remote API
        sim = remApi('remoteApi');
        sim.simxFinish(-1); % Close any previous connections
        
        % Connect to CoppeliaSim using the specified connection method
        clientID = sim.simxStart('127.0.0.1', 19997, true, true, 5000, 5);
        
        if clientID > -1
            fprintf('Connected to CoppeliaSim successfully!\n');
            
            % Main processing loop
            processKinectImages(sim, clientID);
            
            % Disconnect
            sim.simxFinish(clientID);
            fprintf('Disconnected from CoppeliaSim.\n');
        else
            error('Failed to connect to CoppeliaSim. Make sure CoppeliaSim is running with Remote API enabled.');
        end
        
    catch ME
        fprintf('Error: %s\n', ME.message);
        fprintf('Make sure:\n');
        fprintf('1. CoppeliaSim 4.7.0 is running\n');
        fprintf('2. Remote API is enabled (port 19997)\n');
        fprintf('3. CoppeliaSim Remote API MATLAB files are in the path\n');
    end
end

function processKinectImages(sim, clientID)
    % PROCESSKIECTIMAGES Main loop for processing Kinect images
    
    % Get Kinect vision sensor handle
    [res, kinectHandle] = sim.simxGetObjectHandle(clientID, 'kinect_rgb', sim.simx_opmode_blocking);
    if res ~= sim.simx_return_ok
        % Try alternative names for Kinect sensor
        [res, kinectHandle] = sim.simxGetObjectHandle(clientID, 'Vision_sensor', sim.simx_opmode_blocking);
        if res ~= sim.simx_return_ok
            [res, kinectHandle] = sim.simxGetObjectHandle(clientID, 'kinect', sim.simx_opmode_blocking);
            if res ~= sim.simx_return_ok
                error('Could not find Kinect sensor. Please ensure a vision sensor named "kinect_rgb", "Vision_sensor", or "kinect" exists in the scene.');
            end
        end
    end
    
    fprintf('Found Kinect sensor, starting image processing...\n');
    fprintf('Press Ctrl+C to stop.\n');
    
    % Create figure for display
    fig = figure('Name', 'Kinect Cuboid Detection', 'Position', [100, 100, 800, 600]);
    
    % Initialize image capture
    [res, resolution, image] = sim.simxGetVisionSensorImage(clientID, kinectHandle, 0, sim.simx_opmode_streaming);
    
    frameCount = 0;
    while ishandle(fig)
        % Get image from Kinect sensor
        [res, resolution, image] = sim.simxGetVisionSensorImage(clientID, kinectHandle, 0, sim.simx_opmode_buffer);
        
        if res == sim.simx_return_ok && ~isempty(image)
            frameCount = frameCount + 1;
            
            % Convert image data to MATLAB format
            img = processImageData(image, resolution);
            
            if ~isempty(img)
                % Detect cuboids and mark centers
                [imgWithMarkers, numCuboids] = detectAndMarkCuboids(img);
                
                % Display result
                figure(fig);
                imshow(imgWithMarkers);
                title(sprintf('Frame %d - Detected %d cuboids', frameCount, numCuboids));
                drawnow;
            end
        end
        
        % Small pause to prevent overwhelming the connection
        pause(0.1);
    end
end

function img = processImageData(imageData, resolution)
    % PROCESSIMAGEDATA Convert CoppeliaSim image data to MATLAB format
    
    try
        if isempty(imageData) || isempty(resolution)
            img = [];
            return;
        end
        
        % CoppeliaSim returns image as uint8 array
        img_width = resolution(1);
        img_height = resolution(2);
        
        % Reshape and convert image data
        if length(imageData) == img_width * img_height * 3
            % RGB image
            img = reshape(imageData, [3, img_width, img_height]);
            img = permute(img, [3, 2, 1]); % Reorder dimensions
            img = flip(img, 1); % Flip vertically (CoppeliaSim coordinate system)
            img = uint8(img);
        else
            % Grayscale image
            img = reshape(imageData, [img_width, img_height]);
            img = img'; % Transpose
            img = flip(img, 1); % Flip vertically
            img = uint8(img);
        end
        
    catch ME
        fprintf('Warning: Error processing image data: %s\n', ME.message);
        img = [];
    end
end

function [imgWithMarkers, numCuboids] = detectAndMarkCuboids(img)
    % DETECTANDMARKCUBOIDS Detect cuboids and mark their centers with red crosses
    
    imgWithMarkers = img;
    numCuboids = 0;
    
    try
        % Convert to grayscale if needed
        if size(img, 3) == 3
            grayImg = rgb2gray(img);
        else
            grayImg = img;
            img = repmat(img, [1, 1, 3]); % Convert to RGB for marking
        end
        
        % Apply edge detection
        edges = edge(grayImg, 'Canny', [0.1, 0.2]);
        
        % Morphological operations to clean up edges
        se = strel('rectangle', [3, 3]);
        edges = imclose(edges, se);
        edges = imfill(edges, 'holes');
        
        % Find connected components
        labeledImg = bwlabel(edges);
        stats = regionprops(labeledImg, 'BoundingBox', 'Area', 'Solidity', 'Extent');
        
        % Filter for cuboid-like objects
        minArea = 500; % Minimum area threshold
        maxArea = size(grayImg, 1) * size(grayImg, 2) * 0.5; % Maximum area (50% of image)
        minSolidity = 0.7; % How "solid" the shape is
        minExtent = 0.3; % How much of the bounding box is filled
        
        for i = 1:length(stats)
            area = stats(i).Area;
            solidity = stats(i).Solidity;
            extent = stats(i).Extent;
            
            % Check if object meets cuboid criteria
            if area >= minArea && area <= maxArea && solidity >= minSolidity && extent >= minExtent
                bbox = stats(i).BoundingBox;
                
                % Calculate aspect ratio
                aspectRatio = bbox(3) / bbox(4);
                
                % Accept reasonable aspect ratios (not too thin or too wide)
                if aspectRatio >= 0.3 && aspectRatio <= 3.0
                    % Calculate center point
                    centerX = round(bbox(1) + bbox(3)/2);
                    centerY = round(bbox(2) + bbox(4)/2);
                    
                    % Draw red cross at center
                    img = drawRedCross(img, centerX, centerY, 10);
                    numCuboids = numCuboids + 1;
                    
                    fprintf('Detected cuboid %d at center: (%d, %d)\n', numCuboids, centerX, centerY);
                end
            end
        end
        
        imgWithMarkers = img;
        
    catch ME
        fprintf('Warning: Error in cuboid detection: %s\n', ME.message);
        imgWithMarkers = img;
        numCuboids = 0;
    end
end

function img = drawRedCross(img, centerX, centerY, crossSize)
    % DRAWREDCROSS Draw a red cross at the specified center point
    
    [height, width, ~] = size(img);
    
    % Ensure coordinates are within image bounds
    centerX = max(1, min(centerX, width));
    centerY = max(1, min(centerY, height));
    
    % Define cross boundaries
    x1 = max(1, centerX - crossSize);
    x2 = min(width, centerX + crossSize);
    y1 = max(1, centerY - crossSize);
    y2 = min(height, centerY + crossSize);
    
    % Draw horizontal line (red)
    img(centerY, x1:x2, 1) = 255; % Red channel
    img(centerY, x1:x2, 2) = 0;   % Green channel
    img(centerY, x1:x2, 3) = 0;   % Blue channel
    
    % Draw vertical line (red)
    img(y1:y2, centerX, 1) = 255; % Red channel
    img(y1:y2, centerX, 2) = 0;   % Green channel
    img(y1:y2, centerX, 3) = 0;   % Blue channel
end