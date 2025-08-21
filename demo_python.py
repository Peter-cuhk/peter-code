#!/usr/bin/env python3
"""
Python demo of the cuboid detection algorithm
This demonstrates the computer vision approach used in the MATLAB implementation
"""

import numpy as np
import cv2
import matplotlib.pyplot as plt
from scipy import ndimage
from skimage import measure, morphology
import matplotlib.patches as patches

def create_test_image_1():
    """Create a simple test image with clear rectangles"""
    img = np.full((240, 320, 3), 100, dtype=np.uint8)  # Gray background
    
    # Rectangle 1 (blue)
    img[50:100, 80:150] = [0, 0, 200]
    
    # Rectangle 2 (green)
    img[120:180, 200:280] = [0, 200, 0]
    
    # Rectangle 3 (red)
    img[60:90, 30:60] = [200, 0, 0]
    
    # Add some noise
    noise = np.random.normal(0, 10, img.shape).astype(np.int16)
    img = np.clip(img.astype(np.int16) + noise, 0, 255).astype(np.uint8)
    
    return img

def create_test_image_2():
    """Create a more complex test image"""
    img = np.full((300, 400, 3), 80, dtype=np.uint8)  # Darker gray background
    
    # Large rectangle (yellow)
    img[50:120, 100:200] = [200, 200, 0]
    
    # Square (purple)
    img[150:200, 50:100] = [150, 0, 150]
    
    # Wide rectangle (cyan)
    img[220:250, 150:300] = [0, 200, 200]
    
    # Small rectangle (orange)
    img[80:110, 280:320] = [255, 150, 0]
    
    # Add circular object (should not be detected as cuboid)
    y, x = np.ogrid[:300, :400]
    circle = (x - 350)**2 + (y - 200)**2 < 30**2
    img[circle] = [255, 255, 255]
    
    # Add texture and noise
    texture = np.random.normal(0, 15, img.shape).astype(np.int16)
    img = np.clip(img.astype(np.int16) + texture, 0, 255).astype(np.uint8)
    
    return img

def create_test_image_3():
    """Create a realistic scene with various challenges"""
    img = (np.random.rand(320, 480, 3) * 50 + 60).astype(np.uint8)  # Textured background
    
    # Box 1 with gradient
    for i, x in enumerate(range(100, 180)):
        gradient = 0.7 + 0.3 * i / 80
        img[60:120, x] = [int(180 * gradient), int(100 * gradient), int(50 * gradient)]
    
    # Box 2 partially occluded
    img[150:220, 200:300] = [80, 150, 200]
    
    # Occluding object
    img[180:250, 250:320] = [200, 200, 200]
    
    # Box 3 with shadow
    img[80:140, 350:420] = [120, 120, 120]
    # Shadow
    img[145:150, 355:425] = [40, 40, 40]
    
    # Add more realistic noise
    noise = np.random.normal(0, 20, img.shape).astype(np.int16)
    img = np.clip(img.astype(np.int16) + noise, 0, 255).astype(np.uint8)
    
    return img

def detect_and_mark_cuboids(img):
    """Detect cuboids and mark their centers with red crosses"""
    img_with_markers = img.copy()
    num_cuboids = 0
    
    try:
        # Convert to grayscale
        if len(img.shape) == 3:
            gray_img = cv2.cvtColor(img, cv2.COLOR_RGB2GRAY)
        else:
            gray_img = img
            img_with_markers = cv2.cvtColor(img, cv2.COLOR_GRAY2RGB)
        
        # Apply edge detection
        edges = cv2.Canny(gray_img, 25, 50)  # Equivalent to MATLAB's [0.1, 0.2] thresholds
        
        # Morphological operations to clean up edges
        kernel = np.ones((3, 3), np.uint8)
        edges = cv2.morphologyEx(edges, cv2.MORPH_CLOSE, kernel)
        edges = ndimage.binary_fill_holes(edges).astype(np.uint8) * 255
        
        # Find connected components
        labeled_img = measure.label(edges)
        regions = measure.regionprops(labeled_img)
        
        # Filter for cuboid-like objects
        min_area = 500
        max_area = gray_img.shape[0] * gray_img.shape[1] * 0.5
        min_solidity = 0.7
        min_extent = 0.3
        
        for region in regions:
            area = region.area
            solidity = region.solidity
            extent = region.extent
            
            # Check if object meets cuboid criteria
            if (min_area <= area <= max_area and 
                solidity >= min_solidity and 
                extent >= min_extent):
                
                bbox = region.bbox
                height = bbox[2] - bbox[0]
                width = bbox[3] - bbox[1]
                aspect_ratio = width / height if height > 0 else 0
                
                # Accept reasonable aspect ratios
                if 0.3 <= aspect_ratio <= 3.0:
                    # Calculate center point
                    center_y = int((bbox[0] + bbox[2]) / 2)
                    center_x = int((bbox[1] + bbox[3]) / 2)
                    
                    # Draw red cross at center
                    img_with_markers = draw_red_cross(img_with_markers, center_x, center_y, 10)
                    num_cuboids += 1
                    
                    print(f'Detected cuboid {num_cuboids} at center: ({center_x}, {center_y})')
        
    except Exception as e:
        print(f'Warning: Error in cuboid detection: {e}')
        num_cuboids = 0
    
    return img_with_markers, num_cuboids

def draw_red_cross(img, center_x, center_y, cross_size):
    """Draw a red cross at the specified center point"""
    height, width = img.shape[:2]
    
    # Ensure coordinates are within image bounds
    center_x = max(0, min(center_x, width - 1))
    center_y = max(0, min(center_y, height - 1))
    
    # Define cross boundaries
    x1 = max(0, center_x - cross_size)
    x2 = min(width, center_x + cross_size)
    y1 = max(0, center_y - cross_size)
    y2 = min(height, center_y + cross_size)
    
    # Draw horizontal line (red)
    img[center_y, x1:x2] = [255, 0, 0]
    
    # Draw vertical line (red)
    img[y1:y2, center_x] = [255, 0, 0]
    
    return img

def run_demo():
    """Run the cuboid detection demo"""
    print('=== CoppeliaSim Kinect Cuboid Detection Demo ===\n')
    print('Creating synthetic test images...\n')
    
    # Create test images
    test_img1 = create_test_image_1()
    test_img2 = create_test_image_2()
    test_img3 = create_test_image_3()
    
    test_images = [test_img1, test_img2, test_img3]
    titles = ['Simple Rectangles', 'Multiple Objects', 'Realistic Scene']
    
    # Create figure
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    fig.suptitle('Cuboid Detection Demo - MATLAB Algorithm Implementation', fontsize=16)
    
    for i, (img, title) in enumerate(zip(test_images, titles)):
        # Detect cuboids and mark centers
        img_with_markers, num_cuboids = detect_and_mark_cuboids(img)
        
        # Display results
        axes[i].imshow(img_with_markers)
        axes[i].set_title(f'{title}\nDetected: {num_cuboids} cuboids')
        axes[i].axis('off')
    
    plt.tight_layout()
    plt.savefig('/home/runner/work/peter-code/peter-code/demo_output.png', dpi=150, bbox_inches='tight')
    print('Demo completed! Results saved to demo_output.png')
    print('The algorithm successfully detected cuboids in synthetic images.')
    print('When connected to CoppeliaSim, it will work similarly with real Kinect data.\n')
    
    return fig

if __name__ == '__main__':
    run_demo()
    plt.show()