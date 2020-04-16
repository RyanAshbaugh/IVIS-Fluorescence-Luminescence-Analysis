function sortedCorners = sortSelectedCorners( corners )


	corners_array_zmean = corners - mean( corners );
	sortedCorners = zeros( 2, 2, 2 );

	% populate to match up with view of image
	index = find( corners_array_zmean( :, 1 ) < 0 & ...
		corners_array_zmean( :, 2 ) < 0 );
	sortedCorners( 1, 1, : ) = corners( index, : );

	index = find( corners_array_zmean( :, 1 ) < 0 & ...
		corners_array_zmean( :, 2 ) > 0 );
	sortedCorners( 2, 1, : ) = corners( index, : );

	index = find( corners_array_zmean( :, 1 ) > 0 & ...
		corners_array_zmean( :, 2 ) > 0 );
	sortedCorners( 2, 2, : ) = corners( index, : );

	index = find( corners_array_zmean( :, 1 ) > 0 & ...
		corners_array_zmean( :, 2 ) < 0 );
	sortedCorners( 1, 2, : ) = corners( index, : );

	return;

end




