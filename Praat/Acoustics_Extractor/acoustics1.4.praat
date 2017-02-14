# acoustics1.4.praat
#
# 2015.6.17 written by Jaegu Kang 
# 2015.6.18 edited: 'nowarn' added (Youngsun)
# 2015.6.25 edited: pre$, post$ are fixed adding which_tier
# 2015.7.16 edited: Resampling is skipped for 'duration' extraction
#                             Extraction without textgrid is added
#                             'number_of_phones' is not needed anymore
# 2015.8.15 edited: number of intervals are corrected('which_tier')
#				       no_Textgrid option is edited with more precision
# 2016.8.25 edited: choice of averaged or point-wise feature extraction added

# Reference scripts (and thanks to):
#   - Chad Vicenik (http://www.linguistics.ucla.edu/faciliti/facilities/acoustic/PraatVoiceSauceImitator.txt)
#   - Christian DiCanio (http://www.acsu.buffalo.edu/~cdicanio/scripts/Get_Formants.praat)

# For future version:
#   - Redundant lines should be cut out and reorganized (Be careful!!!)
#   - Add more comments for easier debugging and manipulation of the script

######################################################################################
################################  Interactive window  #####################################
######################################################################################


form Acoustics extractor
	comment << Acoustics1.4 >>
	comment This script extracts acoustic features from the selected directory.
	comment To manipulate parameters (e.g. reference formants), please check the script.
	comment Directory of wav and textgrid files:
		text Directory /Users/jaegukang/sound/
	comment Full path of the result file:
		text Resultfile /Users/jaegukang/sound/result.txt
	comment Analyze which tier (tier number) in the textgrid:
		positive Which_tier 1
	comment Analyze what phone sets (separated by comma with no space):
		word Phones aa,ee,ii,oo,uu
		boolean all_phones 
	comment Divide segment into how many chunks:
		positive Chunks 3
	choice Extraction_method: 1
		button Averaged
		button Point-wise
	comment Extraction without TextGrid (eg. each sound file contains one vowel)
		boolean No_TextGrid
	comment Acoustic cues (choose variables to measure)
		boolean Duration 1
		boolean Formants 
		boolean Pitch 
		boolean Intensity 
		boolean H1minusH2
		boolean H1minusA1_H1minusA2_H1minusA3
		boolean sd_skewness_kurtosis_COG 
endform


#####################################################################################
###################################    Data preparation    #################################
#####################################################################################


#---------- Set parameters for formant extraction -----------------------------------------------------------------
# comment: you can change here for different parameters
window_length = 0.025
number_formants = 5
f1ref = 500
f2ref = 1485
f3ref = 2450
f4ref = 3550
f5ref = 4650
maximum_formant = 5500
number_tracks = 3
# right_Frequency_cost = 1
freqcost = 1
# right_Bandwidth_cost = 1
bwcost = 1
# right_Transition_cost = 1
transcost = 1


#---------- Create Strings of file list from the directory ------------------------------------------------------------
# comment: File lists of both wav and textgrid will be created 
Create Strings as file list... sound_list 'directory$'*.wav
Create Strings as file list... textgrid_list 'directory$'*.TextGrid


#---------- Check if the result file exists -----------------------------------------------------------------------------
# comment: If the result file exists, praat will overwrite unless any feedback
if fileReadable (resultfile$)
	pause The result file already exists! Do you want to overwrite it?
	filedelete 'resultfile$'
endif


#---------- Read files --------------------------------------------------------------------------------------------------
# comment: Check the number of wav files and textgrids. If they are not same,
# a warning message will pop up
select Strings sound_list
num_files = Get number of strings
select Strings textgrid_list
num_tg = Get number of strings

if num_files = 0
	exitScript: "No sound files in the directory. Please check your directory: ",directory$
endif

if num_tg = 0
	pause No TextGrid files in the directory. Do you want to continue?
endif

if num_files <> num_tg
	pause The numbers of wav files and textgrids are NOT same. Do you want to continue?
endif

if (duration = 0) and (formants = 0) and (pitch = 0) and (intensity = 0) and (h1minusH2 = 0) and (h1minusA1_H1minusA2_H1minusA3 = 0) and (sd_skewness_kurtosis_COG = 0)
	exitScript: "No variables are selected. Please select your variables."
endif

#---------- Info window preparation----------------------------------------------------------------------------------
# comment: Info window should be cleared first. Time elapsed and file counting will be printed.
# Clear info window
clearinfo 

# Count setting
file_counting = 0

# Print start time
startdate$ = date$()
printline Extracting began at ... 'startdate$''newline$'
printline Directory: 'directory$'
printline Resultfile: 'resultfile$' 
printline ---------------------------------------------------------------------------------------------
printline Num of Sounds: 'num_files'
printline Num of TextGrids: 'num_tg'
if no_TextGrid = 0
	printline Tier number: 'which_tier'
else
	printline No TextGrid option selected
endif
if extraction_method = 1
	printline Num of Chunks: 'chunks' (averaged)
else
	printline Num of Chunks: 'chunks' (point-wise)
endif
printline ---------------------------------------------------------------------------------------------
printline Selected variables:

#---------- Header for result file --------------------------------------------------------------------------------------
# comment: Header for result file will be created depending on the options
# you chose for acoustic cues previously
if no_TextGrid = 1
	titleline$ = "Filename,"
	fileappend "'resultfile$'" 'titleline$'
else
	titleline$ = "Filename,Pre,Phone,Post,"
	fileappend "'resultfile$'" 'titleline$'
endif

# Add headers for selected acoustic cues and chunks
### (1) Duration
if duration = 1
	printline duration
	duration = 1
	duration_title$ = "Begtime,Endtime,Duration,"
	fileappend "'resultfile$'" 'duration_title$'
endif
### (2) Formants
if formants = 1
	printline formants
	formants = 1
	for k from 1 to chunks
		k$ = string$(k)
		formant_title$ = "F1_ch"+k$+",F2_ch"+k$+",F3_ch"+k$+",F4_ch"+k$+","
		fileappend "'resultfile$'" 'formant_title$'
	endfor
endif
### (3) Pitch
if pitch = 1
	printline pitch
	pitch = 1
	for k from 1 to chunks
		k$ = string$(k)
		pitch_title$ = "Pitch_ch"+k$+","
		fileappend "'resultfile$'" 'pitch_title$'
	endfor
endif
### (4) Intensity
if intensity = 1
	printline intensity
	intensity = 1
	for k from 1 to chunks
		k$ = string$(k)
		intensity_title$ = "Intensity_ch"+k$+","
		fileappend "'resultfile$'" 'intensity_title$'
	endfor

	# Set minimum pitch value. If this value is too low, praat wouldn't start intensity analysis
	minimum_pitch = 100
endif
### (5) H1minusH2
if h1minusH2 = 1
	printline H1minusH2
	h1minusH2 = 1
	for k from 1 to chunks
		k$ = string$(k)
		h1minush2_title$ = "H1minusH2_ch"+k$+","
		fileappend "'resultfile$'" 'h1minush2_title$'
	endfor

endif
### (6) H1minusA1 & H1minusA2 & H1minusA3
if h1minusA1_H1minusA2_H1minusA3 = 1
	printline H1minusA1_H1minusA2_H1minusA3
	for k from 1 to chunks
		k$ = string$(k)
		h1minusa123_title$ = "H1minusA1_ch"+k$+",H1minusA2_ch"+k$+",H1minusA3_ch"+k$+","
		fileappend "'resultfile$'" 'h1minusa123_title$'
	endfor
endif
### (7) standard deviation(sd) , skewness, kurtosis, center of gravity(COG)
if sd_skewness_kurtosis_COG = 1
	printline sd skewness kurtosis COG
	sd_skewness_kurtosis_COG = 1
	for k from 1 to chunks
		k$ = string$(k)
		values_title$ = "sd_ch"+k$+",skewness_ch"+k$+",kurtosis_ch"+k$+",COG_ch"+k$+","
		fileappend "'resultfile$'" 'values_title$'
	endfor
endif
printline ---------------------------------------------------------------------------------------------

# Make sure the measurements begin from the new line, not from the header
fileappend "'resultfile$'" 'newline$'


