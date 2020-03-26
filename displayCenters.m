function displayCenters( final_well_centers, photo_width, photo_height )
%displayCenters plot the centers of the wells
%  	Arguments:
%		final_well_centers - num_wells x 2, x y points of all the wells
% 		photo_width - width in pixels of photo
%		photo_height - height of photo in pixels

    figure;
    plot( final_well_centers(:,1), ...
        final_well_centers(:,2), ...
        'o', 'Color', 'r', 'MarkerFaceColor', 'k',...
        'MarkerSize', 4 );
    set( gca, 'Ydir', 'reverse' );
    xlim( [ 1 photo_width ] );
    ylim( [ 1 photo_height ] );

end

