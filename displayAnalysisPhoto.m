function image_handle = displayAnalysisPhoto( photo_histeq, image_scale, ...
    final_well_centers, final_well_radii )
%displayAnalysisPhoto Summary of this function goes here
%   Detailed explanation goes here

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