#####################################################################################
#############################  Acoustic features extraction    ##############################
#####################################################################################


#------------------------------------------------------------------------------------------------------------------------
#------------(1) Extraction without TextGrid ------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------
			if no_TextGrid = 1
#------------------------------------------------------------------------------------------------------------------------

for ifile from 1 to num_files

	# Read sound file iteratively from the directory
	select Strings sound_list
	name$ = Get string... ifile 
	nowarn Read from file... 'directory$''name$'

	# Resample sound file
	if (duration = 1) and (formants = 0) and (pitch = 0) and (intensity = 0) and (h1minusH2 = 0) and (h1minusA1_H1minusA2_H1minusA3 = 0) and (sd_skewness_kurtosis_COG = 0) 
		wavname$ = selected$("Sound",1)
		sound_resampled = selected("Sound")
	else
		printline Resample 16000...
		wavname$ = selected$("Sound",1)
		Resample... 16000 50
		sound_resampled = selected("Sound")
	endif

	# Pitch tracking
	if pitch = 1 or h1minusH2 = 1 or h1minusA1_H1minusA2_H1minusA3 = 1
		select 'sound_resampled'
		To Pitch... 0 50 600
		pitch_tracking = selected("Pitch")
		Interpolate
		Rename... 'name$'_interpolated
		pitch_interpolated = selected("Pitch")
	endif

	# Intensity tracking
	if intensity = 1
		select 'sound_resampled'
		To Intensity... minimum_pitch 0.0 yes
		intensity_tracking = selected("Intensity")
	endif

	# Extract acoustic cues iteratively
	p_b = Get start time
	p_e = Get end time
	p_d = p_e - p_b

	# Write result file
	resultline$ = "'wavname$',"
	fileappend "'resultfile$'" 'resultline$'

#---------------------- (1) Duration ------------------------------------------------------------------------------------
					if duration = 1
						resultline$ = "'p_b','p_e','p_d',"
						fileappend "'resultfile$'" 'resultline$'
					endif
	
#---------------------- (2) Formants -----------------------------------------------------------------------------------
					if formants = 1
						select 'sound_resampled'
						sound_part = selected("Sound")
						jitter = 0.2

						select 'sound_part'
						To Formant (burg)... 0 number_formants maximum_formant window_length 50
						Rename... 'name$' beforetracking
						formant_beforetracking = selected("Formant")

						xx = Get minimum number of formants
						if xx > 3
						  Track... 4 'f1ref' 'f2ref' 'f3ref' 'f4ref' 'f5ref' 'freqcost' 'bwcost' 'transcost'
						elsif xx > 2
						  Track... 3 'f1ref' 'f2ref' 'f3ref' 'f4ref' 'f5ref' 'freqcost' 'bwcost' 'transcost'
						else
						  Track... 2 'f1ref' 'f2ref' 'f3ref' 'f4ref' 'f5ref' 'freqcost' 'bwcost' 'transcost'
						endif

						Rename... 'name$'_aftertracking
						formant_aftertracking = selected("Formant")
	
						for kounter from 1 to 'chunks'
							# Get the f1,f2,f3 measurements
							part = p_d/chunks
							ex_b = part*(kounter-1)
							ex_e = ex_b + part
	
							select 'formant_aftertracking'
							if extraction_method = 1
								f1 = Get mean... 1 ex_b ex_e Hertz
								f2 = Get mean... 2 ex_b ex_e Hertz
							else
								f1 = Get value at time... 1 ex_b+part/2 Hertz Linear
								f2 = Get value at time... 2 ex_b+part/2 Hertz Linear
							endif
	
							if xx > 3
								if extraction_method = 1
									f4 = Get mean... 4 ex_b ex_e Hertz
									f3 = Get mean... 3 ex_b ex_e Hertz
								else
									f4 = Get value at time... 4 ex_b+part/2 Hertz Linear
									f3 = Get value at time... 3 ex_b+part/2 Hertz Linear
								endif
							elsif xx > 2
								if extraction_method = 1
									f4 = 0
									f3 = Get mean... 3 ex_b ex_e Hertz
								else
									f4 = 0
									f3 = Get value at time... 3 ex_b+part/2 Hertz Linear
								endif
							else
								f4 = 0
								f3 = 0
							endif
							resultline$ = "'f1','f2','f3','f4',"
							fileappend "'resultfile$'" 'resultline$'
						endfor

						# Clear object window
						plus 'formant_beforetracking'
						#plus 'sound_part'
						Remove
						
					endif

#---------------------- (3) Pitch ----------------------------------------------------------------------------------------
					if pitch = 1
						for kounter from 1 to 'chunks'
							part = p_d/chunks
							ex_b = part*(kounter-1)
							ex_e = ex_b + part

							select 'pitch_interpolated'
							if extraction_method = 1
								pitch_val = Get mean... p_b+part*(kounter-1) p_b+kounter*part Hertz
							else
								pitch_val = Get value at time... p_b+part*(2*kounter-1)/2 Hertz Linear
							endif

							if pitch_val = undefined
								pitch_val = 0
							endif

							resultline$ = "'pitch_val',"
							fileappend "'resultfile$'" 'resultline$'
						endfor
					endif

#---------------------- (4) Intensity ------------------------------------------------------------------------------------
					if intensity = 1
						for kounter from 1 to 'chunks'
							part = p_d/chunks
							ex_b = part*(kounter-1)
							ex_e = ex_b + part

							select 'intensity_tracking'
							if extraction_method = 1
								int = Get mean... p_b+part*(kounter-1) p_b+kounter*part dB
							else
								int = Get value at time... p_b+part*(2*kounter-1)/2 Cubic
							endif

							resultline$ = "'int',"
							fileappend "'resultfile$'" 'resultline$'
						endfor
					endif

#---------------------- (5) H1minusH2 ------------------------------------------------------------------------------
					if h1minusH2 = 1
						# Extract a part
						select 'sound_resampled'
						Extract part... p_b p_e "rectangular" 1 "no"
						extracted$ = selected$ ("Sound")
						sound_part= selected("Sound")

						select 'sound_part'
						To Formant (burg)... 0 number_formants maximum_formant window_length 50
						Rename... 'name$' beforetracking
						formant_beforetracking = selected("Formant")

						xx = Get minimum number of formants
						if xx > 3
						  Track... 4 'f1ref' 'f2ref' 'f3ref' 'f4ref' 'f5ref' 'freqcost' 'bwcost' 'transcost'
						elsif xx > 2
						  Track... 3 'f1ref' 'f2ref' 'f3ref' 'f4ref' 'f5ref' 'freqcost' 'bwcost' 'transcost'
						else
						  Track... 2 'f1ref' 'f2ref' 'f3ref' 'f4ref' 'f5ref' 'freqcost' 'bwcost' 'transcost'
						endif

						Rename... 'name$'_aftertracking
						formant_aftertracking = selected("Formant")

						for kounter from 1 to 'chunks'
							# Get the f1,f2,f3 measurements
							part = p_d/chunks
							ex_b = part*(kounter-1)
							ex_e = ex_b + part
							select 'sound_part'
							Extract part...  'ex_b' 'ex_e' Hanning 1 no
							Rename... 'name$'_slice
			 				sound_slice = selected("Sound") 
	
							select 'formant_aftertracking'

							if extraction_method = 1
								f1 = Get mean... 1 ex_b ex_e Hertz
								f2 = Get mean... 2 ex_b ex_e Hertz
							else
								f1 = Get value at time... 1 ex_b+part/2 Hertz Linear
								f2 = Get value at time... 2 ex_b+part/2 Hertz Linear
							endif
	
							if xx > 3
								if extraction_method = 1
									f4 = Get mean... 4 ex_b ex_e Hertz
									f3 = Get mean... 3 ex_b ex_e Hertz
								else
									f4 = Get value at time... 4 ex_b+part/2 Hertz Linear
									f3 = Get value at time... 3 ex_b+part/2 Hertz Linear
								endif
							elsif xx > 2
								if extraction_method = 1
									f4 = 0
									f3 = Get mean... 3 ex_b ex_e Hertz
								else
									f4 = 0
									f3 = Get value at time... 3 ex_b+part/2 Hertz Linear
								endif
							else
								f4 = 0
								f3 = 0
							endif

							# Get F0
							select 'pitch_interpolated'
							if extraction_method = 1
								pitch_val = Get mean... p_b+part*(kounter-1) p_b+kounter*part Hertz
							else
								pitch_val = Get value at time... p_b+part*(2*kounter-1)/2 Hertz Linear
							endif

							if pitch_val = undefined
								pitch_val = 0
							endif

							# Get H1-H2
							select 'sound_slice'
							To Spectrum (fft)
							spectrum = selected("Spectrum")
							To Ltas (1-to-1)
							ltas = selected("Ltas")

							if pitch_val <> undefined  
							  p10_nf0md = 'pitch_val' / 10
							  select 'ltas'
							  lowerbh1 = 'pitch_val' - 'p10_nf0md'
							  upperbh1 = 'pitch_val' + 'p10_nf0md'
							  lowerbh2 = ('pitch_val' * 2) - ('p10_nf0md' * 2)
							  upperbh2 = ('pitch_val' * 2) + ('p10_nf0md' * 2)
							  h1db = Get maximum... 'lowerbh1' 'upperbh1' None
							  #h1hz = Get frequency of maximum... 'lowerbh1' 'upperbh1' None
							  h2db = Get maximum... 'lowerbh2' 'upperbh2' None
							  #h2hz = Get frequency of maximum... 'lowerbh2' 'upperbh2' None
							  #rh1hz = round('h1hz')
							  #rh2hz = round('h2hz')

							# Calculate potential voice quality correlates.
							   h1mnh2 = 'h1db' - 'h2db'
							else
								h1mnh2 = 0
							endif

							resultline$ = "'h1mnh2',"
							fileappend "'resultfile$'" 'resultline$'

							select 'ltas'
							plus 'spectrum'
							plus 'sound_slice'
							Remove
						endfor

						# Clear object window
						select 'formant_aftertracking'
						plus 'formant_beforetracking'
						plus 'sound_part'
						Remove
					endif

