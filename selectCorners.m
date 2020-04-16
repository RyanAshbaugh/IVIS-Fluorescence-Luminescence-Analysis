function [ corners_positions, corners_handles ] = selectCorners()

	% pick points
	disp('Select four corner wells');
	empty_point = images.roi.Point;
	corners_handles = [ empty_point empty_point empty_point empty_point ];
	corners_positions = zeros( 4, 2 );

	% for all four corners
	for ii = 1:4

		% draw the point and then add positions to position array
		corners_handles( ii ) = drawpoint( 'Color', 'r', 'LineWidth', 1 );
		corners_positions( ii, : ) = corners_handles( ii ).Position;

	end

end
