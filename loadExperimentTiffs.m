function [ photos_cell, lumis_cell ] = loadExperimentTiffs( ...
    photo_struct, lumi_struct, num_reads )
%loadExperimentTiffs load all of the images for selected experiment
%   Arguments:
%		photo_struct - struct populated with info about experiment and image
%			file names. Has the folder names as well.
%		lumi_struct - same as photo_struct, but with the luminescence images
%		num_reads - number of measurements/images
%	Returns:
%		photos_cell - num_reads x 1, cell array with all images
%		lumis_cell - num_reads x 1, cell array with all luminescence images

    % load each photo and luminescence image 
    photos_cell = cell( num_reads, 1 );
    lumis_cell = cell( num_reads, 1 );
    for ii = 1:num_reads
        photos_cell{ ii } = imread( ...
            strcat( photo_struct(ii).folder, '\', photo_struct(ii).name ) );
        lumis_cell{ ii } = imread( ...
            strcat( lumi_struct(ii).folder, '\', lumi_struct(ii).name ) );
    end

end

