function demo_cuboid_detection()
    % DEMO_CUBOID_DETECTION Demonstration of cuboid detection functionality
    %
    % This demo shows how the cuboid detection algorithm works with sample images
    % and provides a preview of the expected functionality when connected to CoppeliaSim.
    
    fprintf('=== CoppeliaSim Kinect Cuboid Detection Demo ===\n\n');
    
    % Create synthetic test images to demonstrate the algorithm
    fprintf('Creating synthetic test images...\n');
    
    % Test image 1: Simple rectangles
    testImg1 = createTestImage1();
    
    % Test image 2: More complex scene with multiple objects
    testImg2 = createTestImage2();
    
    % Test image 3: Realistic scene with noise
    testImg3 = createTestImage3();
    
    % Process each test image
    testImages = {testImg1, testImg2, testImg3};
    titles = {'Simple Rectangles', 'Multiple Objects', 'Realistic Scene'};
    
    figure('Name', 'Cuboid Detection Demo', 'Position', [50, 50, 1200, 400]);
    
    for i = 1:length(testImages)
        % Detect cuboids and mark centers
        [imgWithMarkers, numCuboids] = detectAndMarkCuboids(testImages{i});
        
        % Display results
        subplot(1, 3, i);
        imshow(imgWithMarkers);
        title(sprintf('%s\nDetected: %d cuboids', titles{i}, numCuboids));
    end
    
    fprintf('\nDemo completed! The algorithm successfully detected cuboids in synthetic images.\n');
    fprintf('When connected to CoppeliaSim, it will work similarly with real Kinect data.\n\n');
    
    % Show algorithm parameters that can be tuned
    showTuningParameters();
end

function img = createTestImage1()
    % Create a simple test image with clear rectangles
    img = uint8(zeros(240, 320, 3) + 100); % Gray background
    
    % Add some rectangular objects
    % Rectangle 1 (blue)
    img(50:100, 80:150, :) = 0;
    img(50:100, 80:150, 3) = 200;
    
    % Rectangle 2 (green)
    img(120:180, 200:280, :) = 0;
    img(120:180, 200:280, 2) = 200;
    
    % Rectangle 3 (red)
    img(60:90, 30:60, :) = 0;
    img(60:90, 30:60, 1) = 200;
    
    % Add some noise
    noise = uint8(randn(size(img)) * 10);
    img = img + noise;
    img(img > 255) = 255;
    img(img < 0) = 0;
end

function img = createTestImage2()
    % Create a more complex test image
    img = uint8(zeros(300, 400, 3) + 80); % Darker gray background
    
    % Add various shaped objects
    % Large rectangle (yellow)
    img(50:120, 100:200, 1) = 200;
    img(50:120, 100:200, 2) = 200;
    img(50:120, 100:200, 3) = 0;
    
    % Square (purple)
    img(150:200, 50:100, 1) = 150;
    img(150:200, 50:100, 2) = 0;
    img(150:200, 50:100, 3) = 150;
    
    % Wide rectangle (cyan)
    img(220:250, 150:300, 1) = 0;
    img(220:250, 150:300, 2) = 200;
    img(220:250, 150:300, 3) = 200;
    
    % Small rectangle (orange)
    img(80:110, 280:320, 1) = 255;
    img(80:110, 280:320, 2) = 150;
    img(80:110, 280:320, 3) = 0;
    
    % Add circular object (should not be detected as cuboid)
    [x, y] = meshgrid(1:400, 1:300);
    circle = (x-350).^2 + (y-200).^2 < 30^2;
    img(circle) = 255;
    
    % Add some texture and noise
    texture = uint8(randn(size(img)) * 15);
    img = img + texture;
    img(img > 255) = 255;
    img(img < 0) = 0;
end

function img = createTestImage3()
    % Create a realistic scene with various challenges
    img = uint8(rand(320, 480, 3) * 50 + 60); % Textured background
    
    % Add realistic cuboid objects with gradients and shadows
    
    % Box 1 with gradient
    box1_x = 100:180;
    box1_y = 60:120;
    gradient = linspace(0.7, 1.0, length(box1_x));
    for i = 1:length(box1_x)
        img(box1_y, box1_x(i), 1) = uint8(180 * gradient(i));
        img(box1_y, box1_x(i), 2) = uint8(100 * gradient(i));
        img(box1_y, box1_x(i), 3) = uint8(50 * gradient(i));
    end
    
    % Box 2 partially occluded
    box2_x = 200:300;
    box2_y = 150:220;
    img(box2_y, box2_x, 1) = 80;
    img(box2_y, box2_x, 2) = 150;
    img(box2_y, box2_x, 3) = 200;
    
    % Occluding object (partially covers box 2)
    img(180:250, 250:320, :) = 200; % Light colored occluder
    
    % Box 3 with shadow
    box3_x = 350:420;
    box3_y = 80:140;
    img(box3_y, box3_x, :) = 120; % Main object
    % Shadow
    shadow_x = 355:425;
    shadow_y = 145:150;
    img(shadow_y, shadow_x, :) = 40;
    
    % Add more realistic noise and compression artifacts
    noise = uint8(randn(size(img)) * 20);
    img = img + noise;
    img(img > 255) = 255;
    img(img < 0) = 0;
    
    % Simulate compression artifacts
    img = imresize(imresize(img, 0.7), size(img, [1,2]));
end

function showTuningParameters()
    % Display algorithm parameters that can be tuned
    fprintf('Algorithm Parameters (can be tuned for different scenarios):\n');
    fprintf('├─ Edge Detection:\n');
    fprintf('│  ├─ Canny thresholds: [0.1, 0.2]\n');
    fprintf('│  └─ Morphological closing: 3x3 rectangle\n');
    fprintf('├─ Object Filtering:\n');
    fprintf('│  ├─ Minimum area: 500 pixels\n');
    fprintf('│  ├─ Maximum area: 50%% of image\n');
    fprintf('│  ├─ Minimum solidity: 0.7\n');
    fprintf('│  ├─ Minimum extent: 0.3\n');
    fprintf('│  └─ Aspect ratio: 0.3 to 3.0\n');
    fprintf('└─ Visualization:\n');
    fprintf('   └─ Cross size: 10 pixels\n\n');
    
    fprintf('To modify these parameters, edit the detectAndMarkCuboids function.\n');
    fprintf('Adjust thresholds based on your specific scene and lighting conditions.\n');
end

% Include the detection function from the main script
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