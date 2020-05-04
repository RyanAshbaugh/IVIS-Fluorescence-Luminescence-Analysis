function all_wells = generateAllWells( corner_positions, num_x_wells, num_y_wells )


	% for storing all of the well x's and y's
	all_wells = zeros( num_y_wells, num_x_wells, 2 );

	% changes and y and x within the first row
	intra_row_dx = ( corner_positions( 1, 2, 1 ) - corner_positions( 1, 1, 1 ) ) / ...
		( num_x_wells - 1 );
	intra_row_dy = ( corner_positions( 1, 2, 2 ) - corner_positions( 1, 1, 2 ) ) / ...
		( num_x_wells - 1 );


	% changes in y and x between rows
	inter_row_dx = ( corner_positions( 2, 1, 1 ) - corner_positions( 1, 1, 1 ) ) / ...
		( num_y_wells - 1 );
	inter_row_dy = ( corner_positions( 2, 1, 2 ) - corner_positions( 1, 1, 2 ) ) / ...
		( num_y_wells - 1 );


	% create the first row and reshape it to be 2 deep tensor
	first_row_x = corner_positions( 1, 1, 1 ):intra_row_dx:corner_positions(1, 2, 1);
	first_row_y = corner_positions( 1, 1, 2 ):intra_row_dy:corner_positions(1, 2, 2);
	first_row = reshape( [ first_row_x'; first_row_y' ], 1, num_x_wells, 2 );

	% create all of the well locations by using teh inter row offsets
	all_wells( :, :, 1 ) = first_row_x + ndgrid( 0:7, 0:11 ) * inter_row_dx;
	all_wells( :, :, 2 ) = first_row_y + ndgrid( 0:7, 0:11 ) * inter_row_dy;


end
