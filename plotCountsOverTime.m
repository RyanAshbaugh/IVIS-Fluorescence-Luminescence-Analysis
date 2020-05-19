function msg = plotCountsOverTime( image_axes, normalized_counts, groups, ...
		mean_flag )
	
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
		legend( image_axes, legend_names );
		title( image_axes, title_str );
		xlabel( image_axes, 'Measurement number' );
		ylabel( image_axes, 'Relative Luminescence Units' );

		hold( image_axes, 'off' );
		msg = 'Plotted normalized well counts for each group';
	end

end
