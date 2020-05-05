function [ well_centers, well_radii ] = ...
		findMissingWells( well_centers, well_radii, row_lines, col_lines )

	num_rows = size( row_lines, 1 );
	num_cols = size( col_lines, 1 );

	% go through all the intersecions and see if any points are missing
    for ii = 1:num_rows
		for jj = 1:num_cols

			% y intercepts
			Bs = -1 * [ row_lines( ii, 1 ); col_lines( jj, 1 ) ];
			
		    % slopes
			Ms = [ row_lines( ii, 2 ) -1; col_lines( jj, 2 ) -1 ];
			intersect_point = Ms \ Bs;
	
			distances = distanceToCenters( well_centers, intersect_point );

			% check if the intersect point is close to any already found points
			if sum( distances < 5 ) == 0
				well_centers = [ well_centers; intersect_point' ];
				well_radii = [ well_radii; round( mean( well_radii ) ) ];
			end
		end
	end
end
