
---

## 🛠 Usage Guide

### Prerequisites

- Unity (version used/tested)  
- VRChat Avatar SDK (if applicable)

### Setup

1. Download the code from git (Code->Download Zip)
2. Open the Zip and drag "360Camera" into your unity assests
3. In Unity, inside "360Camera", open "Prefab"
4. Drag and drop the Avatar Prefab into the scene
5. Detach the avatar BluePrint ID
6. Open the VRC Avatar SDK panel
7. Name/Picture for the avatar
8. Upload Avatar to VRChat

---

##  Usage
https://vrchat.com/home/avatar/avtr_de011766-a8b6-4635-a579-b3da989b6c18
Here is a link to the avatar if you don't want to upload your own version. Recommended to lower your render resolution in SteamVR to avoid crashing. To use the 360 Camera on the Avatar:

1. Open the radial menu by holing down the menu button(R key on desktop)
2. Click "Expressions"
3. See "Enable360Cam(HEAVY PERF)", "World Drop", "ToggleMesh", "STICK/HEAD"
4. To start, Click "Enable360Cam(HEAVY PERF)"
5. You will see a Capture Sphere that hurts to look at and a small screen that follows your hand but a bit out
6. Click "ToggleMesh" to turn on your body, see that the camera is at the end of the stick
7. Click "World Drop" to drop the Capture Sphere somewhere in the world to record
8. Click "STICK/HEAD" to change the camera to the head position or at the end of the stick
9. Open your camera by double clicking the camera icon at the bottom
10. In "Ancor" click "World", this will make the camera no longer follow your position.
11. Grab the lens of the camera and put it inside of the Capture Sphere
12. Use the Arrows to go to the right side of the camera settings
13. In "Camera Resolution", Set it to 8k. (You will have to stretch the image later if you want a  equirectangular panorama) (But You can change the config to match a 2x1 ratio)
14. Use the camera to capture an image

---

## 🎥 How It Works

1. The camera renders 6 views (front, back, left, right, up, down) using separate sub-cameras.  
2. A shader stitches these into a seamless equirectangular panorama.  
3. The result is output to a render texture or saved to a file.

---

## 🧪 Performance & Tips

- LOWER YOUR STEAMVR RESOLUTION
- For video, consider the perforamnce of your system. You may want to lower the resolution of your video/ lower the resolution of the camera Render Textures.   
- Point the VRC camera down or in a direction with fewer objects

