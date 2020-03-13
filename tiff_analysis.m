clear all; close all;

% select experiment folder to analyze
top_folder = uigetdir('Select main experiment folder');

approximate_well_radii_range = [ 10 20 ];
image_scale = 4;

tic;    % start timer

% put all files in the folder into a list, for the photos and luminescence
photo_struct = dir( strcat(top_folder, '/**/photograph.TIF' ) );
lumi_struct = dir( strcat(top_folder, '/**/luminescent.TIF' ) );

% number of images captured during experiment
num_reads = size( photo_struct, 1 );

% load each photo and luminescence image 
photos_cell = cell( num_reads, 1 );
lumis_cell = cell( num_reads, 1 );
for ii = 1:num_reads
    photos_cell{ ii } = imread( ...
        strcat( photo_struct(ii).folder, '\', photo_struct(ii).name ) );
    lumis_cell{ ii } = imread( ...
        strcat( lumi_struct(ii).folder, '\', lumi_struct(ii).name ) );
end

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

% find wells
[ well_centers, well_radii ] = imfindcircles( photo_thresh, ...
    approximate_well_radii_range, 'Method', 'TwoStage', ...
    'ObjectPolarity', 'bright' );
num_wells = length( well_radii );

% analysis ROIs downsampled by 2
well_centers_half = well_centers / 2;
well_radii_half = well_radii / 2;

% sort the wells top to bottom, left to right
[ final_well_centers, final_well_radii, well_rows_cell ] = ...
    sortWells( well_centers, well_radii );

% get lines for all of the rows and columns
num_rows = size( well_rows_cell, 1 );


% group by column
% sort circles by y value (row)
[ centers_sorted_x, centers_sort_col_index ] = sort( well_centers(:,1) );
max_radius = max( well_radii );

% look for row transitions using difference between adjacent well centers
col_starts = ...
    find( [ 1; diff( centers_sorted_x ) > max_radius ] > 0 );
col_ends = ...
    find( [ diff(centers_sorted_x) > max_radius; num_wells ] > 0 );
num_cols = length( col_starts );

well_columns_cell = cell( 1 );
for xx = 1:num_cols
    col_wells = well_centers( ...
        centers_sort_col_index( col_starts(xx):col_ends(xx) ), : );
    [ col_wells_y_sorted, col_wells_y_sorted_index ] = ...
        sort( col_wells( :, 1 ) );
    well_columns_cell{ xx, 1 } = ...
        col_wells( col_wells_y_sorted_index, : );
end

num_cols = size( well_columns_cell, 1 );

row_lines = zeros( num_rows, 2 );
col_lines = zeros( num_cols, 2 );
% for every row
figure;
plot( final_well_centers(:,1), ...
    final_well_centers(:,2), ...
    'o', 'Color', 'r', 'MarkerFaceColor', 'k',...
    'MarkerSize', 4 );
set( gca, 'Ydir', 'reverse' );
xlim( [ 1 photo_width ] );
ylim( [ 1 photo_height ] );
hold on;
for row = 1:num_rows
    
    row_xs = well_rows_cell{ row, 1 }(:,1);
    row_ys = well_rows_cell{ row, 1 }(:,2);
    predictors = [ ones( size( row_xs ) ), row_xs ];
    
    row_lines( row, : ) = regress( row_ys, predictors );
    
    plot( [ 1 480 ], ...
        [ 1 480 ] .* row_lines( row, 2 ) + row_lines( row, 1 ));
    
end

for col = 1:num_cols
    
    col_xs = well_columns_cell{ col, 1 }(:,1);
    col_ys = well_columns_cell{ col, 1 }(:,2);
    predictors = [ ones( size( col_xs ) ), col_xs ];
    
    col_lines( col, : ) = regress( col_ys, predictors );
    
    plot( [ 1 480 ], ...
        [ 1 480 ] .* col_lines( col, 2 ) + col_lines( col, 1 ));
    
end


for ii = 1:num_rows
    for jj = 1:num_cols
        
        % y intercepts
        Bs = -1 * [ row_lines( ii, 1 ); col_lines( jj, 1 ) ];
        
        % slopes
        Ms = [ row_lines( ii, 2 ) -1; col_lines( jj, 2 ) -1 ]; 
        intersect_point = Ms \ Bs; 
        
        distances = distanceToCenters( final_well_centers, intersect_point );
        
        if sum( distances < 5 ) == 0
            well_centers = [ well_centers; intersect_point' ];
            well_radii = [ well_radii; round( mean( well_radii ) ) ];
        end
        
    end
end

hold off;

% resort wells after adding any missed wells
[ final_well_centers, final_well_radii, well_rows_cell ] = ...
    sortWells( well_centers, well_radii );
num_wells = length( well_radii );

%% 
%num_cols = max( cellfun('length', well_cell_array ) );

% show the image, but resize it to make it bigger
figure;
image_handle = imshow( ...
    imresize(photo_histeq, image_scale * size( photo_histeq ) ) );
hold on;
viscircles( well_centers * image_scale, well_radii * image_scale, ...
    'LineWidth', 1 );

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

% Analysis of luminescence images
luminescence_rows = size( lumis_cell{ 1 }, 1 );
luminescence_cols = size( lumis_cell{ 1 }, 2 );

% row or column vectors filling matrix for capturing indices within circle
[ columns_grid, row_grid ] = ...
    meshgrid( 1:luminescence_cols, 1:luminescence_rows );

% total counts for pixels within each well for each reading
well_counts = zeros( num_wells, num_reads );

% indices of luminescence image for each well, 1D indices
well_indices_cell = cell( num_wells, 1 );

% for every well, get the indices within luminescence image
for well = 1:num_wells

    % logical mask only for pixels in well
    well_mask = ( row_grid - final_well_centers( well, 2 ) / 2 ) .^ 2 + ...
        ( columns_grid - final_well_centers( well, 1 ) / 2 ) .^ 2 <= ...
        ( final_well_radii( well ) / 2 ) ^ 2;
    
    % every pixel still > 0 is a well pixel
    well_indices_cell{ well, 1 } = find( well_mask > 0 );
    
end

% for all of the readings and wells
for ii = 1:num_reads
    for well = 1:num_wells
        
        % find the total number of counts within well
        well_counts( well, ii ) = ...
            sum( lumis_cell{ ii, 1 }( well_indices_cell{ well, 1 } ) );
        
    end
end

saveResults( well_counts, top_folder, image_handle );

toc;

