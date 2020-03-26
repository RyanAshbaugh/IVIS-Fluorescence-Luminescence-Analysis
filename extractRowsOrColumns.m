function [ well_centers_cell, well_radii_cell ] = extractRowsOrColumns( ...
    well_centers, well_radii, sort_direction )
%extractRowsOrColumns Summary of this function goes here
%   Detailed explanation goes here
%   Arguments:
%       sort_direction - 1 = sort on x values, 2 = sort on y values

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
        
        % now withing group, sort the wells
        [ group_wells_sorted, group_wells_sorted_index ] = ...
            sort( group_well_points( :, mod( sort_direction, 2 ) + 1 ) );
        
        well_centers_cell{ ii, 1 } = ...
            group_well_points( group_wells_sorted_index, : );
        well_radii_cell{ ii, 1 } = ...
            group_well_radii( group_wells_sorted_index );
    end
end

