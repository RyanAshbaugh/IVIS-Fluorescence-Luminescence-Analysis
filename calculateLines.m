function [ row_lines, col_lines ] = calculateLines( ...
    well_rows_cell, well_columns_cell )
%	calculateLines - find the 'lines of best fit' for each row and column so
%		that they go through the center points of the wells located there
%	Arguments:
%		well_rows_cell - num_rows x 1 cell array, with entries num_cols x 2
%			having the x,y points of the centers, sorted by rows
%		well_columns_cell - num_cols x 1 cell array, with entries num_rows x 2
% 			having the x,y points of the centers sorted by columns
%	Returns:
% 		row_lines - num_rows x 2, with coefficients for y = m * x + b, ie
%			[ b1 m1; b2 m2; ... b_num_rows m_num_rows ]
% 		col_lines - num_cols x 2, with coefficients for y = m * x + b, ie
%			[ b1 m1; b2 m2; ... b_num_cols m_num_cols ]

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

