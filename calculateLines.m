function [ row_lines, col_lines ] = calculateLines( ...
    well_rows_cell, well_columns_cell )
%calculateLines Summary of this function goes here
%   Detailed explanation goes here

    num_rows = size( well_rows_cell, 1 );
    num_cols = size( well_columns_cell, 1 ); 
    row_lines = zeros( num_rows, 2 );
    col_lines = zeros( num_cols, 2 );

    % for every row
    for row = 1:num_rows

        % grab the row x and ys
        row_xs = well_rows_cell{ row, 1 }(:,1);
        row_ys = well_rows_cell{ row, 1 }(:,2);
        
        % setup lines equation, using 1's for y intercept
        % y = m*x + b
        predictors = [ ones( size( row_xs ) ), row_xs ];
        
        % regress the predictor equations on the y values to get equation
        % for lines
        row_lines( row, : ) = regress( row_ys, predictors );

    end

    % for every column
    for col = 1:num_cols

        % grab the column x and ys
        col_xs = well_columns_cell{ col, 1 }(:,1);
        col_ys = well_columns_cell{ col, 1 }(:,2);
        
        % setup lines equation, using 1's for y intercept
        predictors = [ ones( size( col_xs ) ), col_xs ];

        % regress predictor equations on the y values to get line equation
        col_lines( col, : ) = regress( col_ys, predictors );

    end
end