#---------------------- (6) H1minusA1 & H1minusA2 & H1minusA3 ------------------------------------------------
					if h1minusA1_H1minusA2_H1minusA3 = 1

						select 'sound_resampled'
						Extract part... p_b p_e "rectangular" 1 "no"
						extracted$ = selected$ ("Sound")
						sound_part= selected("Sound")

						select 'sound_part'
						To Formant (burg)... 0 number_formants maximum_formant window_length 50
						Rename... 'name$' beforetracking
						formant_beforetracking = selected("Formant")

						xx = Get minimum number of formants
						if xx > 3
						  Track... 4 'f1ref' 'f2ref' 'f3ref' 'f4ref' 'f5ref' 'freqcost' 'bwcost' 'transcost'
						elsif xx > 2
						  Track... 3 'f1ref' 'f2ref' 'f3ref' 'f4ref' 'f5ref' 'freqcost' 'bwcost' 'transcost'
						else
						  Track... 2 'f1ref' 'f2ref' 'f3ref' 'f4ref' 'f5ref' 'freqcost' 'bwcost' 'transcost'
						endif

						Rename... 'name$'_aftertracking
						formant_aftertracking = selected("Formant")

						for kounter from 1 to 'chunks'
							# Get the f1,f2,f3 measurements
							part = p_d/chunks
							ex_b = part*(kounter-1)
							ex_e = ex_b + part
							select 'sound_part'
							Extract part...  'ex_b' 'ex_e' Hanning 1 no
							Rename... 'name$'_slice
			 				sound_slice = selected("Sound") 
	
							select 'formant_aftertracking'
							if extraction_method = 1
								f1 = Get mean... 1 ex_b ex_e Hertz
								f2 = Get mean... 2 ex_b ex_e Hertz
							else
								f1 = Get value at time... 1 ex_b+part/2 Hertz Linear
								f2 = Get value at time... 2 ex_b+part/2 Hertz Linear
							endif
	
							if xx > 3
								if extraction_method = 1
									f4 = Get mean... 4 ex_b ex_e Hertz
									f3 = Get mean... 3 ex_b ex_e Hertz
								else
									f4 = Get value at time... 4 ex_b+part/2 Hertz Linear
									f3 = Get value at time... 3 ex_b+part/2 Hertz Linear
								endif
							elsif xx > 2
								if extraction_method = 1
									f4 = 0
									f3 = Get mean... 3 ex_b ex_e Hertz
								else
									f4 = 0
									f3 = Get value at time... 3 ex_b+part/2 Hertz Linear
								endif
							else
								f4 = 0
								f3 = 0
							endif

							# Get F0
							select 'pitch_interpolated'
							if extraction_method = 1
								pitch_val = Get mean... p_b+part*(kounter-1) p_b+kounter*part Hertz
							else
								pitch_val = Get value at time... p_b+part*(2*kounter-1)/2 Hertz Linear
							endif

							if pitch_val = undefined
								pitch_val = 0
							endif

							# Get H1-H2
							select 'sound_slice'
							To Spectrum (fft)
							spectrum = selected("Spectrum")
							To Ltas (1-to-1)
							ltas = selected("Ltas")

							if pitch_val <> undefined  
							  p10_nf0md = 'pitch_val' / 10
							  select 'ltas'
							  lowerbh1 = 'pitch_val' - 'p10_nf0md'
							  upperbh1 = 'pitch_val' + 'p10_nf0md'
							  lowerbh2 = ('pitch_val' * 2) - ('p10_nf0md' * 2)
							  upperbh2 = ('pitch_val' * 2) + ('p10_nf0md' * 2)
							  h1db = Get maximum... 'lowerbh1' 'upperbh1' None
							  h1hz = Get frequency of maximum... 'lowerbh1' 'upperbh1' None
							  h2db = Get maximum... 'lowerbh2' 'upperbh2' None
							  h2hz = Get frequency of maximum... 'lowerbh2' 'upperbh2' None
							  rh1hz = round('h1hz')
							  rh2hz = round('h2hz')

							# Get the a1, a2, a3 measurements.
							  p10_f1hzpt = 'f1' / 10
							  p10_f2hzpt = 'f2' / 10
							  p10_f3hzpt = 'f3' / 10
							  lowerba1 = 'f1' - 'p10_f1hzpt'
							  upperba1 = 'f1' + 'p10_f1hzpt'
							  lowerba2 = 'f2' - 'p10_f2hzpt'
							  upperba2 = 'f2' + 'p10_f2hzpt'
							  lowerba3 = 'f3' - 'p10_f3hzpt'
							  upperba3 = 'f3' + 'p10_f3hzpt'
							  a1db = Get maximum... 'lowerba1' 'upperba1' None
							  a1hz = Get frequency of maximum... 'lowerba1' 'upperba1' None
							  a2db = Get maximum... 'lowerba2' 'upperba2' None
			  				  a2hz = Get frequency of maximum... 'lowerba2' 'upperba2' None
							  a3db = Get maximum... 'lowerba3' 'upperba3' None
							  a3hz = Get frequency of maximum... 'lowerba3' 'upperba3' None

							# Calculate potential voice quality correlates.
							   h1mna1 = 'h1db' - 'a1db'
							   h1mna2 = 'h1db' - 'a2db'
							   h1mna3 = 'h1db' - 'a3db'
							else
								h1mna1 = 0
								h1mna2 = 0
								h1mna3 = 0
							endif

							resultline$ = "'h1mna1','h1mna2','h1mna3',"
							fileappend "'resultfile$'" 'resultline$'

							select 'ltas'
							plus 'spectrum'
							plus 'sound_slice'
							Remove
						endfor

						# Clear object window
						select 'formant_aftertracking'
						plus 'formant_beforetracking'
						plus 'sound_part'
						Remove
					endif

