function msg = plotCountsOverTime( image_axes, well_counts, ...
		normalized_counts, groups )

	
	if isempty( normalized_counts )
		msg = 'No well count data to plot';
		return
	elseif isempty( groups )
		msg = 'No well groups found. Generate wells and groups';
		return
	else
		hold( image_axes, 'on' );
		for ii = 1:size( groups, 2 )
			group_counts = normalized_counts( groups{ii}{2}, : );

			plot( image_axes, group_counts );

		end
		hold( image_axes, 'off' );
		msg = 'Plotted normalized well counts for each group';
	end

end
