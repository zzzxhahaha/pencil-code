;  $Id: pc_variable_stats.pro,v 1.2 2005-08-28 13:07:40 ajohan Exp $
;
;  Summarize data
;  omit ghost zones in the analysis
;
pro pc_variable_stats,variable, varname=varname, dim=dim, $
    MINIMUM=MINIMUM_, MAXIMUM=MAXIMUM_, MEAN=MEAN_, RMS=RMS_, $
    TRIM=TRIM, NOHEADER=NOHEADER, NOVECTORS=NOVECTORS, _EXTRA=e
COMPILE_OPT IDL2,HIDDEN

xyz = ['x', 'y', 'z']

stat_headings=[ $
               '  name            ',$
               '   ',             $
               'minval         ',$
               'maxval          ',$
               'mean           ',$
               'rms' ]
stats        =[ $
               "' '+strmid(strlowcase(varname)+'          ',0,10)",       $
               "'-->'",         $
               'min(statvar)', $
               'max(statvar)', $
               'mean(statvar)',$
               'rms(statvar)' ]
stat_formats =[ $
               'A10',$
               'A',$
               '1G15.6',$
               '1G15.6',$
               '1G15.6',$
               '1G15.6' ]
requested_stats=make_array(6,/INT,VALUE=0)

if (keyword_set(MINIMUM_) or $
    keyword_set(MAXIMUM_) or $
    keyword_set(MEAN_)    or $
    keyword_set(RMS_) ) then begin
  requested_stats[*]=0
  if keyword_set(MINIMUM_) then requested_stats[2]=1
  if keyword_set(MAXIMUM_) then requested_stats[3]=1
  if keyword_set(MEAN_)    then requested_stats[4]=1
  if keyword_set(RMS_)     then requested_stats[5]=1
endif else begin
  requested_stats[*]=1
endelse

if (n_elements(varname) eq 1) then begin
  requested_stats[0:1]=1
endif else begin
  requested_stats[0:1]=0
endelse

if (n_elements(dim) ne 1) then pc_read_dim, obj=dim, _EXTRA=e

if (not keyword_set(NOHEADER)) then $
    print,arraytostring(stat_headings[where(requested_stats)],LIST='')
;
;  We do not want averages of grid and time parameters.
;
if ( (varname eq 'X') or (varname eq 'Y') or (varname eq 'Z') or $
   (varname eq 'DX') or (varname eq 'DY') or (varname eq 'DZ') or $
   (varname eq 'T') ) then return

varsize=size(variable)

fmt='('+arraytostring(stat_formats[where(requested_stats)],LIST=',',/NOLEAD)+')'
;
;  The array is a scalar field....
;

if ( pc_is_scalarfield(variable, dim=dim, $
    subscripts=subscripts, TRIM=TRIM, NOVECTORS=NOVECTORS) ) then begin

  stats[0]="' '+strmid(strlowcase(varname)+'          ',0,10)"
 
  if (execute("statvar=variable[" + $
      arraytostring(subscripts,/NOLEADER)+"]",1) ne 1) then $
      message, 'Subscripting array  ' + varname 

  cmd = "print, FORMAT=fmt" + $
      arraytostring(stats[where(requested_stats)])  
  if (execute(cmd,1) ne 1) then message, 'Error printing stats for ' + stats[0] 
;
;  The array is a vector field...
;
endif else if ( pc_is_vectorfield(variable, dim=dim, $
   subscripts=subscripts, TRIM=TRIM, NOVECTORS=NOVECTORS) ) then begin

  for j=0,2 do begin
    subscripts[varsize[0]-1]=string(j)
    stats[0]="' '+strmid(strlowcase(varname)+'_'+xyz[j]+'          ',0,10)"

    if (execute("statvar=variable[" + $
        arraytostring(subscripts,/NOLEADER)+"]",1) ne 1) then $
        message, 'Error printing stats for ' + varname 

    cmd = "print, FORMAT=fmt" + arraytostring(stats[where(requested_stats)])  
    if (execute(cmd,1) ne 1) then message, 'Error printing stats for '+stats[0] 
  endfor

endif

end
