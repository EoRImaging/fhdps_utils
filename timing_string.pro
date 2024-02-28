function timing_string, time
  compile_opt defint32, logical_predicate, strictarr, strictarrsubs

  if time lt 60 then time_str = number_formatter(time, format = '(d8.2)') + ' sec' $
  else if time lt 3600 then time_str = number_formatter(time / 60d, format = '(d8.2)') + ' min' $
  else time_str = number_formatter(time / 3600d, format = '(d8.2)') + ' hours'

  return, time_str
end