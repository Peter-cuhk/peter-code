function setup_coppelia_api()
    % SETUP_COPPELIA_API Setup script for CoppeliaSim Remote API
    %
    % This function helps set up the CoppeliaSim Remote API for MATLAB.
    % It provides instructions and attempts to locate the necessary files.
    
    fprintf('=== CoppeliaSim Remote API Setup for MATLAB ===\n\n');
    
    % Check if Remote API files are already in path
    if exist('remApi', 'file') == 2
        fprintf('✓ CoppeliaSim Remote API files found in MATLAB path.\n');
        testConnection();
        return;
    end
    
    fprintf('CoppeliaSim Remote API files not found in MATLAB path.\n\n');
    
    % Provide setup instructions
    fprintf('Setup Instructions:\n');
    fprintf('1. Download CoppeliaSim 4.7.0 from: https://coppeliarobotics.com/\n');
    fprintf('2. Navigate to your CoppeliaSim installation folder\n');
    fprintf('3. Find the Remote API files for MATLAB:\n');
    fprintf('   - Windows: CoppeliaSim_Edu_V4_7_0_Win/programming/remoteApiBindings/matlab/matlab/\n');
    fprintf('   - Linux: CoppeliaSim_Edu_V4_7_0_Ubuntu/programming/remoteApiBindings/matlab/matlab/\n');
    fprintf('   - macOS: CoppeliaSim_Edu_V4_7_0_macOS/programming/remoteApiBindings/matlab/matlab/\n');
    fprintf('4. Copy the following files to your MATLAB working directory:\n');
    fprintf('   - remApi.m\n');
    fprintf('   - remoteApiProto.m\n');
    fprintf('   - Library files (*.dll on Windows, *.so on Linux, *.dylib on macOS)\n\n');
    
    % Try to find CoppeliaSim installation automatically
    fprintf('Searching for CoppeliaSim installation...\n');
    
    possiblePaths = {
        'C:\Program Files\CoppeliaSim_Edu_V4_7_0_Win\programming\remoteApiBindings\matlab\matlab\'
        'C:\CoppeliaSim_Edu_V4_7_0_Win\programming\remoteApiBindings\matlab\matlab\'
        '/opt/CoppeliaSim_Edu_V4_7_0_Ubuntu/programming/remoteApiBindings/matlab/matlab/'
        '/usr/local/CoppeliaSim_Edu_V4_7_0_Ubuntu/programming/remoteApiBindings/matlab/matlab/'
        '/Applications/CoppeliaSim_Edu_V4_7_0_macOS/programming/remoteApiBindings/matlab/matlab/'
        '~/CoppeliaSim_Edu_V4_7_0_macOS/programming/remoteApiBindings/matlab/matlab/'
    };
    
    foundPath = '';
    for i = 1:length(possiblePaths)
        if exist(possiblePaths{i}, 'dir')
            if exist(fullfile(possiblePaths{i}, 'remApi.m'), 'file')
                foundPath = possiblePaths{i};
                break;
            end
        end
    end
    
    if ~isempty(foundPath)
        fprintf('✓ Found CoppeliaSim Remote API at: %s\n', foundPath);
        fprintf('Adding to MATLAB path...\n');
        addpath(foundPath);
        
        if exist('remApi', 'file') == 2
            fprintf('✓ Successfully added Remote API to MATLAB path.\n');
            
            % Save path for future sessions
            try
                savepath;
                fprintf('✓ Path saved for future MATLAB sessions.\n');
            catch
                fprintf('⚠ Could not save path. You may need to run this setup again in future sessions.\n');
            end
            
            testConnection();
        else
            fprintf('✗ Could not load Remote API. Please check the installation.\n');
        end
    else
        fprintf('✗ CoppeliaSim installation not found automatically.\n');
        fprintf('Please follow the manual setup instructions above.\n');
    end
    
    fprintf('\n=== Setup Complete ===\n');
end

function testConnection()
    % TEST_CONNECTION Test the CoppeliaSim connection
    
    fprintf('\nTesting CoppeliaSim connection...\n');
    
    try
        sim = remApi('remoteApi');
        sim.simxFinish(-1);
        
        fprintf('Attempting to connect to CoppeliaSim (make sure it is running)...\n');
        clientID = sim.simxStart('127.0.0.1', 19997, true, true, 5000, 5);
        
        if clientID > -1
            fprintf('✓ Successfully connected to CoppeliaSim!\n');
            fprintf('✓ Remote API is working correctly.\n');
            sim.simxFinish(clientID);
        else
            fprintf('✗ Could not connect to CoppeliaSim.\n');
            fprintf('Make sure:\n');
            fprintf('  - CoppeliaSim 4.7.0 is running\n');
            fprintf('  - Remote API server is enabled (should be by default)\n');
            fprintf('  - Port 19997 is not blocked by firewall\n');
        end
        
    catch ME
        fprintf('✗ Error testing connection: %s\n', ME.message);
        fprintf('The Remote API files may not be properly installed.\n');
    end
end