function displayAnalysisPhoto( image_axes, well_centers, well_radii, ...
		image_scale )
%	displayAnalysisPhoto display an image of one photo with all detected wells
%	Arguments:
%		photo_histeq - size of input photo, histogram equalized input image
%		image_scale - how much to scale up size of image by
% 		final_well_centers - num_wells x 2, sorted x y well center locations
%		final_well_radii - num_wells x 1, sorted radii in pixels
%		visible - on or off to show image
%	Returns:
%		image_handle - handle to image/figure

    num_wells = size( well_radii, 1 );

    % show the image, but resize it to make it bigger
    hold( image_axes, 'on' );

    %viscircles( image_axes, well_centers * image_scale, ...
    %    well_radii * image_scale, 'LineWidth', 1 );

    % make black dot and put text in it for readability
    plot( image_axes, image_scale * well_centers(:,1), ...
        image_scale * well_centers(:,2), ...
        'o', 'Color', 'k', 'MarkerFaceColor', 'k',...
        'MarkerSize', 10 );
    for well = 1:num_wells
        xx = image_scale * well_centers( well, 1 );
        yy = image_scale * well_centers( well, 2 ); 
        text( image_axes, xx, yy, num2str( well ), ...
			'Color', 'r', 'FontSize', 8, ...
            'HorizontalAlignment', 'center' );    

		% draw a circle with the rectangle command, because of course thats how
		% it should work. thanks mathworks
		current_radii = well_radii( well ) * image_scale;
		position_vector = [ ( xx - current_radii ), ( yy - current_radii ), ...
			2 * current_radii, 2 * current_radii ];
		rectangle( image_axes, 'Position', position_vector, ...
			'Curvature', [ 1 1 ], 'EdgeColor', 'r'	);
    end
    hold( image_axes, 'off' );
end

