function photo_histeq = createDisplayPhoto( photo_cell, scale )

	photo_median = median( photo_cell{ 1 }, 'all' );

	% power of 2 which will be used as a scaler for all pixel values
	threshold_scaler_pow_of_2 = ceil( log2( double( photo_median ) ) );

	% multiply each pixel by power of two, this acst to 'stretch' and threshold
	% pixel values, setting the new maximum to ( 2^16 )/( 2^scaler ) = 
	photo_thresholded = photo_cell{ 1 } * 2 ^ threshold_scaler_pow_of_2;

	% perform histogram equalization
	photo_histeq = histeq( photo_thresholded );

end