#---------------------- (7) standard deviation, skewness, kurtosis, center of gravity -----------------------------
					if sd_skewness_kurtosis_COG = 1
						# Extract a part
						select 'sound_resampled'
						Extract part... p_b p_e "rectangular" 1 "no"
						extracted$ = selected$ ("Sound")
						sound_part= selected("Sound")

						for kounter from 1 to 'chunks'
							part = p_d/chunks
							ex_b = part*(kounter-1)
							ex_e = ex_b + part
							select 'sound_part'
							Extract part...  'ex_b' 'ex_e' Hanning 1 no
							Rename... 'name$'_slice
			 				sound_slice = selected("Sound") 

							select 'sound_slice'
							To Spectrum (fft)
							spectrum = selected("Spectrum")

							grav = Get centre of gravity... 2
							sdev = Get standard deviation... 2
							skew = Get skewness... 2
							kurt = Get kurtosis... 2

							resultline$ = "'sdev','skew','kurt','grav',"
							fileappend "'resultfile$'" 'resultline$'

							select 'spectrum'
							plus 'sound_slice'
							Remove
						endfor
						select 'sound_part'
						Remove
					endif

					# Make sure the measurements begin from the next line, not from the header
					fileappend "'resultfile$'" 'newline$'

	file_counting = file_counting + 1
	date$ = date$()
	printline FileNum:'file_counting' / 'num_files' 'date$' 'directory$''name$' ... done

	# Clear object window
	select all
	minus Strings sound_list
	Remove

endfor

select all
Remove


#------------------------------------------------------------------------------------------------------------------------
#------------(2) For all phones ------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------
			elsif all_phones = 1
#------------------------------------------------------------------------------------------------------------------------

for ifile from 1 to num_files

	# Read sound file iteratively from the directory
	select Strings sound_list
	name$ = Get string... ifile 
	nowarn Read from file... 'directory$''name$'

	# Resample sound file
	if (duration = 1) and (formants = 0) and (pitch = 0) and (intensity = 0) and (h1minusH2 = 0) and (h1minusA1_H1minusA2_H1minusA3 = 0) and (sd_skewness_kurtosis_COG = 0) 
		wavname$ = selected$("Sound",1)
		sound_resampled = selected("Sound")
	else
		printline Resample 16000...
		wavname$ = selected$("Sound",1)
		Resample... 16000 50
		sound_resampled = selected("Sound")
	endif

	# Pitch tracking
	if pitch = 1 or h1minusH2 = 1 or h1minusA1_H1minusA2_H1minusA3 = 1
		select 'sound_resampled'
		To Pitch... 0 50 600
		pitch_tracking = selected("Pitch")
		Interpolate
		Rename... 'name$'_interpolated
		pitch_interpolated = selected("Pitch")
	endif

	# Intensity tracking
	if intensity = 1
		select 'sound_resampled'
		To Intensity... 10 0.0 yes
		intensity_tracking = selected("Intensity")	
	endif

	# Open textgrid file
	tgname$ = "'directory$''wavname$'.TextGrid"
	if fileReadable (tgname$)
		nowarn Read from file... 'tgname$'
		textgrid = selected("TextGrid")
		select 'textgrid'
		num_intervals = Get number of intervals... which_tier

		# Check labels with predefined phone sets

		for iLabel from 1 to num_intervals
			# Extract phone one by one
			select 'textgrid'
			iPhone = 1
			ph_set$ = phones$
			p_label$ = Get label of interval... 'which_tier' 'iLabel'

#			while iPhone <= number_of_phones
#				commaLoc = index_regex(ph_set$,",")
#				ph_set_length = length(ph_set$)
#				if commaLoc = 0
#					one_phone$ = ph_set$
#				else
#					one_phone$ = left$(ph_set$,commaLoc-1)
#				endif
#				one_phone_length = length(one_phone$)

					select 'textgrid'
					p_b = Get starting point... which_tier iLabel
					p_e = Get end point... which_tier iLabel
					p_d = p_e - p_b	
					jitter = 0.2

					# Add Pre & Post phone
					if iLabel = 1
						pre$ = "Start"
						posttime = iLabel+1
						post$ = Get label of interval... which_tier posttime
					elsif iLabel = num_intervals
						post$ = "End"
					elsif iLabel <> 1 and iLabel <> num_intervals
						pretime = iLabel-1
						posttime = iLabel+1
						pre$ = Get label of interval... which_tier pretime
						post$ = Get label of interval... which_tier posttime
					endif

					# Write result file
					resultline$ = "'wavname$','pre$','p_label$','post$',"
					fileappend "'resultfile$'" 'resultline$'

#---------------------- (1) Duration ------------------------------------------------------------------------------------
					if duration = 1
						resultline$ = "'p_b','p_e','p_d',"
						fileappend "'resultfile$'" 'resultline$'
					endif

#---------------------- (2) Formants -----------------------------------------------------------------------------------
					if formants = 1
						# Extract a part
						select 'sound_resampled'
						# Add jitter for accurate formant tracking
						jitter = 0.2

						Extract part... p_b-jitter p_e+jitter "rectangular" 1 "no"
						extracted$ = selected$ ("Sound")
						sound_part = selected("Sound")

						select 'sound_part'
						To Formant (burg)... 0 number_formants maximum_formant window_length 50
						Rename... 'name$' beforetracking
						formant_beforetracking = selected("Formant")

						xx = Get minimum number of formants
						if xx > 3
						  Track... 4 'f1ref' 'f2ref' 'f3ref' 'f4ref' 'f5ref' 'freqcost' 'bwcost' 'transcost'
						elsif xx > 2
						  Track... 3 'f1ref' 'f2ref' 'f3ref' 'f4ref' 'f5ref' 'freqcost' 'bwcost' 'transcost'
						elsif xx > 1
						  Track... 2 'f1ref' 'f2ref' 'f3ref' 'f4ref' 'f5ref' 'freqcost' 'bwcost' 'transcost'
						else
						  exitScript: "Only first formant was tracked. Check your file."
						endif

						Rename... 'name$'_aftertracking
						formant_aftertracking = selected("Formant")
	
						for kounter from 1 to 'chunks'
							# Get the f1,f2,f3 measurements
							part = p_d/chunks
							ex_b = part*(kounter-1) + jitter
							ex_e = ex_b + part
	
							select 'formant_aftertracking'

							if extraction_method = 1
								f1 = Get mean... 1 ex_b ex_e Hertz
								f2 = Get mean... 2 ex_b ex_e Hertz
							else
								f1 = Get value at time... 1 ex_b+part/2 Hertz Linear
								f2 = Get value at time... 2 ex_b+part/2 Hertz Linear
							endif
	
							if xx > 3
								if extraction_method = 1
									f4 = Get mean... 4 ex_b ex_e Hertz
									f3 = Get mean... 3 ex_b ex_e Hertz
								else
									f4 = Get value at time... 4 ex_b+part/2 Hertz Linear
									f3 = Get value at time... 3 ex_b+part/2 Hertz Linear
								endif
							elsif xx > 2
								if extraction_method = 1
									f4 = 0
									f3 = Get mean... 3 ex_b ex_e Hertz
								else
									f4 = 0
									f3 = Get value at time... 3 ex_b+part/2 Hertz Linear
								endif
							else
								f4 = 0
								f3 = 0
							endif

							resultline$ = "'f1','f2','f3','f4',"
							fileappend "'resultfile$'" 'resultline$'
						endfor

						# Clear object window
						plus 'formant_beforetracking'
						plus 'sound_part'
						Remove
						
					endif

#---------------------- (3) Pitch ----------------------------------------------------------------------------------------
					if pitch = 1
						for kounter from 1 to 'chunks'
							part = p_d/chunks
							ex_b = part*(kounter-1) + jitter
							ex_e = ex_b + part

							select 'pitch_interpolated'
							if extraction_method = 1
								pitch_val = Get mean... p_b+part*(kounter-1) p_b+kounter*part Hertz
							else
								pitch_val = Get value at time... p_b+part*(2*kounter-1)/2 Hertz Linear
							endif

							if pitch_val = undefined
								pitch_val = 0
							endif

							resultline$ = "'pitch_val',"
							fileappend "'resultfile$'" 'resultline$'
						endfor
					endif

#---------------------- (4) Intensity ------------------------------------------------------------------------------------
					if intensity = 1
						for kounter from 1 to 'chunks'
							part = p_d/chunks
							ex_b = part*(kounter-1) + jitter
							ex_e = ex_b + part

							select 'intensity_tracking'
							if extraction_method = 1
								int = Get mean... p_b+part*(kounter-1) p_b+kounter*part dB
							else
								int = Get value at time... p_b+part*(2*kounter-1)/2 Cubic
							endif


							resultline$ = "'int',"
							fileappend "'resultfile$'" 'resultline$'
						endfor
					endif
				

