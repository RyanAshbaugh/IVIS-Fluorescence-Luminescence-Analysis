function [ final_well_centers, final_well_radii ] = ...
			automaticDetection( photo_cell, radii_range, sensitivity )

	% number of images captured during experiment
	num_reads = size( photo_cell, 1 );

	% use the first image to detect wells
	% find the median pixel value from the image
	photo_median = median( photo_cell{1}, 'all' );

	% power of 2 which will be used as a scaler for all pixel values
	threshold_scaler_pow_of_2 = ceil( log2( double( photo_median ) ) );

	% multipy each pixel by power of two, this acts to 'stretch' and threshold
	% pixel values, setting the new maximun to ( 2^16 ) / ( 2^scaler ) = 
	photo_thresh = photo_cell{ 1 } * 2 ^ threshold_scaler_pow_of_2;

	photo_histeq = histeq( photo_thresh );

	% find wells
	[ temp_well_centers, temp_well_radii ] = imfindcircles( photo_thresh, ...
		radii_range, 'Method', 'TwoStage', ...
		'ObjectPolarity', 'bright', 'Sensitivity', sensitivity );
	num_wells_detected = length( temp_well_radii );

	% make cell of wells grouped by column ( sort_direction = 1-columns, 
	%   2-rows )
	[ well_rows_cell, well_rows_radii ] = ...
		extractRowsOrColumns( temp_well_centers, temp_well_radii, 2 );
	[ well_columns_cell, ~ ] = ...
		extractRowsOrColumns( temp_well_centers, temp_well_radii, 1 );

	% sort the wells top to bottom, left to right
	[ well_centers, well_radii ] = ...
		sortWells( temp_well_centers, temp_well_radii, ...
		well_rows_cell, well_rows_radii );
    
	% get lines for all of the rows and columns
	num_rows = size( well_rows_cell, 1 );
	num_cols = size( well_columns_cell, 1 );

	% calculate equations for row and column lines already detected
	[ row_lines, col_lines ] = ...
		calculateLines( well_rows_cell, well_columns_cell );

	% find the wells that are missing
	[ well_centers, well_radii ] = findMissingWells( well_centers, ...
		well_radii, row_lines, col_lines );

	%{
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
	%}
    
	% resort wells after adding any missed wells
	[ well_rows_cell, well_rows_radii ] = ...
		extractRowsOrColumns( well_centers, well_radii, 2 );
	[ final_well_centers, final_well_radii ] = ...
		sortWells( well_centers, well_radii, well_rows_cell, well_rows_radii );

end

