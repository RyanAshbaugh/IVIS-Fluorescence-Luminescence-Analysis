function displayCenters( final_well_centers, photo_width, photo_height )
%displayCenters Summary of this function goes here
%   Detailed explanation goes here

    figure;
    plot( final_well_centers(:,1), ...
        final_well_centers(:,2), ...
        'o', 'Color', 'r', 'MarkerFaceColor', 'k',...
        'MarkerSize', 4 );
    set( gca, 'Ydir', 'reverse' );
    xlim( [ 1 photo_width ] );
    ylim( [ 1 photo_height ] );

end

