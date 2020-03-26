function well_counts = wellCountAnalysis( ...
    lumis_cell, final_well_centers, final_well_radii )
%	wellCountAnalysis perform an analysis of the amount of light being
%		detected in each well for each measurement taken.
%	Arguments:
%		lumis_cell - num_measurements cell array, each entry is the detected
%			light image
%		final_well_centers - num_wells x 2, x y location of sorted wells
% 		final_well_radii - num_wells x 1, radii length in pixels

    num_wells = size( final_well_centers, 1 );
    num_reads = size( lumis_cell, 1 ); 

    % Analysis of luminescence images
    luminescence_rows = size( lumis_cell{ 1 }, 1 );
    luminescence_cols = size( lumis_cell{ 1 }, 2 );

    % row or column vectors filling matrix for capturing indices within circle
    [ columns_grid, row_grid ] = ...
        meshgrid( 1:luminescence_cols, 1:luminescence_rows );

    % total counts for pixels within each well for each reading
    well_counts = zeros( num_wells, num_reads );

    % indices of luminescence image for each well, 1D indices
    well_indices_cell = cell( num_wells, 1 );

    % for every well, get the indices within luminescence image
    for well = 1:num_wells

        % logical mask only for pixels in well
        well_mask = ( row_grid - final_well_centers( well, 2 ) / 2 ) .^ 2 + ...
            ( columns_grid - final_well_centers( well, 1 ) / 2 ) .^ 2 <= ...
            ( final_well_radii( well ) / 2 ) ^ 2;

        % every pixel still > 0 is a well pixel
        well_indices_cell{ well, 1 } = find( well_mask > 0 );

    end

    % for all of the readings and wells
    for ii = 1:num_reads
        for well = 1:num_wells

            % find the total number of counts within well
            well_counts( well, ii ) = ...
                sum( lumis_cell{ ii, 1 }( well_indices_cell{ well, 1 } ) );

        end
    end
end

