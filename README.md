# IVIS Image Analysis Tool

The IVIS Image Analysis Tool is a MATLAB Application which allows users to analyze images or sequences of images acquired using an IVIS imager. It can perform automated and semi-automated region of interest (ROI) detection for multiwell plates as well as calculate photon counts within ROIs across a sequence of images.

# Usage

To use the IVIS Image Analysis Tool, simply clone the git repository or download it as a .zip file and extract it onto any computer with MATLAB installed.

# Analyzing images

## Selecting an experiment

To analyze a sequence of images, begin by pressing the browse button next to the 'IVIS Experiment Folder' input field. The selected folder must be the folder containing the folders which correspond to each measurement of the IVIS.

For example, if you would like to analyze the sequence of three images named 'Example_Images_SEQ', you would select the top folder 'Example_Images_SEQ' and whose contents are depicted below:

Example_Images_SEQ
+-- Example_Images_001
|	+--AnalyzedClickInfo.txt
|	+--ClickInfo.txt
|	+--luminescent.TIF
|	+--photogragh.TIF
|	+--readbiasonly.TIF
+-- Example_Images_001
|	+--AnalyzedClickInfo.txt
|	+--ClickInfo.txt
|	+--luminescent.TIF
|	+--photogragh.TIF
|	+--readbiasonly.TIF
+-- Example_Images_001
|	+--AnalyzedClickInfo.txt
|	+--ClickInfo.txt
|	+--luminescent.TIF
|	+--photogragh.TIF
|	+--readbiasonly.TIF
+-- Example_Images_SEQ.PNG
+-- SequenceInfo.txt

Once an sequence folder has been selected, the first image in the sequence will be displayed on the right side of the window under the 'Plate Image' tab.

## Generating ROIs

Next, select the type of ROI(s) you will be working with from the 'ROI Type' drop down menu. Currently, 96 well plates are supported.

ROIs can be detected automatically by looking for circles in the sequence images, or they can be selected manually.

### Automatic
To automatically find the ROIs for a multiwell plate, click the 'Automatic' option under the 'ROI Detection Method' radio button group. Then click the 'Place ROIs' button.

### Manual
If the automatic well detection does not perform well in locating the wells, manually selecting them is a good solution.

To manually place the ROIs on the image, click the 'Manual' button and then click the 'Place ROIs' button. A window will open with an image of the plate. By clicking on the image in the center of the four corner wells, the rest of the 96 wells will be filled in automatically. This process can be repeated if the initial placement is not satisfactory.

## Analyzing ROIs

In order to analyze the ROI measurements over time, we first need to assign to groups the ROIs which we are interested in. To do this, begin by clicking the 'Add group' button which allows you to type the name of a new group of wells. This can be helpful to group together wells with the same experimental conditions. An example of two groups and the assignment of wells to those groups is shown below

___________________________________
| Group 1		| 1:6, 8, 10,12:20|
___________________________________
| Group 2		| 25:36			  |
___________________________________

