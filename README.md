# README 
This is the code for a fourth semester project in which we gathered hand tracking data and used that to move around a 3DOF (Degrees of Freedom) robotic arm made with 3d printed plastic. A showcase of the product can be seen on youtube at https://www.youtube.com/watch?v=b34DfGKIK74.

The code is NOT pretty and it wasn't written with other people in mind, so i'm sorry :) 

# Functionality
Basically a program will run in Processing 4 https://processing.org/
This program will send data via wi-fi to 3 ESP32 modules. Each is responsible for driving 1-2 servo motors to a specific degree. The servo motors are calibrated but i can't remember how exactly.

# Problems
During examination we we're informed that processing opens and sends data an enormous amount of times which created some lag. We never fixed this but it should be adressed.

# Guide
The project is documented in danish.
Each ESP32 will be wired to 1 or 2 servo motors, this should be obvious by the naming of the arduino files.
Then the processing sketch will be run which should collect data from a LEAPMOTION handtracking device. If you find a different way to input coordinates in xyz space then that should work as well.
