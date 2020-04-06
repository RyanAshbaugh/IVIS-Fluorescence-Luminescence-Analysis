% ivis-analysis
% File name: main_app.m
% Purpose: analyse tiff images of multiwell plates taken from an IVIS imager
%	specifically to be used with the gui app
% Input file: folder containing subfolders corresponding to each reading
% 	where subfolder have the tiff images of interest
% Date: 3-26-2020
% Author: Ryan Ashbaugh - ashbau12@msu.edu

clear all; close all;

% select experiment folder to analyze
top_folder = uigetdir('Select main experiment folder');

approximate_well_radii_range = [ 10 20 ];
image_scale = 4;				% enlarge image for better view when saving
sensitivity = 0.86;				% for detecting cirlces

tic;    % start timer

% do all of the analysis
[ well_counts, image_handle ] = performAnalysis( top_folder, ...
	approximate_well_radii_range, image_scale, sensitivity );

saveResults( well_counts, top_folder, image_handle );

toc;


