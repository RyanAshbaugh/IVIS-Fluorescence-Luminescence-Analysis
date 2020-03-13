top_folder = uigetdir('Select main experiment folder');

% put all files in the folder into a list
photo_struct = dir( strcat(top_folder, '/**/photograph.TIF' ) );
lumi_struct = dir( strcat(top_folder, '/**/luminescent.TIF' ) );

num_reads = size( photo_struct, 1 );

photos_cell = cell( num_reads, 1 );
lumis_cell = cell( num_reads, 1 );
for ii = 1:num_reads
    photos_cell{ ii } = imread( ...
        strcat( photo_struct(ii).folder, '\', photo_struct(ii).name ) );
    lumis_cell{ ii } = imread( ...
        strcat( lumi_struct(ii).folder, '\', lumi_struct(ii).name ) );
end