#---------------------- (5) H1minusH2 ------------------------------------------------------------------------------
					if h1minusH2 = 1
						# Extract a part
						select 'sound_resampled'
						# Add jitter for accurate formant tracking
						jitter = 0.2

						Extract part... p_b-jitter p_e+jitter "rectangular" 1 "no"
						extracted$ = selected$ ("Sound")
						sound_part= selected("Sound")

						select 'sound_part'
						To Formant (burg)... 0 number_formants maximum_formant window_length 50
						Rename... 'name$' beforetracking
						formant_beforetracking = selected("Formant")

						xx = Get minimum number of formants
						if xx > 3
						  Track... 4 'f1ref' 'f2ref' 'f3ref' 'f4ref' 'f5ref' 'freqcost' 'bwcost' 'transcost'
						elsif xx > 2
						  Track... 3 'f1ref' 'f2ref' 'f3ref' 'f4ref' 'f5ref' 'freqcost' 'bwcost' 'transcost'
						else
						  Track... 2 'f1ref' 'f2ref' 'f3ref' 'f4ref' 'f5ref' 'freqcost' 'bwcost' 'transcost'
						endif

						Rename... 'name$'_aftertracking
						formant_aftertracking = selected("Formant")

						for kounter from 1 to 'chunks'
							# Get the f1,f2,f3 measurements
							part = p_d/chunks
							ex_b = part*(kounter-1) + jitter
							ex_e = ex_b + part
							select 'sound_part'
							Extract part...  'ex_b' 'ex_e' Hanning 1 no
							Rename... 'name$'_slice
			 				sound_slice = selected("Sound") 
	
							select 'formant_aftertracking'
							if extraction_method = 1
								f1 = Get mean... 1 ex_b ex_e Hertz
								f2 = Get mean... 2 ex_b ex_e Hertz
							else
								f1 = Get value at time... 1 ex_b+part/2 Hertz Linear
								f2 = Get value at time... 2 ex_b+part/2 Hertz Linear
							endif
	
							if xx > 3
								if extraction_method = 1
									f4 = Get mean... 4 ex_b ex_e Hertz
									f3 = Get mean... 3 ex_b ex_e Hertz
								else
									f4 = Get value at time... 4 ex_b+part/2 Hertz Linear
									f3 = Get value at time... 3 ex_b+part/2 Hertz Linear
								endif
							elsif xx > 2
								if extraction_method = 1
									f4 = 0
									f3 = Get mean... 3 ex_b ex_e Hertz
								else
									f4 = 0
									f3 = Get value at time... 3 ex_b+part/2 Hertz Linear
								endif
							else
								f4 = 0
								f3 = 0
							endif

							# Get F0
							select 'pitch_interpolated'
							if extraction_method = 1
								pitch_val = Get mean... p_b+part*(kounter-1) p_b+kounter*part Hertz
							else
								pitch_val = Get value at time... p_b+part*(2*kounter-1)/2 Hertz Linear
							endif

							if pitch_val = undefined
								pitch_val = 0
							endif

							# Get H1-H2
							select 'sound_slice'
							To Spectrum (fft)
							spectrum = selected("Spectrum")
							To Ltas (1-to-1)
							ltas = selected("Ltas")

							if pitch_val <> undefined  
							  p10_nf0md = 'pitch_val' / 10
							  select 'ltas'
							  lowerbh1 = 'pitch_val' - 'p10_nf0md'
							  upperbh1 = 'pitch_val' + 'p10_nf0md'
							  lowerbh2 = ('pitch_val' * 2) - ('p10_nf0md' * 2)
							  upperbh2 = ('pitch_val' * 2) + ('p10_nf0md' * 2)
							  h1db = Get maximum... 'lowerbh1' 'upperbh1' None
							  #h1hz = Get frequency of maximum... 'lowerbh1' 'upperbh1' None
							  h2db = Get maximum... 'lowerbh2' 'upperbh2' None
							  #h2hz = Get frequency of maximum... 'lowerbh2' 'upperbh2' None
							  #rh1hz = round('h1hz')
							  #rh2hz = round('h2hz')

							# Calculate potential voice quality correlates.
							   h1mnh2 = 'h1db' - 'h2db'
							else
								h1mnh2 = 0
							endif

							resultline$ = "'h1mnh2',"
							fileappend "'resultfile$'" 'resultline$'

							select 'ltas'
							plus 'spectrum'
							plus 'sound_slice'
							Remove
						endfor

						# Clear object window
						select 'formant_aftertracking'
						plus 'formant_beforetracking'
						plus 'sound_part'
						Remove
					endif

#---------------------- (6) H1minusA1 & H1minusA2 & H1minusA3 ------------------------------------------------
					if h1minusA1_H1minusA2_H1minusA3 = 1
						# Extract a part
						select 'sound_resampled'
						# Add jitter for accurate formant tracking
						jitter = 0.2

						Extract part... p_b-jitter p_e+jitter "rectangular" 1 "no"
						extracted$ = selected$ ("Sound")
						sound_part= selected("Sound")

						select 'sound_part'
						To Formant (burg)... 0 number_formants maximum_formant window_length 50
						Rename... 'name$' beforetracking
						formant_beforetracking = selected("Formant")

						xx = Get minimum number of formants
						if xx > 3
						  Track... 4 'f1ref' 'f2ref' 'f3ref' 'f4ref' 'f5ref' 'freqcost' 'bwcost' 'transcost'
						elsif xx > 2
						  Track... 3 'f1ref' 'f2ref' 'f3ref' 'f4ref' 'f5ref' 'freqcost' 'bwcost' 'transcost'
						else
						  Track... 2 'f1ref' 'f2ref' 'f3ref' 'f4ref' 'f5ref' 'freqcost' 'bwcost' 'transcost'
						endif

						Rename... 'name$'_aftertracking
						formant_aftertracking = selected("Formant")

						for kounter from 1 to 'chunks'
							# Get the f1,f2,f3 measurements
							part = p_d/chunks
							ex_b = part*(kounter-1) + jitter
							ex_e = ex_b + part
							select 'sound_part'
							Extract part...  'ex_b' 'ex_e' Hanning 1 no
							Rename... 'name$'_slice
			 				sound_slice = selected("Sound") 
	
							select 'formant_aftertracking'
							if extraction_method = 1
								f1 = Get mean... 1 ex_b ex_e Hertz
								f2 = Get mean... 2 ex_b ex_e Hertz
							else
								f1 = Get value at time... 1 ex_b+part/2 Hertz Linear
								f2 = Get value at time... 2 ex_b+part/2 Hertz Linear
							endif
	
							if xx > 3
								if extraction_method = 1
									f4 = Get mean... 4 ex_b ex_e Hertz
									f3 = Get mean... 3 ex_b ex_e Hertz
								else
									f4 = Get value at time... 4 ex_b+part/2 Hertz Linear
									f3 = Get value at time... 3 ex_b+part/2 Hertz Linear
								endif
							elsif xx > 2
								if extraction_method = 1
									f4 = 0
									f3 = Get mean... 3 ex_b ex_e Hertz
								else
									f4 = 0
									f3 = Get value at time... 3 ex_b+part/2 Hertz Linear
								endif
							else
								f4 = 0
								f3 = 0
							endif

							# Get F0
							select 'pitch_interpolated'
							if extraction_method = 1
								pitch_val = Get mean... p_b+part*(kounter-1) p_b+kounter*part Hertz
							else
								pitch_val = Get value at time... p_b+part*(2*kounter-1)/2 Hertz Linear
							endif

							if pitch_val = undefined
								pitch_val = 0
							endif

							# Get H1-H2
							select 'sound_slice'
							To Spectrum (fft)
							spectrum = selected("Spectrum")
							To Ltas (1-to-1)
							ltas = selected("Ltas")

							if pitch_val <> undefined  
							  p10_nf0md = 'pitch_val' / 10
							  select 'ltas'
							  lowerbh1 = 'pitch_val' - 'p10_nf0md'
							  upperbh1 = 'pitch_val' + 'p10_nf0md'
							  lowerbh2 = ('pitch_val' * 2) - ('p10_nf0md' * 2)
							  upperbh2 = ('pitch_val' * 2) + ('p10_nf0md' * 2)
							  h1db = Get maximum... 'lowerbh1' 'upperbh1' None
							  h1hz = Get frequency of maximum... 'lowerbh1' 'upperbh1' None
							  h2db = Get maximum... 'lowerbh2' 'upperbh2' None
							  h2hz = Get frequency of maximum... 'lowerbh2' 'upperbh2' None
							  rh1hz = round('h1hz')
							  rh2hz = round('h2hz')

							# Get the a1, a2, a3 measurements.
							  p10_f1hzpt = 'f1' / 10
							  p10_f2hzpt = 'f2' / 10
							  p10_f3hzpt = 'f3' / 10
							  lowerba1 = 'f1' - 'p10_f1hzpt'
							  upperba1 = 'f1' + 'p10_f1hzpt'
							  lowerba2 = 'f2' - 'p10_f2hzpt'
							  upperba2 = 'f2' + 'p10_f2hzpt'
							  lowerba3 = 'f3' - 'p10_f3hzpt'
							  upperba3 = 'f3' + 'p10_f3hzpt'
							  a1db = Get maximum... 'lowerba1' 'upperba1' None
							  a1hz = Get frequency of maximum... 'lowerba1' 'upperba1' None
							  a2db = Get maximum... 'lowerba2' 'upperba2' None
			  				  a2hz = Get frequency of maximum... 'lowerba2' 'upperba2' None
							  a3db = Get maximum... 'lowerba3' 'upperba3' None
							  a3hz = Get frequency of maximum... 'lowerba3' 'upperba3' None

							# Calculate potential voice quality correlates.
							   h1mna1 = 'h1db' - 'a1db'
							   h1mna2 = 'h1db' - 'a2db'
							   h1mna3 = 'h1db' - 'a3db'
							else
								h1mna1 = 0
								h1mna2 = 0
								h1mna3 = 0
							endif

							resultline$ = "'h1mna1','h1mna2','h1mna3',"
							fileappend "'resultfile$'" 'resultline$'

							select 'ltas'
							plus 'spectrum'
							plus 'sound_slice'
							Remove
						endfor

						# Clear object window
						select 'formant_aftertracking'
						plus 'formant_beforetracking'
						plus 'sound_part'
						Remove
					endif

