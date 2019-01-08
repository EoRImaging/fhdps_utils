function image_window, x_locs, y_locs, image_window_name = image_window_name, $
  fractional_size = fractional_size, xval_center=xval_center, yval_center=yval_center, $
  norm_image_window=norm_image_window

  ;; This function makes a 2D spatial window for an irregularly gridded (e.g. HEALPix) pixel set

  ;; x_locs and y_locs give the x,y values for all the pixels
  ;; (number of image pixels = n_elements(x_locs) = n_elements(y_locs))
  if n_elements(x_locs) ne n_elements(y_locs) then begin
    message, 'Number of x pixel locations must match the number of y pixel locations'
  endif

  x_minmax = minmax(x_locs)
  y_minmax = minmax(y_locs)
  x_extent = x_minmax[1] - x_minmax[0]
  y_extent = y_minmax[1] - y_minmax[0]

  ;; Make a 1001 element mask given the filter type (should be fairly smooth with that many elements).
  window_1d = spectral_window(1001, periodic = periodic, type = image_window_name, fractional_size = fractional_size)

  ;; Make a 1001x1001 mask
  window_2d = window_1d # transpose(window_1d)
  window_extent = N_elements(window_1d)

  if N_elements(xval_center) EQ 0 then xval_center = 0
  if N_elements(yval_center) EQ 0 then yval_center = 0

  ;; Find locations of pixel centers
  pix_center_x = (x_locs - x_minmax[0] - xval_center) * window_extent/x_extent
  pix_center_y = (y_locs - y_minmax[0] - yval_center) * window_extent/y_extent

  ;; Interpolate the mask to the pixel centeres
  pix_window = interpolate(temporary(window_2d), pix_center_x, pix_center_y)

  ;; n_elements(pix_center_y) gives the number of pixels
  if keyword_set(norm_image_window) then norm_factor = sqrt(n_elements(pix_center_y)/total(pix_window^2.)) $
    else norm_factor=1.

  pix_window = pix_window * norm_factor

  return, pix_window
end
