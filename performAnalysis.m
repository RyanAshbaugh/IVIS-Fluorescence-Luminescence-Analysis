function [ well_counts, image_handle ] = ...
		performAnalysis( top_folder, approximate_well_radii_range, ...
	   	image_scale, sensitivity )
%	performAnalysis Do all necessary steps to perform the analysis of well
%		light detection over multiple readings, so that it can be used by
%		an app or from the command line
%	Arguments:
% 		top_folder - string with the path for the main experiment folder
%		approximate_well_radii_range - 1 x 2, # of pixels a radii can be
%		image_scale - for enlarging the image for better viewing
%		sensitivity - for detecting circles, higher is more circles
%	Returns:
%		well_counts - num_wells x num_measurements, the total light detected
%			each well for each measurement
%		image_handle - handle for analysis image

	% put all files in the folder into a list, for the photos and luminescence
	photo_struct = dir( strcat(top_folder, '/**/photograph.TIF' ) );
	lumi_struct = dir( strcat(top_folder, '/**/luminescent.TIF' ) );

	% number of images captured during experiment
	num_reads = size( photo_struct, 1 );

	% cell arrays of each monochrome and fluorescence/luminescence image
	[ photos_cell, lumis_cell ] = loadExperimentTiffs( photo_struct, ...
		lumi_struct, num_reads );

%     % display original image
%     figure;
%     imshow( ...
%         imresize(photos_cell{ 1 }, image_scale * size( photos_cell{ 1 } ) ) );
    
	photo_height = size( photos_cell{ 1 }, 1 );
	photo_width = size( photos_cell{ 1 }, 2 );

	% use the first image to detect wells
	% find the median pixel value from the image
	photo_median = median( photos_cell{1}, 'all' );

	% power of 2 which will be used as a scaler for all pixel values
	threshold_scaler_pow_of_2 = ceil( log2( double( photo_median ) ) );

	% multipy each pixel by power of two, this acts to 'stretch' and threshold
	% pixel values, setting the new maximun to ( 2^16 ) / ( 2^scaler ) = 
	photo_thresh = photos_cell{ 1 } * 2 ^ threshold_scaler_pow_of_2;

	% perform histogram equalization
	photo_histeq = histeq( photo_thresh );

%     % display histeq image
%     figure;
%     imshow( ...
%         imresize(photo_histeq, image_scale * size( photo_histeq ) ) );
    
	% find wells
	[ well_centers, well_radii ] = imfindcircles( photo_thresh, ...
		approximate_well_radii_range, 'Method', 'TwoStage', ...
		'ObjectPolarity', 'bright', 'Sensitivity', sensitivity );
	num_wells = length( well_radii );

%     % display detected circles image
%     figure;
%     imshow( ...
%         imresize(photo_histeq, image_scale * size( photo_histeq ) ) );
%     hold on;
%     viscircles( well_centers * image_scale, ...
%         well_radii * image_scale, 'LineWidth', 1 );
%      % make black dot and put text in it for readability
%     plot( image_scale * well_centers(:,1), ...
%         image_scale * well_centers(:,2), ...
%         'o', 'Color', 'k', 'MarkerFaceColor', 'k',...
%         'MarkerSize', 10 );
%     for well = 1:num_wells
%         xx = image_scale * well_centers( well, 1 );
%         yy = image_scale * well_centers( well, 2 ); 
%         text( xx, yy, num2str( well ), 'Color', 'r', 'FontSize', 8, ...
%             'HorizontalAlignment', 'center' );    
%     end
%     hold off;
    
	% make cell of wells grouped by column ( sort_direction = 1-columns, 
	%   2-rows )
	[ well_rows_cell, well_rows_radii ] = ...
		extractRowsOrColumns( well_centers, well_radii, 2 );
	well_columns_cell = extractRowsOrColumns( well_centers, well_radii, 1 );

	% sort the wells top to bottom, left to right
	[ final_well_centers, final_well_radii ] = ...
		sortWells( well_centers, well_radii, well_rows_cell, well_rows_radii );
    
%     % diplay sorted detected wells
%     figure;
%     imshow( ...
%         imresize(photo_histeq, image_scale * size( photo_histeq ) ) );
%     hold on;
%     viscircles( final_well_centers * image_scale, ...
%         well_radii * image_scale, 'LineWidth', 1 );
%     % make black dot and put text in it for readability
%     plot( image_scale * final_well_centers(:,1), ...
%         image_scale * final_well_centers(:,2), ...
%         'o', 'Color', 'k', 'MarkerFaceColor', 'k',...
%         'MarkerSize', 10 );
%     for well = 1:num_wells
%         xx = image_scale * final_well_centers( well, 1 );
%         yy = image_scale * final_well_centers( well, 2 ); 
%         text( xx, yy, num2str( well ), 'Color', 'r', 'FontSize', 8, ...
%             'HorizontalAlignment', 'center' );    
%     end
%     hold off;

	% get lines for all of the rows and columns
	num_rows = size( well_rows_cell, 1 );
	num_cols = size( well_columns_cell, 1 );

	% calculate equations for row and column lines already detected
	[ row_lines, col_lines ] = ...
		calculateLines( well_rows_cell, well_columns_cell );

	% displayCenters( final_well_centers, photo_width, photo_height );
	% displayLines( row_lines, col_lines, photo_width );

	% go through all the intersecions and see if any points are missing
	for ii = 1:num_rows
		for jj = 1:num_cols
			
			% y intercepts
			Bs = -1 * [ row_lines( ii, 1 ); col_lines( jj, 1 ) ];
			
			% slopes
			Ms = [ row_lines( ii, 2 ) -1; col_lines( jj, 2 ) -1 ]; 
			intersect_point = Ms \ Bs; 
			
			distances = distanceToCenters( final_well_centers, intersect_point );
			
			% check if the intersect point is close to any already found points
			if sum( distances < 5 ) == 0
				well_centers = [ well_centers; intersect_point' ];
				well_radii = [ well_radii; round( mean( well_radii ) ) ];
			end
			
		end
    end
    
%     displayCenters( well_centers, photo_width, photo_height );
% 	displayLines( row_lines, col_lines, photo_width );

	% resort wells after adding any missed wells
	[ well_rows_cell, well_rows_radii ] = ...
		extractRowsOrColumns( well_centers, well_radii, 2 );
	[ final_well_centers, final_well_radii ] = ...
		sortWells( well_centers, well_radii, well_rows_cell, well_rows_radii );

	image_handle = displayAnalysisPhoto( photo_histeq, image_scale, ...
		final_well_centers, final_well_radii, 'off' );

	well_counts = wellCountAnalysis( lumis_cell, final_well_centers, ...
		final_well_radii );

end