#---------------------- (7) standard deviation, skewness, kurtosis, center of gravity -----------------------------
					if sd_skewness_kurtosis_COG = 1
						# Extract a part
						select 'sound_resampled'
						# Add jitter for accurate formant tracking
						jitter = 0.2

						Extract part... p_b-jitter p_e+jitter "rectangular" 1 "no"
						extracted$ = selected$ ("Sound")
						sound_part= selected("Sound")

						for kounter from 1 to 'chunks'
							part = p_d/chunks
							ex_b = part*(kounter-1) + jitter
							ex_e = ex_b + part
							select 'sound_part'
							Extract part...  'ex_b' 'ex_e' Hanning 1 no
							Rename... 'name$'_slice
			 				sound_slice = selected("Sound") 

							select 'sound_slice'
							To Spectrum (fft)
							spectrum = selected("Spectrum")

							grav = Get centre of gravity... 2
							sdev = Get standard deviation... 2
							skew = Get skewness... 2
							kurt = Get kurtosis... 2

							resultline$ = "'sdev','skew','kurt','grav',"
							fileappend "'resultfile$'" 'resultline$'

							select 'spectrum'
							plus 'sound_slice'
							Remove
						endfor
						select 'sound_part'
						Remove
					endif

					# Make sure the measurements begin from the next line, not from the header
					fileappend "'resultfile$'" 'newline$'

		endfor
	endif
	
	file_counting = file_counting + 1
	date$ = date$()
	printline FileNum:'file_counting' / 'num_files' 'date$' 'directory$''name$' ... done

	# Clear object window
	select all
	minus Strings sound_list
	minus Strings textgrid_list
	Remove

endfor

select all
Remove


#------------------------------------------------------------------------------------------------------------------------
#------------(3) For specified phones ----------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------
			elsif all_phones = 0
#------------------------------------------------------------------------------------------------------------------------


for ifile from 1 to num_files

	# Read sound file iteratively from the directory
	select Strings sound_list
	name$ = Get string... ifile 
	nowarn Read from file... 'directory$''name$'

	# Resample sound file
	if (duration = 1) and (formants = 0) and (pitch = 0) and (intensity = 0) and (h1minusH2 = 0) and (h1minusA1_H1minusA2_H1minusA3 = 0) and (sd_skewness_kurtosis_COG = 0) 
		wavname$ = selected$("Sound",1)
		sound_resampled = selected("Sound")
	else
		printline Resample 16000...
		wavname$ = selected$("Sound",1)
		Resample... 16000 50
		sound_resampled = selected("Sound")
	endif

	# Pitch tracking
	if pitch = 1 or h1minusH2 = 1 or h1minusA1_H1minusA2_H1minusA3 = 1
		select 'sound_resampled'
		To Pitch... 0 50 600
		pitch_tracking = selected("Pitch")
		Interpolate
		Rename... 'name$'_interpolated
		pitch_interpolated = selected("Pitch")
	endif

	# Intensity tracking
	if intensity = 1
		select 'sound_resampled'
		To Intensity... 10 0.0 yes
		intensity_tracking = selected("Intensity")	
	endif

	# Open textgrid file
	tgname$ = "'directory$''wavname$'.TextGrid"
	if fileReadable (tgname$)
		nowarn Read from file... 'tgname$'
		textgrid = selected("TextGrid")
		select 'textgrid'
		num_intervals = Get number of intervals... which_tier  

		# Check labels with predefined phone sets

		for iLabel from 1 to num_intervals
			# Extract phone one by one
			select 'textgrid'
			iPhone = 1
			ph_set$ = phones$
			p_label$ = Get label of interval... 'which_tier' 'iLabel'

			# Check phones
			if length(ph_set$) = 0
				exitScript: "Phones are not specified. Please type in phones first."
			endif

			# Count number_of_phones
			cnt = 1
			tmp$ = ph_set$
			val = index_regex(tmp$,",")
			long = length(tmp$)

			while index_regex(tmp$,",") <> 0
				cnt = cnt + 1
				tmp$ = right$(tmp$,long - val)
				val = index_regex(tmp$,",")
				long = length(tmp$)
			endwhile

			number_of_phones = cnt

			while iPhone <= number_of_phones
				commaLoc = index_regex(ph_set$,",")
				ph_set_length = length(ph_set$)
				if commaLoc = 0
					one_phone$ = ph_set$
				else
					one_phone$ = left$(ph_set$,commaLoc-1)
				endif
				one_phone_length = length(one_phone$)

				##### Check if one_phone matches with the label #####
				if one_phone$ = p_label$
					select 'textgrid'
					p_b = Get starting point... which_tier iLabel
					p_e = Get end point... which_tier iLabel
					p_d = p_e - p_b	
					jitter = 0.2

					# Add Pre & Post phone
					if iLabel = 1
						pre$ = "Start"
					elsif iLabel = num_intervals
						post$ = "End"
					elsif iLabel <> 1 and iLabel <> num_intervals
						pretime = iLabel-1
						posttime = iLabel+1
						pre$ = Get label of interval... which_tier pretime
						post$ = Get label of interval... which_tier posttime
					endif

					# Write result file
					resultline$ = "'wavname$','pre$','one_phone$','post$',"
					fileappend "'resultfile$'" 'resultline$'

#---------------------- (1) Duration ------------------------------------------------------------------------------------
					if duration = 1
						resultline$ = "'p_b','p_e','p_d',"
						fileappend "'resultfile$'" 'resultline$'
					endif

