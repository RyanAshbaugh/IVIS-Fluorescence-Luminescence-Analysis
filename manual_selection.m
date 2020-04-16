% ivis-analysis
% File name: main.m
% Purpose: analyse tiff images of multiwell plates taken from an IVIS imager
% Input file: folder containing subfolders corresponding to each reading
% 	where subfolder have the tiff images of interest
% Date: 3-26-2020
% Author: Ryan Ashbaugh - ashbau12@msu.edu

clear all; close all;

% select experiment folder to analyze
top_folder = uigetdir('Select main experiment folder');

approximate_well_radii_range = [ 10 20 ];
image_scale = 4;				% enlarge image for better view when saving

tic;    % start timer

% put all files in the folder into a list, for the photos and luminescence
photo_struct = dir( strcat(top_folder, '/**/photograph.TIF' ) );
lumi_struct = dir( strcat(top_folder, '/**/luminescent.TIF' ) );

% number of images captured during experiment
num_reads = size( photo_struct, 1 );

% cell arrays of each monochrome and fluorescence/luminescence image
[ photos_cell, lumis_cell ] = loadExperimentTiffs( photo_struct, ...
    lumi_struct, num_reads );

photo_height = size( photos_cell{ 1 }, 1 );
photo_width = size( photos_cell{ 1 }, 2 );

% use the first image to detect wells
% find the median pixel value from the image
photo_median = median( photos_cell{1}, 'all' );

% power of 2 which will be used as a scaler for all pixel values
threshold_scaler_pow_of_2 = ceil( log2( double( photo_median ) ) );

% multipy each pixel by power of two, this acts to 'stretch' and threshold
% pixel values, setting the new maximun to ( 2^16 ) / ( 2^scaler ) = 
photo_thresh = photos_cell{ 1 } * 2 ^ threshold_scaler_pow_of_2;

% perform histogram equalization
photo_histeq = histeq( photo_thresh );


imshow( photo_histeq );


% pick points
disp('Select four corner wells');
empty_point = images.roi.Point;
corners = [ empty_point empty_point empty_point empty_point ];
for ii = 1:4

	corners( ii ) = drawpoint( 'Color', 'r', 'LineWidth', 1 );

end


