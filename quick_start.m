%% Quick Start Guide for CoppeliaSim Kinect Cuboid Detection
% This script shows the basic steps to use the cuboid detection system

%% Step 1: Setup (Run once)
% Make sure CoppeliaSim Remote API files are installed
setup_coppelia_api();

%% Step 2: Test without CoppeliaSim (Optional)
% Run the demo to see how the algorithm works
demo_cuboid_detection();

%% Step 3: Test system health (Optional)
% Check if everything is working correctly
test_system();

%% Step 4: Start CoppeliaSim
% 1. Open CoppeliaSim 4.7.0
% 2. Load a scene with objects (or create one following CoppeliaSim_Scene_Setup.md)
% 3. Make sure you have a vision sensor named "kinect_rgb", "Vision_sensor", or "kinect"
% 4. Start the simulation (play button)

%% Step 5: Run the main detection system
% This will connect to CoppeliaSim and start detecting cuboids
kinect_cuboid_detection();

%% Alternative: Manual connection test
% If you want to test the connection manually:
try
    sim = remApi('remoteApi');
    sim.simxFinish(-1);
    clientID = sim.simxStart('127.0.0.1', 19997, true, true, 5000, 5);
    
    if clientID > -1
        fprintf('✓ Connected to CoppeliaSim successfully!\n');
        
        % Get simulation time to test communication
        [res, simTime] = sim.simxGetSimulationTime(clientID, sim.simx_opmode_blocking);
        if res == sim.simx_return_ok
            fprintf('✓ Simulation time: %.2f seconds\n', simTime);
        end
        
        % Try to find vision sensors
        fprintf('Available vision sensors:\n');
        sensorNames = {'kinect_rgb', 'Vision_sensor', 'kinect'};
        for i = 1:length(sensorNames)
            [res, handle] = sim.simxGetObjectHandle(clientID, sensorNames{i}, sim.simx_opmode_blocking);
            if res == sim.simx_return_ok
                fprintf('  ✓ Found: %s (handle: %d)\n', sensorNames{i}, handle);
            else
                fprintf('  - Not found: %s\n', sensorNames{i});
            end
        end
        
        sim.simxFinish(clientID);
    else
        fprintf('✗ Could not connect to CoppeliaSim\n');
        fprintf('Make sure CoppeliaSim is running and Remote API is enabled\n');
    end
catch ME
    fprintf('Error: %s\n', ME.message);
end

%% Troubleshooting Tips
fprintf('\n=== Troubleshooting Tips ===\n');
fprintf('If you encounter issues:\n');
fprintf('1. Make sure CoppeliaSim 4.7.0 is running\n');
fprintf('2. Check that Remote API server is enabled (Tools → Remote API server)\n');
fprintf('3. Verify the scene has a vision sensor\n');
fprintf('4. Run setup_coppelia_api() to check Remote API installation\n');
fprintf('5. Run test_system() to diagnose problems\n');
fprintf('6. Check firewall settings for port 19997\n\n');

%% Algorithm Parameters
fprintf('=== Detection Parameters ===\n');
fprintf('You can modify these in detectAndMarkCuboids():\n');
fprintf('- minArea: Minimum object size (default: 500 pixels)\n');
fprintf('- maxArea: Maximum object size (default: 50%% of image)\n');
fprintf('- minSolidity: Shape solidity (default: 0.7)\n');
fprintf('- minExtent: Bounding box fill ratio (default: 0.3)\n');
fprintf('- aspectRatio: Width/height ratio range (default: 0.3-3.0)\n');
fprintf('- Edge detection: Canny thresholds [0.1, 0.2]\n\n');

fprintf('=== Quick Start Complete ===\n');
fprintf('Run kinect_cuboid_detection() when CoppeliaSim is ready!\n');