#---------------------- (2) Formants -----------------------------------------------------------------------------------
					if formants = 1
						# Extract a part
						select 'sound_resampled'
						# Add jitter for accurate formant tracking
						jitter = 0.2

						Extract part... p_b-jitter p_e+jitter "rectangular" 1 "no"
						extracted$ = selected$ ("Sound")
						sound_part = selected("Sound")

						select 'sound_part'
						To Formant (burg)... 0 number_formants maximum_formant window_length 50
						Rename... 'name$' beforetracking
						formant_beforetracking = selected("Formant")

						xx = Get minimum number of formants
						if xx > 3
						  Track... 4 'f1ref' 'f2ref' 'f3ref' 'f4ref' 'f5ref' 'freqcost' 'bwcost' 'transcost'
						elsif xx > 2
						  Track... 3 'f1ref' 'f2ref' 'f3ref' 'f4ref' 'f5ref' 'freqcost' 'bwcost' 'transcost'
						else
						  Track... 2 'f1ref' 'f2ref' 'f3ref' 'f4ref' 'f5ref' 'freqcost' 'bwcost' 'transcost'
						endif

						Rename... 'name$'_aftertracking
						formant_aftertracking = selected("Formant")
	
						for kounter from 1 to 'chunks'
							# Get the f1,f2,f3 measurements
							part = p_d/chunks
							ex_b = part*(kounter-1) + jitter
							ex_e = ex_b + part
	
							select 'formant_aftertracking'

							if extraction_method = 1
								f1 = Get mean... 1 ex_b ex_e Hertz
								f2 = Get mean... 2 ex_b ex_e Hertz
							else
								f1 = Get value at time... 1 ex_b+part/2 Hertz Linear
								f2 = Get value at time... 2 ex_b+part/2 Hertz Linear
							endif
	
							if xx > 3
								if extraction_method = 1
									f4 = Get mean... 4 ex_b ex_e Hertz
									f3 = Get mean... 3 ex_b ex_e Hertz
								else
									f4 = Get value at time... 4 ex_b+part/2 Hertz Linear
									f3 = Get value at time... 3 ex_b+part/2 Hertz Linear
								endif
							elsif xx > 2
								if extraction_method = 1
									f4 = 0
									f3 = Get mean... 3 ex_b ex_e Hertz
								else
									f4 = 0
									f3 = Get value at time... 3 ex_b+part/2 Hertz Linear
								endif
							else
								f4 = 0
								f3 = 0
							endif

							resultline$ = "'f1','f2','f3','f4',"
							fileappend "'resultfile$'" 'resultline$'
						endfor

						# Clear object window
						plus 'formant_beforetracking'
						plus 'sound_part'
						Remove
						
					endif

#---------------------- (3) Pitch ----------------------------------------------------------------------------------------
					if pitch = 1
						for kounter from 1 to 'chunks'
							part = p_d/chunks
							ex_b = part*(kounter-1) + jitter
							ex_e = ex_b + part

							select 'pitch_interpolated'
							if extraction_method = 1
								pitch_val = Get mean... p_b+part*(kounter-1) p_b+kounter*part Hertz
							else
								pitch_val = Get value at time... p_b+part*(2*kounter-1)/2 Hertz Linear
							endif

							if pitch_val = undefined
								pitch_val = 0
							endif

							resultline$ = "'pitch_val',"
							fileappend "'resultfile$'" 'resultline$'
						endfor
					endif

#---------------------- (4) Intensity ------------------------------------------------------------------------------------
					if intensity = 1
						for kounter from 1 to 'chunks'
							part = p_d/chunks
							ex_b = part*(kounter-1) + jitter
							ex_e = ex_b + part

							select 'intensity_tracking'
							if extraction_method = 1
								int = Get mean... p_b+part*(kounter-1) p_b+kounter*part dB
							else
								int = Get value at time... p_b+part*(2*kounter-1)/2 Cubic
							endif

							resultline$ = "'int',"
							fileappend "'resultfile$'" 'resultline$'
						endfor
					endif
				

#---------------------- (5) H1minusH2 ------------------------------------------------------------------------------
					if h1minusH2 = 1
						# Extract a part
						select 'sound_resampled'
						# Add jitter for accurate formant tracking
						jitter = 0.2

						Extract part... p_b-jitter p_e+jitter "rectangular" 1 "no"
						extracted$ = selected$ ("Sound")
						sound_part= selected("Sound")

						select 'sound_part'
						To Formant (burg)... 0 number_formants maximum_formant window_length 50
						Rename... 'name$' beforetracking
						formant_beforetracking = selected("Formant")

						xx = Get minimum number of formants
						if xx > 3
						  Track... 4 'f1ref' 'f2ref' 'f3ref' 'f4ref' 'f5ref' 'freqcost' 'bwcost' 'transcost'
						elsif xx > 2
						  Track... 3 'f1ref' 'f2ref' 'f3ref' 'f4ref' 'f5ref' 'freqcost' 'bwcost' 'transcost'
						else
						  Track... 2 'f1ref' 'f2ref' 'f3ref' 'f4ref' 'f5ref' 'freqcost' 'bwcost' 'transcost'
						endif

						Rename... 'name$'_aftertracking
						formant_aftertracking = selected("Formant")

						for kounter from 1 to 'chunks'
							# Get the f1,f2,f3 measurements
							part = p_d/chunks
							ex_b = part*(kounter-1) + jitter
							ex_e = ex_b + part
							select 'sound_part'
							Extract part...  'ex_b' 'ex_e' Hanning 1 no
							Rename... 'name$'_slice
			 				sound_slice = selected("Sound") 
	
							select 'formant_aftertracking'

							if extraction_method = 1
								f1 = Get mean... 1 ex_b ex_e Hertz
								f2 = Get mean... 2 ex_b ex_e Hertz
							else
								f1 = Get value at time... 1 ex_b+part/2 Hertz Linear
								f2 = Get value at time... 2 ex_b+part/2 Hertz Linear
							endif
	
							if xx > 3
								if extraction_method = 1
									f4 = Get mean... 4 ex_b ex_e Hertz
									f3 = Get mean... 3 ex_b ex_e Hertz
								else
									f4 = Get value at time... 4 ex_b+part/2 Hertz Linear
									f3 = Get value at time... 3 ex_b+part/2 Hertz Linear
								endif
							elsif xx > 2
								if extraction_method = 1
									f4 = 0
									f3 = Get mean... 3 ex_b ex_e Hertz
								else
									f4 = 0
									f3 = Get value at time... 3 ex_b+part/2 Hertz Linear
								endif
							else
								f4 = 0
								f3 = 0
							endif

							# Get F0
							select 'pitch_interpolated'
							if extraction_method = 1
								pitch_val = Get mean... p_b+part*(kounter-1) p_b+kounter*part Hertz
							else
								pitch_val = Get value at time... p_b+part*(2*kounter-1)/2 Hertz Linear
							endif

							if pitch_val = undefined
								pitch_val = 0
							endif

							# Get H1-H2
							select 'sound_slice'
							To Spectrum (fft)
							spectrum = selected("Spectrum")
							To Ltas (1-to-1)
							ltas = selected("Ltas")

							if pitch_val <> undefined  
							  p10_nf0md = 'pitch_val' / 10
							  select 'ltas'
							  lowerbh1 = 'pitch_val' - 'p10_nf0md'
							  upperbh1 = 'pitch_val' + 'p10_nf0md'
							  lowerbh2 = ('pitch_val' * 2) - ('p10_nf0md' * 2)
							  upperbh2 = ('pitch_val' * 2) + ('p10_nf0md' * 2)
							  h1db = Get maximum... 'lowerbh1' 'upperbh1' None
							  #h1hz = Get frequency of maximum... 'lowerbh1' 'upperbh1' None
							  h2db = Get maximum... 'lowerbh2' 'upperbh2' None
							  #h2hz = Get frequency of maximum... 'lowerbh2' 'upperbh2' None
							  #rh1hz = round('h1hz')
							  #rh2hz = round('h2hz')

							# Calculate potential voice quality correlates.
							   h1mnh2 = 'h1db' - 'h2db'
							else
								h1mnh2 = 0
							endif

							resultline$ = "'h1mnh2',"
							fileappend "'resultfile$'" 'resultline$'

							select 'ltas'
							plus 'spectrum'
							plus 'sound_slice'
							Remove
						endfor

						# Clear object window
						select 'formant_aftertracking'
						plus 'formant_beforetracking'
						plus 'sound_part'
						Remove
					endif

