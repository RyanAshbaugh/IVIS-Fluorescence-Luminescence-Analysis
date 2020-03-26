function displayLines( row_lines, col_lines, photo_width )
%displayLines Summary of this function goes here
%   Detailed explanation goes here

    num_rows = size( row_lines, 1 );
    num_cols = size( col_lines, 1 );

    hold on;
    row_Xs = repmat( [ 1 photo_width ]', 1, num_rows );
    row_Ys = [ row_lines * [ 1 1 ]', row_lines * [ 1 photo_width ]' ]';
    col_Xs = repmat( [ 1 photo_width ]', 1, num_cols );
    col_Ys = [ col_lines * [ 1 1 ]', col_lines * [ 1 photo_width ]' ]';
    line( row_Xs, row_Ys );
    line( col_Xs, col_Ys );
    hold off;

end

