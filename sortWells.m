function [ final_well_centers, final_well_radii ] = ...
    sortWells( well_centers, well_radii, well_rows_cell, well_rows_radii )
% 	sortWells - once the the centers and radii have been grouped by rows, we 
% 		want we want to get a matrix with wells sorted top-bottom, left-right, 
% 		so that row 1 is the first well, and row num_wells is the last well. 
%		This makes analysing output much easier, since before, even though 
%		wells were grouped, they could be in any order which is confusing.
%	Arguments:
%		well_centers - num_wells x 2, all of the well centers in x and y
%		well_radii - num_wells x 1, all of the well radii in pixels
%		well_rows_cell - num_rows x 1, cell array, where each entry is an array
%			num_cols x 2 having the centers sorted by well
%		well_rows_radii - same as well_rows_cell but for the radii
%	Returns:
%		final_well_centers - num_wells x 2, centers of wells reorganized so
% 			well 1 is in row 1, 2 in row 2, etc, top-bottom left right
%		final_well_radii - same as final_well_centers, but for radii
%		well_cell_array - cell array with num_rows entries, all sorted as above

    num_rows = size( well_rows_cell, 1 );

	% initialize final matrices
    final_well_centers = zeros( size( well_centers ) );
    final_well_radii = zeros( size( well_radii ) );

	% for all rows
    start_index = 1;
    for row = 1:num_rows

		% find where this row ends to map it to final matrix
        end_index = start_index + size( well_rows_cell{ row, 1 }, 1 ) - 1;

		% now assign that whole slice index to that row's entry
        final_well_centers( ...
            start_index : end_index, : ) = ...
            well_rows_cell{ row, 1 };
        final_well_radii( ...
            start_index : end_index ) = ...
            well_rows_radii{ row, 1 };

		% move to next starting index for final matrices
        start_index = start_index + size( well_rows_cell{ row, 1 }, 1 );
    end

end
