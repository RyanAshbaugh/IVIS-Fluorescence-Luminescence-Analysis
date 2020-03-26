function distances = distanceToCenters( well_centers, point )
%	distanceToCenters find the distance of all of the centers to a point
%	Arguments:
%		well_centers - num_rows x 2, x y points of all centers
%		point - x y point to find distance to
% 	Returns:
%		distances - num_rows x 1, distance of each center to the point
    
    distances = sqrt( ( well_centers(:,1) - point(1) ) .^ 2 + ...
        ( well_centers(:,2) - point(2) ) .^ 2 );

end

