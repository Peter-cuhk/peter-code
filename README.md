# CoppeliaSim Kinect Cuboid Detection

MATLAB code for connecting to CoppeliaSim 4.7.0, capturing Kinect images, detecting cuboid objects, and marking their centers with red crosses.

## Features

- 🔗 Connect to CoppeliaSim 4.7.0 using Remote API
- 📷 Capture images from Kinect vision sensor
- 🔍 Real-time cuboid detection using computer vision
- ✨ Visual marking of detected cuboids with red crosses
- 🛠️ Configurable detection parameters
- 📊 Demo mode for testing without CoppeliaSim

## Requirements

### Software Requirements
- MATLAB R2018b or later
- MATLAB Computer Vision Toolbox
- CoppeliaSim 4.7.0 (Educational or Professional)

### Hardware Requirements
- Computer capable of running CoppeliaSim
- Network connection (for local API communication)

## Installation

### 1. Download CoppeliaSim 4.7.0
Download from: https://coppeliarobotics.com/

### 2. Setup Remote API
Run the setup script in MATLAB:
```matlab
setup_coppelia_api()
```

This will:
- Search for CoppeliaSim installation
- Add Remote API files to MATLAB path
- Test the connection

### 3. Manual Setup (if automatic setup fails)
1. Navigate to your CoppeliaSim installation folder
2. Find the Remote API MATLAB files:
   - Windows: `CoppeliaSim_Edu_V4_7_0_Win/programming/remoteApiBindings/matlab/matlab/`
   - Linux: `CoppeliaSim_Edu_V4_7_0_Ubuntu/programming/remoteApiBindings/matlab/matlab/`
   - macOS: `CoppeliaSim_Edu_V4_7_0_macOS/programming/remoteApiBindings/matlab/matlab/`
3. Copy these files to your MATLAB working directory:
   - `remApi.m`
   - `remoteApiProto.m`
   - Library files (`*.dll`, `*.so`, or `*.dylib`)

## Usage

### Quick Start

1. **Start CoppeliaSim 4.7.0**
   - Open CoppeliaSim
   - Load a scene with a Kinect sensor (vision sensor)
   - Ensure Remote API is enabled (port 19997)

2. **Run the detection system**
   ```matlab
   kinect_cuboid_detection()
   ```

3. **View results**
   - A window will open showing the Kinect feed
   - Detected cuboids will be marked with red crosses
   - Detection statistics will be displayed in the command window

### Demo Mode
Test the algorithm without CoppeliaSim:
```matlab
demo_cuboid_detection()
```

## Configuration

### Vision Sensor Setup in CoppeliaSim
Ensure your scene has a vision sensor named one of:
- `kinect_rgb`
- `Vision_sensor`
- `kinect`

### Detection Parameters
Edit `detectAndMarkCuboids()` function to adjust:

| Parameter | Default | Description |
|-----------|---------|-------------|
| `minArea` | 500 | Minimum object area (pixels) |
| `maxArea` | 50% of image | Maximum object area |
| `minSolidity` | 0.7 | Shape solidity threshold |
| `minExtent` | 0.3 | Bounding box fill ratio |
| `aspectRatio` | 0.3-3.0 | Width/height ratio range |
| `crossSize` | 10 | Red cross marker size |

### Edge Detection Settings
| Parameter | Default | Description |
|-----------|---------|-------------|
| Canny thresholds | [0.1, 0.2] | Edge detection sensitivity |
| Morphological SE | 3×3 rectangle | Edge cleanup |

## File Structure

```
peter-code/
├── kinect_cuboid_detection.m    # Main detection system
├── setup_coppelia_api.m         # Remote API setup
├── demo_cuboid_detection.m      # Demo without CoppeliaSim
└── README.md                    # This file
```

## API Reference

### Main Functions

#### `kinect_cuboid_detection()`
Main function that connects to CoppeliaSim and processes Kinect images.

#### `setup_coppelia_api()`
Setup helper for configuring the CoppeliaSim Remote API.

#### `demo_cuboid_detection()`
Demonstration of cuboid detection with synthetic images.

### Core Algorithm Functions

#### `processKinectImages(sim, clientID)`
Main processing loop for handling Kinect sensor data.

#### `detectAndMarkCuboids(img)`
Computer vision algorithm for detecting rectangular objects.
- **Input**: RGB or grayscale image
- **Output**: Image with red crosses, number of detected cuboids

#### `drawRedCross(img, centerX, centerY, crossSize)`
Draws red cross markers at specified coordinates.

## Troubleshooting

### Connection Issues
- ✅ Ensure CoppeliaSim 4.7.0 is running
- ✅ Check that Remote API is enabled (default port 19997)
- ✅ Verify firewall is not blocking port 19997
- ✅ Run `setup_coppelia_api()` to test connection

### Detection Issues
- 🔧 Adjust lighting in CoppeliaSim scene
- 🔧 Modify detection parameters for your objects
- 🔧 Ensure objects have clear edges and sufficient contrast
- 🔧 Check that vision sensor is properly positioned

### Performance Issues
- ⚡ Reduce image resolution in CoppeliaSim
- ⚡ Increase processing loop delay
- ⚡ Close other applications to free memory

## Technical Details

### Connection Method
Uses the specified CoppeliaSim Remote API connection:
```matlab
clientID = sim.simxStart('127.0.0.1', 19997, true, true, 5000, 5);
```

### Computer Vision Pipeline
1. **Image Acquisition**: Get RGB data from Kinect sensor
2. **Preprocessing**: Convert to grayscale, apply filters
3. **Edge Detection**: Canny edge detection with morphological cleanup
4. **Object Detection**: Connected component analysis
5. **Filtering**: Apply geometric constraints for cuboid shapes
6. **Visualization**: Draw red crosses at object centers

### Supported Object Types
The algorithm detects objects that are:
- Rectangular or square in shape
- Have solid, well-defined edges
- Meet minimum/maximum size criteria
- Have reasonable aspect ratios
- Sufficient contrast with background

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is open source. Please check the specific license terms.

## References

- [CoppeliaSim Manual](https://manual.coppeliarobotics.com/index.html)
- [CoppeliaSim Remote API](https://manual.coppeliarobotics.com/en/remoteApiOverview.html)
- [MATLAB Computer Vision Toolbox](https://www.mathworks.com/products/computer-vision.html)