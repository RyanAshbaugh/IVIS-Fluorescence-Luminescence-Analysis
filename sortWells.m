function [ final_well_centers, final_well_radii, well_cell_array ] = ...
    sortWells( well_centers, well_radii, well_rows_cell, well_rows_radii )

%     num_wells = length( well_radii );
%     
%     % sort circles by y value (row)
%     [ centers_sorted_y, centers_sort_row_index ] = sort( well_centers(:,2) );
%     max_radius = max( well_radii );
% 
%     % look for row transitions using difference between adjacent well centers
%     row_starts = ...
%         find( [ 1; diff( centers_sorted_y ) > max_radius ] > 0 );
%     row_ends = ...
%         find( [ diff(centers_sorted_y) > max_radius; num_wells ] > 0 );
%     num_rows = length( row_starts );
% 
%     % populate the final well centers and radii matrices
%     final_well_centers = zeros( size( well_centers ) );
%     final_well_radii = zeros( size( well_radii ) );
%     well_cell_array = cell( 1 );
%     for yy = 1:num_rows
%         % get a single row of circles
%         row_wells = well_centers( ...
%             centers_sort_row_index( row_starts(yy):row_ends(yy) ),: );
%         row_radii = well_radii( ...
%             centers_sort_row_index( row_starts(yy):row_ends(yy) ) );
% 
%         % sort these on their x value (column)
%         [ row_wells_x_sorted, row_wells_x_sorted_index ] = ...
%             sort( row_wells( :, 1 ) );
% 
%         % then fill the final matrices with the proper sorted circles
%         final_well_centers( row_starts(yy):row_ends(yy), : ) = ...
%             row_wells( row_wells_x_sorted_index, : );
%         final_well_radii( row_starts(yy):row_ends(yy), : ) = ...
%             row_radii( row_wells_x_sorted_index );
%         
%         % cell array for tracking which wells in which row
%         well_cell_array{ yy, 1 } = ...
%             row_wells( row_wells_x_sorted_index, : );
% 
%     end
    
    num_rows = size( well_rows_cell, 1 );
    final_well_centers = zeros( size( well_centers ) );
    final_well_radii = zeros( size( well_radii ) );

    start_index = 1;
    for row = 1:num_rows
        end_index = start_index + size( well_rows_cell{ row, 1 }, 1 ) - 1;
        final_well_centers( ...
            start_index : end_index, : ) = ...
            well_rows_cell{ row, 1 };
        final_well_radii( ...
            start_index : end_index ) = ...
            well_rows_radii{ row, 1 };
        start_index = start_index + size( well_rows_cell{ row, 1 }, 1 );
    end

    well_cell_array = well_rows_cell;
end