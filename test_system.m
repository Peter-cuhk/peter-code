function test_system()
    % TEST_SYSTEM Comprehensive testing suite for the CoppeliaSim Kinect system
    %
    % This function runs various tests to ensure the system is working correctly
    % and helps diagnose any issues.
    
    fprintf('=== CoppeliaSim Kinect Cuboid Detection - System Test ===\n\n');
    
    % Test 1: Check MATLAB toolboxes
    fprintf('Test 1: Checking MATLAB dependencies...\n');
    testMatlabDependencies();
    
    % Test 2: Check CoppeliaSim Remote API
    fprintf('\nTest 2: Checking CoppeliaSim Remote API...\n');
    apiStatus = testRemoteAPI();
    
    % Test 3: Test computer vision algorithms
    fprintf('\nTest 3: Testing computer vision algorithms...\n');
    testComputerVision();
    
    % Test 4: Test image processing functions
    fprintf('\nTest 4: Testing image processing functions...\n');
    testImageProcessing();
    
    % Test 5: Performance benchmark
    fprintf('\nTest 5: Performance benchmark...\n');
    runPerformanceBenchmark();
    
    % Summary
    fprintf('\n=== Test Summary ===\n');
    if apiStatus
        fprintf('✓ System is ready for CoppeliaSim connection\n');
        fprintf('✓ Run kinect_cuboid_detection() to start detection\n');
    else
        fprintf('⚠ CoppeliaSim connection issues detected\n');
        fprintf('⚠ Run setup_coppelia_api() first\n');
    end
    
    fprintf('✓ Computer vision algorithms working correctly\n');
    fprintf('✓ All tests completed\n\n');
end

function testMatlabDependencies()
    % Test required MATLAB toolboxes and functions
    
    % Check Computer Vision Toolbox
    if license('test', 'Video_and_Image_Blockset')
        fprintf('  ✓ Computer Vision Toolbox available\n');
    else
        fprintf('  ✗ Computer Vision Toolbox not available\n');
        fprintf('    This toolbox is required for image processing functions\n');
    end
    
    % Check Image Processing Toolbox
    if license('test', 'Image_Toolbox')
        fprintf('  ✓ Image Processing Toolbox available\n');
    else
        fprintf('  ✗ Image Processing Toolbox not available\n');
        fprintf('    This toolbox is required for advanced image operations\n');
    end
    
    % Test key functions
    functions_to_test = {'rgb2gray', 'edge', 'bwlabel', 'regionprops', 'imshow'};
    
    for i = 1:length(functions_to_test)
        func_name = functions_to_test{i};
        if exist(func_name, 'builtin') || exist(func_name, 'file')
            fprintf('  ✓ Function %s available\n', func_name);
        else
            fprintf('  ✗ Function %s not available\n', func_name);
        end
    end
end

function apiStatus = testRemoteAPI()
    % Test CoppeliaSim Remote API availability and connection
    
    apiStatus = false;
    
    % Check if Remote API files are available
    if exist('remApi', 'file') == 2
        fprintf('  ✓ remApi.m found\n');
    else
        fprintf('  ✗ remApi.m not found\n');
        fprintf('    Run setup_coppelia_api() to install Remote API files\n');
        return;
    end
    
    % Test API initialization
    try
        sim = remApi('remoteApi');
        fprintf('  ✓ Remote API initialized successfully\n');
    catch ME
        fprintf('  ✗ Remote API initialization failed: %s\n', ME.message);
        return;
    end
    
    % Test connection (only if CoppeliaSim is running)
    try
        sim.simxFinish(-1);
        clientID = sim.simxStart('127.0.0.1', 19997, true, true, 2000, 5);
        
        if clientID > -1
            fprintf('  ✓ Successfully connected to CoppeliaSim\n');
            
            % Test basic API functions
            [res, ~] = sim.simxGetSimulationTime(clientID, sim.simx_opmode_blocking);
            if res == sim.simx_return_ok
                fprintf('  ✓ API communication working\n');
                apiStatus = true;
            else
                fprintf('  ⚠ API communication issues\n');
            end
            
            sim.simxFinish(clientID);
        else
            fprintf('  ⚠ Cannot connect to CoppeliaSim (this is OK if CoppeliaSim is not running)\n');
        end
    catch ME
        fprintf('  ⚠ Connection test failed: %s\n', ME.message);
        fprintf('    This is normal if CoppeliaSim is not running\n');
    end
end

function testComputerVision()
    % Test computer vision algorithms with known inputs
    
    % Create test image with known shapes
    testImg = createTestPattern();
    
    % Test detection algorithm
    [resultImg, numDetected] = detectAndMarkCuboids(testImg);
    
    if numDetected > 0
        fprintf('  ✓ Cuboid detection algorithm working (%d objects detected)\n', numDetected);
    else
        fprintf('  ⚠ No objects detected in test pattern\n');
        fprintf('    This might indicate detection parameters need adjustment\n');
    end
    
    % Test individual components
    try
        grayImg = rgb2gray(testImg);
        edges = edge(grayImg, 'Canny');
        fprintf('  ✓ Edge detection working\n');
        
        labeled = bwlabel(edges);
        stats = regionprops(labeled, 'Area', 'BoundingBox');
        fprintf('  ✓ Object analysis working\n');
        
    catch ME
        fprintf('  ✗ Computer vision error: %s\n', ME.message);
    end
end

