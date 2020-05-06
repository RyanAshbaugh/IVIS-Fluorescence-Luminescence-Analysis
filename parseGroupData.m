function [ groups, msg ] = parseGroupData( indices, ...
		group_numbers, groups )
	
	split_numbers = split( group_numbers, { ' ', ',' } );
	error_msg = '';
	group_id = indices( 1 );

	try
		% for all numbers in new entry of group numbers
		for ii = 1:size( split_numbers, 1 )

			% if the entry is not empty
			if ~isempty( split_numbers{ ii } )
				temp_nums = split( split_numbers{ ii }, ':' );
				
				% if entry is not of kind 1:19, etc then it should not be
				% more than 2
				if size( temp_nums, 1 ) > 2
					error();
				% if it is just a single number, add it 
				elseif size( temp_nums, 1 ) == 1
					well_number = str2num( temp_nums{ 1 } );
					groups{ group_id }{ 2 } = ...
						[ groups{ group_id }{ 2 }, well_number ]; 
				% if it is a range like 1:10 add the range
				elseif size( temp_nums, 1 ) == 2
					range_begin = str2num( temp_nums{ 1 } );
					range_end = str2num( temp_nums{ 2 } );
					well_range = range_begin:range_end;
					groups{ group_id }{ 2 } = ...
						[ groups{ group_id }{ 2 }, well_range ]; 
				end
			end
		end
		msg = 'Groups updated successfully';
	catch ME
		msg = ...
			[ 'Invalid number group selection. Group selection' ...
			'. Selection must follow the example: 1:5, 6, 8,11:12' ];
		rethrow( ME );
	end
end
