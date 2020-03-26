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

% find wells
[ well_centers, well_radii ] = imfindcircles( photo_thresh, ...
    approximate_well_radii_range, 'Method', 'TwoStage', ...
    'ObjectPolarity', 'bright' );
num_wells = length( well_radii );

% make cell of wells grouped by column ( sort_direction = 1-columns, 
%   2-rows )
[ well_rows_cell, well_rows_radii ] = ...
    extractRowsOrColumns( well_centers, well_radii, 2 );
well_columns_cell = extractRowsOrColumns( well_centers, well_radii, 1 );

% sort the wells top to bottom, left to right
[ final_well_centers, final_well_radii ] = ...
    sortWells( well_centers, well_radii, well_rows_cell, well_rows_radii );

% get lines for all of the rows and columns
num_rows = size( well_rows_cell, 1 );
num_cols = size( well_columns_cell, 1 );

% calculate equations for row and column lines already detected
[ row_lines, col_lines ] = ...
    calculateLines( well_rows_cell, well_columns_cell );

displayCenters( final_well_centers, photo_width, photo_height );
displayLines( row_lines, col_lines, photo_width );

% go through all the intersecions and see if any points are missing
for ii = 1:num_rows
    for jj = 1:num_cols
        
        % y intercepts
        Bs = -1 * [ row_lines( ii, 1 ); col_lines( jj, 1 ) ];
        
        % slopes
        Ms = [ row_lines( ii, 2 ) -1; col_lines( jj, 2 ) -1 ]; 
        intersect_point = Ms \ Bs; 
        
        distances = distanceToCenters( final_well_centers, intersect_point );
        
        % check if the intersect point is close to any already found points
        if sum( distances < 5 ) == 0
            well_centers = [ well_centers; intersect_point' ];
            well_radii = [ well_radii; round( mean( well_radii ) ) ];
        end
        
    end
end

% resort wells after adding any missed wells
[ well_rows_cell, well_rows_radii ] = ...
    extractRowsOrColumns( well_centers, well_radii, 2 );
[ final_well_centers, final_well_radii ] = ...
    sortWells( well_centers, well_radii, well_rows_cell, well_rows_radii );

image_handle = displayAnalysisPhoto( photo_histeq, image_scale, ...
    final_well_centers, final_well_radii );

well_counts = wellCountAnalysis( lumis_cell, final_well_centers, ...
    final_well_radii );

saveResults( well_counts, top_folder, image_handle );

toc;

