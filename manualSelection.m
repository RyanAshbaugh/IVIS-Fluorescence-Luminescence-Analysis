function all_centers_mat = manualSelection( num_rows, num_cols )

	% select the four corner wells of the plate
	corner_array = selectCorners();

	% sort them top-bottom, left-right, so they can be placed any order
	final_corner_positions = sortSelectedCorners( corner_array );

	% m x n x 2 mat with the last dimension for X and Y positions
	all_wells_tensor = generateAllWells( final_corner_positions, num_cols, num_rows )

	% reshape the array to be m*n x 2
	% first transpose to temp variable so that it sorts left to right, up down
	tmp(:,:,1) = all_wells_tensor(:,:,1)';
	tmp(:,:,2) = all_wells_tensor(:,:,2)';
	all_centers_mat = reshape( tmp, num_cols * num_rows, 2, 1 )

end

