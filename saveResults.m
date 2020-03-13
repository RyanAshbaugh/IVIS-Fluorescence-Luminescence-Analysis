function saveResults( well_counts, exp_folder, fig_handle )
%saveResults save results from analyzing tiff files from IVIS experiments
%   Arguments:
%       well_counts - num_wells x num_images, total number of photon counts
%           within each well for each image
%       exp_folder - main experiment folder, location of all image
%           subfolders
%       fig_handle - handle for image with circles and shit

    % construct new matrix having well numbers in first column to allow for
    % rearrangement in excel sheet with ease
    num_wells = size( well_counts, 1 );
    well_counts_with_headers = ...
        zeros( size( well_counts, 1 ), size( well_counts, 2 ) + 1 );
    well_counts_with_headers( :, 1 ) = 1:num_wells;
    well_counts_with_headers( :, 2:end ) = well_counts;

    % save the well counts and analysis images
    count_fname = string( [ exp_folder '\well_counts.csv' ] );
    image_fname = [ exp_folder '\analysis_image.png' ];
    csvwrite( count_fname, well_counts_with_headers );
    saveas( fig_handle, image_fname );

end

