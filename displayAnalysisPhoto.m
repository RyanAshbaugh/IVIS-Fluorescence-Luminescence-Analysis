function image_handle = displayAnalysisPhoto( photo_histeq, image_scale, ...
    final_well_centers, final_well_radii )
%	displayAnalysisPhoto display an image of one photo with all detected wells
%	Arguments:
%		photo_histeq - size of input photo, histogram equalized input image
%		image_scale - how much to scale up size of image by
% 		final_well_centers - num_wells x 2, sorted x y well center locations
%		final_well_radii - num_wells x 1, sorted radii in pixels
%	Returns:
%		image_handle - handle to image/figure

    num_wells = size( final_well_radii, 1 );

    % show the image, but resize it to make it bigger
    figure;
    image_handle = imshow( ...
        imresize(photo_histeq, image_scale * size( photo_histeq ) ) );
    hold on;
    viscircles( final_well_centers * image_scale, ...
        final_well_radii * image_scale, 'LineWidth', 1 );

    % make black dot and put text in it for readability
    plot( image_scale * final_well_centers(:,1), ...
        image_scale * final_well_centers(:,2), ...
        'o', 'Color', 'k', 'MarkerFaceColor', 'k',...
        'MarkerSize', 10 );
    for well = 1:num_wells
        xx = image_scale * final_well_centers( well, 1 );
        yy = image_scale * final_well_centers( well, 2 ); 
        text( xx, yy, num2str( well ), 'Color', 'r', 'FontSize', 8, ...
            'HorizontalAlignment', 'center' );    
    end
    hold off;
end

