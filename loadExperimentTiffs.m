function [ photos_cell, lumis_cell ] = loadExperimentTiffs( ...
    photo_struct, lumi_struct, num_reads )
%loadExperimentTiffs Summary of this function goes here
%   Detailed explanation goes here

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