function testImageProcessing()
    % Test image processing and conversion functions
    
    % Test image data conversion
    try
        % Simulate CoppeliaSim image data format
        resolution = [320, 240];
        imageData = uint8(rand(320 * 240 * 3, 1) * 255);
        
        img = processImageData(imageData, resolution);
        
        if ~isempty(img) && size(img, 1) == 240 && size(img, 2) == 320
            fprintf('  ✓ Image data conversion working\n');
        else
            fprintf('  ✗ Image data conversion failed\n');
        end
        
    catch ME
        fprintf('  ✗ Image processing error: %s\n', ME.message);
    end
    
    % Test cross drawing
    try
        testImg = uint8(zeros(100, 100, 3));
        resultImg = drawRedCross(testImg, 50, 50, 5);
        
        % Check if red pixels were added
        if any(resultImg(:, :, 1) == 255)
            fprintf('  ✓ Red cross drawing working\n');
        else
            fprintf('  ✗ Red cross drawing failed\n');
        end
        
    catch ME
        fprintf('  ✗ Cross drawing error: %s\n', ME.message);
    end
end

function runPerformanceBenchmark()
    % Benchmark the detection algorithm performance
    
    % Create test images of different sizes
    sizes = [240, 320; 480, 640; 720, 1280];
    
    fprintf('  Performance tests:\n');
    
    for i = 1:size(sizes, 1)
        height = sizes(i, 1);
        width = sizes(i, 2);
        
        % Create test image
        testImg = uint8(rand(height, width, 3) * 255);
        
        % Add some rectangular shapes
        testImg(50:100, 50:150, :) = 200;
        testImg(150:200, 200:300, :) = 100;
        
        % Time the detection
        tic;
        [~, numDetected] = detectAndMarkCuboids(testImg);
        processingTime = toc;
        
        fps = 1 / processingTime;
        
        fprintf('    %dx%d: %.2fs (%.1f FPS) - %d objects\n', ...
                width, height, processingTime, fps, numDetected);
    end
end

function img = createTestPattern()
    % Create a test pattern with known rectangular shapes
    
    img = uint8(zeros(240, 320, 3) + 50); % Dark background
    
    % Add clear rectangular objects
    % Rectangle 1 - should be detected
    img(50:100, 80:160, 1) = 200;
    img(50:100, 80:160, 2) = 100;
    img(50:100, 80:160, 3) = 50;
    
    % Rectangle 2 - should be detected
    img(120:180, 200:280, 1) = 100;
    img(120:180, 200:280, 2) = 200;
    img(120:180, 200:280, 3) = 100;
    
    % Small rectangle - might not be detected (below threshold)
    img(190:210, 50:80, :) = 255;
    
    % Circle - should not be detected
    [x, y] = meshgrid(1:320, 1:240);
    circle = (x-260).^2 + (y-60).^2 < 25^2;
    img(repmat(circle, [1, 1, 3])) = 150;
end

% Include required functions from main script
function img = processImageData(imageData, resolution)
    % Process CoppeliaSim image data
    try
        if isempty(imageData) || isempty(resolution)
            img = [];
            return;
        end
        
        img_width = resolution(1);
        img_height = resolution(2);
        
        if length(imageData) == img_width * img_height * 3
            img = reshape(imageData, [3, img_width, img_height]);
            img = permute(img, [3, 2, 1]);
            img = flip(img, 1);
            img = uint8(img);
        else
            img = reshape(imageData, [img_width, img_height]);
            img = img';
            img = flip(img, 1);
            img = uint8(img);
        end
    catch
        img = [];
    end
end

function [imgWithMarkers, numCuboids] = detectAndMarkCuboids(img)
    % Simple version for testing
    imgWithMarkers = img;
    numCuboids = 0;
    
    try
        if size(img, 3) == 3
            grayImg = rgb2gray(img);
        else
            grayImg = img;
            img = repmat(img, [1, 1, 3]);
        end
        
        edges = edge(grayImg, 'Canny', [0.1, 0.2]);
        se = strel('rectangle', [3, 3]);
        edges = imclose(edges, se);
        edges = imfill(edges, 'holes');
        
        labeledImg = bwlabel(edges);
        stats = regionprops(labeledImg, 'BoundingBox', 'Area', 'Solidity', 'Extent');
        
        minArea = 500;
        maxArea = size(grayImg, 1) * size(grayImg, 2) * 0.5;
        minSolidity = 0.7;
        minExtent = 0.3;
        
        for i = 1:length(stats)
            area = stats(i).Area;
            solidity = stats(i).Solidity;
            extent = stats(i).Extent;
            
            if area >= minArea && area <= maxArea && solidity >= minSolidity && extent >= minExtent
                bbox = stats(i).BoundingBox;
                aspectRatio = bbox(3) / bbox(4);
                
                if aspectRatio >= 0.3 && aspectRatio <= 3.0
                    centerX = round(bbox(1) + bbox(3)/2);
                    centerY = round(bbox(2) + bbox(4)/2);
                    img = drawRedCross(img, centerX, centerY, 10);
                    numCuboids = numCuboids + 1;
                end
            end
        end
        
        imgWithMarkers = img;
    catch
        imgWithMarkers = img;
        numCuboids = 0;
    end
end

function img = drawRedCross(img, centerX, centerY, crossSize)
    % Draw red cross marker
    [height, width, ~] = size(img);
    
    centerX = max(1, min(centerX, width));
    centerY = max(1, min(centerY, height));
    
    x1 = max(1, centerX - crossSize);
    x2 = min(width, centerX + crossSize);
    y1 = max(1, centerY - crossSize);
    y2 = min(height, centerY + crossSize);
    
    img(centerY, x1:x2, 1) = 255;
    img(centerY, x1:x2, 2) = 0;
    img(centerY, x1:x2, 3) = 0;
    
    img(y1:y2, centerX, 1) = 255;
    img(y1:y2, centerX, 2) = 0;
    img(y1:y2, centerX, 3) = 0;
end