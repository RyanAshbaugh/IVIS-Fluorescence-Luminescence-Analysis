function [ well_centers_cell, well_radii_cell ] = extractRowsOrColumns( ...
    well_centers, well_radii, sort_direction )
%	extractRowsOrColumns create a cell which sorts the well centers and radii
%		so they are grouped by either column or row
%   Arguments:
%		well_centers - num_wells x 2, all circle centers in x y points 
%		well_radii - num_wells x 1, all circle radii in pixels 
%       sort_direction - 1 = sort x values (cols), 2 = sort on y values (rows)
%	Returns:
%		well_centers_cell - cell containing entries where each entry is a group
% 			of row/column centers ( num_rows/columns x ( num_columns/row x 2 ))
% 		well_radii_cell - cell with row/column radii (num_rows/columns x 
%			( num_columns/rows x 1 ) )


    num_wells = size( well_centers, 1 );
    
    % sort circles by either x or y values
    [ centers_sorted, centers_sorted_indices ] = ...
        sort( well_centers( :, sort_direction ) );
    max_radius = max( well_radii );

    % look for transitions using difference between adjacent well centers
    starts = ...
        find( [ 1; diff( centers_sorted ) > max_radius ] > 0 );
    ends = ...
        find( [ diff( centers_sorted ) > max_radius; num_wells ] > 0 );
    num_groups = length( starts );

    well_centers_cell = cell( 1 );
    well_radii_cell = cell( 1 );
    for ii = 1:num_groups
        
        % get all points for a group of wells
        group_well_points = well_centers( ...
            centers_sorted_indices( starts(ii):ends(ii) ), : );
        group_well_radii = well_radii( ...
            centers_sorted_indices( starts(ii):ends(ii) ), : );
        
        % now within group, sort the wells
        [ group_wells_sorted, group_wells_sorted_index ] = ...
            sort( group_well_points( :, mod( sort_direction, 2 ) + 1 ) );
        
		% now assign the sorted centers and radii to the final output cell
        well_centers_cell{ ii, 1 } = ...
            group_well_points( group_wells_sorted_index, : );
        well_radii_cell{ ii, 1 } = ...
            group_well_radii( group_wells_sorted_index );
    end
end