#---------------------- (6) H1minusA1 & H1minusA2 & H1minusA3 ------------------------------------------------
					if h1minusA1_H1minusA2_H1minusA3 = 1
						# Extract a part
						select 'sound_resampled'
						# Add jitter for accurate formant tracking
						jitter = 0.2

						Extract part... p_b-jitter p_e+jitter "rectangular" 1 "no"
						extracted$ = selected$ ("Sound")
						sound_part= selected("Sound")

						select 'sound_part'
						To Formant (burg)... 0 number_formants maximum_formant window_length 50
						Rename... 'name$' beforetracking
						formant_beforetracking = selected("Formant")

						xx = Get minimum number of formants
						if xx > 3
						  Track... 4 'f1ref' 'f2ref' 'f3ref' 'f4ref' 'f5ref' 'freqcost' 'bwcost' 'transcost'
						elsif xx > 2
						  Track... 3 'f1ref' 'f2ref' 'f3ref' 'f4ref' 'f5ref' 'freqcost' 'bwcost' 'transcost'
						else
						  Track... 2 'f1ref' 'f2ref' 'f3ref' 'f4ref' 'f5ref' 'freqcost' 'bwcost' 'transcost'
						endif

						Rename... 'name$'_aftertracking
						formant_aftertracking = selected("Formant")

						for kounter from 1 to 'chunks'
							# Get the f1,f2,f3 measurements
							part = p_d/chunks
							ex_b = part*(kounter-1) + jitter
							ex_e = ex_b + part
							select 'sound_part'
							Extract part...  'ex_b' 'ex_e' Hanning 1 no
							Rename... 'name$'_slice
			 				sound_slice = selected("Sound") 
	
							select 'formant_aftertracking'

							if extraction_method = 1
								f1 = Get mean... 1 ex_b ex_e Hertz
								f2 = Get mean... 2 ex_b ex_e Hertz
							else
								f1 = Get value at time... 1 ex_b+part/2 Hertz Linear
								f2 = Get value at time... 2 ex_b+part/2 Hertz Linear
							endif
	
							if xx > 3
								if extraction_method = 1
									f4 = Get mean... 4 ex_b ex_e Hertz
									f3 = Get mean... 3 ex_b ex_e Hertz
								else
									f4 = Get value at time... 4 ex_b+part/2 Hertz Linear
									f3 = Get value at time... 3 ex_b+part/2 Hertz Linear
								endif
							elsif xx > 2
								if extraction_method = 1
									f4 = 0
									f3 = Get mean... 3 ex_b ex_e Hertz
								else
									f4 = 0
									f3 = Get value at time... 3 ex_b+part/2 Hertz Linear
								endif
							else
								f4 = 0
								f3 = 0
							endif

							# Get F0
							select 'pitch_interpolated'
							if extraction_method = 1
								pitch_val = Get mean... p_b+part*(kounter-1) p_b+kounter*part Hertz
							else
								pitch_val = Get value at time... p_b+part*(2*kounter-1)/2 Hertz Linear
							endif

							if pitch_val = undefined
								pitch_val = 0
							endif

							# Get H1-H2
							select 'sound_slice'
							To Spectrum (fft)
							spectrum = selected("Spectrum")
							To Ltas (1-to-1)
							ltas = selected("Ltas")

							if pitch_val <> undefined  
							  p10_nf0md = 'pitch_val' / 10
							  select 'ltas'
							  lowerbh1 = 'pitch_val' - 'p10_nf0md'
							  upperbh1 = 'pitch_val' + 'p10_nf0md'
							  lowerbh2 = ('pitch_val' * 2) - ('p10_nf0md' * 2)
							  upperbh2 = ('pitch_val' * 2) + ('p10_nf0md' * 2)
							  h1db = Get maximum... 'lowerbh1' 'upperbh1' None
							  h1hz = Get frequency of maximum... 'lowerbh1' 'upperbh1' None
							  h2db = Get maximum... 'lowerbh2' 'upperbh2' None
							  h2hz = Get frequency of maximum... 'lowerbh2' 'upperbh2' None
							  rh1hz = round('h1hz')
							  rh2hz = round('h2hz')

							# Get the a1, a2, a3 measurements.
							  p10_f1hzpt = 'f1' / 10
							  p10_f2hzpt = 'f2' / 10
							  p10_f3hzpt = 'f3' / 10
							  lowerba1 = 'f1' - 'p10_f1hzpt'
							  upperba1 = 'f1' + 'p10_f1hzpt'
							  lowerba2 = 'f2' - 'p10_f2hzpt'
							  upperba2 = 'f2' + 'p10_f2hzpt'
							  lowerba3 = 'f3' - 'p10_f3hzpt'
							  upperba3 = 'f3' + 'p10_f3hzpt'
							  a1db = Get maximum... 'lowerba1' 'upperba1' None
							  a1hz = Get frequency of maximum... 'lowerba1' 'upperba1' None
							  a2db = Get maximum... 'lowerba2' 'upperba2' None
			  				  a2hz = Get frequency of maximum... 'lowerba2' 'upperba2' None
							  a3db = Get maximum... 'lowerba3' 'upperba3' None
							  a3hz = Get frequency of maximum... 'lowerba3' 'upperba3' None

							# Calculate potential voice quality correlates.
							   h1mna1 = 'h1db' - 'a1db'
							   h1mna2 = 'h1db' - 'a2db'
							   h1mna3 = 'h1db' - 'a3db'
							else
								h1mna1 = 0
								h1mna2 = 0
								h1mna3 = 0
							endif

							resultline$ = "'h1mna1','h1mna2','h1mna3',"
							fileappend "'resultfile$'" 'resultline$'

							select 'ltas'
							plus 'spectrum'
							plus 'sound_slice'
							Remove
						endfor

						# Clear object window
						select 'formant_aftertracking'
						plus 'formant_beforetracking'
						plus 'sound_part'
						Remove
					endif

#---------------------- (7) standard deviation, skewness, kurtosis, center of gravity -----------------------------
					if sd_skewness_kurtosis_COG = 1
						# Extract a part
						select 'sound_resampled'
						# Add jitter for accurate formant tracking
						jitter = 0.2

						Extract part... p_b-jitter p_e+jitter "rectangular" 1 "no"
						extracted$ = selected$ ("Sound")
						sound_part= selected("Sound")

						for kounter from 1 to 'chunks'
							part = p_d/chunks
							ex_b = part*(kounter-1) + jitter
							ex_e = ex_b + part
							select 'sound_part'
							Extract part...  'ex_b' 'ex_e' Hanning 1 no
							Rename... 'name$'_slice
			 				sound_slice = selected("Sound") 

							select 'sound_slice'
							To Spectrum (fft)
							spectrum = selected("Spectrum")

							grav = Get centre of gravity... 2
							sdev = Get standard deviation... 2
							skew = Get skewness... 2
							kurt = Get kurtosis... 2

							resultline$ = "'sdev','skew','kurt','grav',"
							fileappend "'resultfile$'" 'resultline$'

							select 'spectrum'
							plus 'sound_slice'
							Remove
						endfor
						select 'sound_part'
						Remove
					endif

					# Make sure the measurements begin from the next line, not from the header
					fileappend "'resultfile$'" 'newline$'

				endif
				
				# Update phone set for next loop
				ph_set$ = mid$(ph_set$,commaLoc+1,ph_set_length-commaLoc)
				iPhone = iPhone + 1
			endwhile
		endfor
	endif
	
	file_counting = file_counting + 1
	date$ = date$()
	printline FileNum:'file_counting' / 'num_files' 'date$' 'directory$''name$' ... done

	# Clear object window
	select all
	minus Strings sound_list
	minus Strings textgrid_list
	Remove

endfor

select all
Remove

#------------------------------------------------------------------------------------------------------------------------
			endif
#------------------------------------------------------------------------------------------------------------------------


######################################################################################
######################################  Wrap up  #######################################
######################################################################################


enddate$ = date$()
printline All completed!'newline$'
printline Started at 'startdate$'
printline Ended at 'enddate$'




