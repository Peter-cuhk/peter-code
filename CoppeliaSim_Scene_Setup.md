# CoppeliaSim Scene Setup Instructions

This file provides instructions for setting up a CoppeliaSim scene with a Kinect sensor for cuboid detection.

## Quick Scene Setup

### Method 1: Use Default Scene
1. Open CoppeliaSim 4.7.0
2. File → Open scene → Choose any scene with objects
3. Add a vision sensor (Kinect) by:
   - Right-click in scene hierarchy
   - Add → Vision sensor
   - Rename to "kinect_rgb" or "Vision_sensor"

### Method 2: Create Custom Scene
1. Open CoppeliaSim
2. Create a new scene (File → New scene)
3. Add objects to detect:
   - Add → Primitive shape → Cuboid
   - Create multiple cuboids of different sizes
   - Position them in the scene

4. Add a Kinect/Vision sensor:
   - Add → Vision sensor
   - Rename to "kinect_rgb"
   - Position above the objects
   - Angle downward to view the objects

5. Configure the vision sensor:
   - Right-click vision sensor → Edit → Vision sensor properties
   - Set resolution (e.g., 640x480 or 320x240)
   - Adjust near/far clipping planes
   - Set appropriate field of view

## Recommended Scene Layout

```
Scene Hierarchy:
├── World
├── kinect_rgb (Vision sensor)
├── Cuboid1 (Primitive shape)
├── Cuboid2 (Primitive shape)
├── Cuboid3 (Primitive shape)
└── Floor (Primitive shape - optional)
```

## Vision Sensor Configuration

### Position
- Height: 1-3 meters above objects
- Angle: 30-60 degrees downward
- Distance: Ensure all objects are in view

### Properties
- Resolution: 320x240 (for performance) or 640x480 (for quality)
- Near clipping: 0.1m
- Far clipping: 10m
- View angle: 60-90 degrees
- Render mode: OpenGL3

### Naming Convention
Ensure the vision sensor is named one of:
- `kinect_rgb` (preferred)
- `Vision_sensor`
- `kinect`

## Object Setup for Detection

### Good Objects for Detection
- Boxes/cuboids with clear edges
- Objects with good contrast to background
- Well-lit objects
- Objects larger than 500 pixels in the image

### Objects to Avoid
- Very small objects (< 500 pixels)
- Objects with poor contrast
- Highly reflective objects
- Objects with rounded edges

## Lighting Setup
- Add adequate lighting to the scene
- Avoid harsh shadows that obscure edges
- Use diffuse lighting for best results
- Consider adding multiple light sources

## Testing Your Scene
1. Start simulation (Play button)
2. Double-click vision sensor to view its feed
3. Verify objects are clearly visible
4. Adjust sensor position/properties if needed
5. Run the MATLAB detection script

## Example Script for Scene Creation

Save this as a CoppeliaSim script if you want to automate scene creation:

```lua
-- CoppeliaSim scene creation script
function createDetectionScene()
    -- Clear existing scene
    sim.clearScene()
    
    -- Add floor
    local floor = sim.createPrimitiveShape(sim.primitiveshape_cuboid, {10, 10, 0.1})
    sim.setObjectPosition(floor, -1, {0, 0, -0.05})
    sim.setObjectName(floor, "Floor")
    
    -- Add cuboids for detection
    local cuboid1 = sim.createPrimitiveShape(sim.primitiveshape_cuboid, {1, 0.5, 0.3})
    sim.setObjectPosition(cuboid1, -1, {0, 0, 0.15})
    sim.setObjectName(cuboid1, "Cuboid1")
    
    local cuboid2 = sim.createPrimitiveShape(sim.primitiveshape_cuboid, {0.8, 0.8, 0.4})
    sim.setObjectPosition(cuboid2, -1, {2, 1, 0.2})
    sim.setObjectName(cuboid2, "Cuboid2")
    
    local cuboid3 = sim.createPrimitiveShape(sim.primitiveshape_cuboid, {1.2, 0.6, 0.2})
    sim.setObjectPosition(cuboid3, -1, {-1.5, -1, 0.1})
    sim.setObjectName(cuboid3, "Cuboid3")
    
    -- Add vision sensor (Kinect)
    local visionSensor = sim.createVisionSensor()
    sim.setObjectPosition(visionSensor, -1, {0, -3, 2})
    sim.setObjectOrientation(visionSensor, -1, {math.rad(30), 0, 0})
    sim.setObjectName(visionSensor, "kinect_rgb")
    
    -- Configure vision sensor
    sim.setVisionSensorResolution(visionSensor, {640, 480})
    
    -- Add lighting
    local light = sim.createLight(sim.light_omnidirectional)
    sim.setObjectPosition(light, -1, {0, 0, 3})
    sim.setLightParameters(light, 1, {1, 1, 1}, {1, 1, 1}, {0, 0, 0})
    
    print("Detection scene created successfully!")
end

-- Call the function to create the scene
createDetectionScene()
```

## Remote API Setup
Make sure Remote API is enabled:
1. Go to Tools → Remote API server
2. Ensure it's running on port 19997
3. Check "Continuous service" if needed

The default configuration should work with the MATLAB scripts provided.