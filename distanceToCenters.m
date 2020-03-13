function distances = distanceToCenters( well_centers, point )
    
    distances = sqrt( ( well_centers(:,1) - point(1) ) .^ 2 + ...
        ( well_centers(:,2) - point(2) ) .^ 2 );

end

