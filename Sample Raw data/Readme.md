Before running, may need to change the hard coded folder path to the raw image folder that is being analyzed. Enter the trial number to be analyzed as both "first trial" and "last trial" in script, unless segmenting consecutive trials

When the MATLAB code is run, first frame will pop up (to ask for initial crop), select an area that includes the animal but within arena so the loop will find a nice threshold where only one object is detected

Code will then ask "Cam4 (y/n)?". This is because for some very early experimentation, we played with different illumination setups, and if it was "Cam 4", images have to be inverted. None of the trials included in the paper are  Cam4, so would input 'n'.

Loop will attempt to find a threshold where there's only one object, will as to confirm that this is the trichoplax (input 'y'). Otherwise, can recrop 'r', try adjusting threshold and size range 'a', and other options listed

At any point if the animal cannot be segmented (less than or more than 1 object is detected), the same set of options will be available. Generally adjusting threshold (0.4 to 0.6 range work well) and re-cropping (if there's a debris) help. 

It's very hard to threshold an animal once it hits the rim. If that happens before the code goes through all the images, can hit 'd' (for done) in the list of options given. 

Outputs a text file (timepoint, centroid x coordinate, centroid y coordinate, area (pixels), perimeter (pixels) ), as well as a folder with the figures generated. Take the area and perimeter output with a grain of salt - may be dependent on thresholding, low image resolution, etc. We do not use this data in our paper for these reasons. 