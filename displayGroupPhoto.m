function [ group_handle_cell, msg ] = ...
		displayGroupPhoto( image_axes, well_centers, well_radii, ...
		groups, image_scale, group_handle_cell )

	groups
	if isempty( well_centers )
		msg = 'No wells ROIs found, add wells to the image before grouping';
		return;
	end
	num_groups = size( groups, 2 );

	hold( image_axes, 'on' );
	group_handle_cell

	% delete all of the old markings and text
	if ~isempty( group_handle_cell )
		for group = 1:size( group_handle_cell{1}, 2 )
			delete( group_handle_cell{1}{group} );
			for well = 1:size( group_handle_cell{2}{group}, 2 )
				delete( group_handle_cell{2}{group}{well} );
			end
		end
	end

	colors = hsv( num_groups );
	% for all of the groups
	for ii = 1:num_groups
		
		num_group_wells = size( groups{ii}{2}, 2 );
		group_well_centers = well_centers( groups{ii}{2}, : );
		group_well_radii = well_radii( groups{ii}{2}, : );

		% plot the color of the group
		if num_group_wells > 0
			group_handle_cell{1}{ii} = ...
				plot( image_axes, image_scale * group_well_centers( :, 1 ), ...
				image_scale * group_well_centers( :, 2 ), ...
				'o', 'Color', colors( ii, : ), ...
				'MarkerFaceColor', colors( ii, : ),...
				'MarkerSize', 10 );
		end

		% plot the group number
		for jj = 1:num_group_wells
			xx = image_scale * group_well_centers( jj, 1 );
			yy = image_scale * group_well_centers( jj, 2 );
			group_handle_cell{2}{ii}{jj} = ...
				text( image_axes, xx, yy, num2str( ii ), ...
				'Color', 1 - colors( ii, : ), 'FontSize', 8, ...
				'HorizontalAlignment', 'center' );
		end

	end
	hold( image_axes, 'off' );
	msg = 'Drawing wells on the Group Image Tab...';
	
end

