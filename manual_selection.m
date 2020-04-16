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

num_x_wells = 12;
num_y_wells = 8;

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


%{
% pick points
disp('Select four corner wells');
empty_point = images.roi.Point;
temp_corners = [ empty_point empty_point empty_point empty_point ];
corners_array = zeros( 4, 2 );

for ii = 1:4

	temp_corners( ii ) = drawpoint( 'Color', 'r', 'LineWidth', 1 );
	corners_array( ii, : ) = temp_corners( ii ).Position;

end
%}


all_radii = ones( num_x_wells * num_y_wells, 1 ) * 7;

[ corners_array, temp_corners ] = selectCorners();
final_corner_positions = sortSelectedCorners( corners_array );

all_wells_tensor = generateAllWells( final_corner_positions, num_x_wells, num_y_wells );
all_centers_mat = reshape( all_wells_tensor, num_x_wells * num_y_wells, 2, 1 );

h = displayAnalysisPhoto( photo_histeq, image_scale, all_centers_mat, all_radii, 'on' );


