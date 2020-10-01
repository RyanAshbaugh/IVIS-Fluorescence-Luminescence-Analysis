function msg = plotCountsOverTime( image_axes, normalized_counts, groups, ...
		stim_indices, mean_flag )
	
	if isempty( normalized_counts )
		msg = 'No well count data to plot';
		return
	elseif isempty( groups )
		msg = 'No well groups found. Generate wells and groups';
		return
	else
		cla( image_axes );

		hold( image_axes, 'on' );

		num_readings = size( normalized_counts, 2 );
		readings_vector = 0:( num_readings - 1 );
		title_str = 'Well counts for each measurement';

		num_groups = size( groups, 2 );
		colors = hsv( num_groups );
		legend_names = {};
		for ii = 1:num_groups
			group_counts = normalized_counts( groups{ii}{2}, : );
			legend_names{ ii } = groups{ ii }{ 1 };
			if ~isempty( group_counts )
				if mean_flag
					plot( image_axes, readings_vector, mean( group_counts ), ...
						'Color', colors(ii,:));
					title_str = 'Avg. group well counts for each measurement';
				else
					plot( image_axes, readings_vector, group_counts, ...
						'Color', colors(ii,:));
				end
			end
		end
		lgd = legend( image_axes, legend_names, 'Location', 'northeastoutside' );
		title( image_axes, title_str );
		xlabel( image_axes, 'Measurement number' );
		ylabel( image_axes, 'Relative Luminescence Units' );

		xlim( image_axes, [ 0 num_readings ] );
		xline( image_axes, stim_indices( 1 ), 'g', 'LineWidth', 1.5, ...
		   'DisplayName', 'Stim on'	);
		xline( image_axes, stim_indices( 2 ), 'r', 'LineWidth', 1.5, ...
		   'DisplayName', 'Stim off' );

		set( image_axes, 'Color', [ 0.1, 0.1, 0.1 ] ); 
		set( lgd, 'Color', [ 0.05, 0.05, 0.05 ], 'TextColor', 'w' ); 
		grid( image_axes, 'on' );
		grid( image_axes, 'minor' );
		image_axes.GridColor = 'w';
		image_axes.MinorGridColor = 'w';
		hold( image_axes, 'off' );
		msg = 'Plotted normalized well counts for each group';
	end

end
