##########################################
#
#	Extractor (ver. 3)
#
#	This script extracts Pitch, F1, F2, F3, Intensity with various durational information including
#	phoneme duration, word duration and utterance duration.
#	WIth specified chunks, this script searches through all the vowels (specified ^[aeiouvxyw]) and 
#	calculates Pitch, F1, F2, F3 and Intensity iteratively.
#	
#	(1) Place .wav and .textgrid into the same folder
# 	(2) Open script and check the parameters (e.g. directory, chunk, reference formant values)
#	(3) Run script
#	(4) Check output in the result txt file.
#
#	Made by Jaegu Kang (2015-3-28)
#
#	- Accurate formant tracking by adding jitter(0.2) -> you can change the value
#	- Sound extraction function needs to be examined later
#	- Phonemes including <LAUGH> were deleted e.g. <LAUGH-요>
#	- Object window gets cleared in every loop to less burden the memory
#
##########################################

#####Start of the script#####

form Extractor
	comment Directory of input files (.wav & .textgrid):
	text Directory /Users/jaegukang/Desktop/tmp/corpus_practice/
	comment Full path of the resulting text file:
	text Resultfile /Users/jaegukang/Desktop/tmp/corpus_practice/scripts/result.txt
	comment Divide vowel into how many chunks:
	integer Chunk 6
	comment Formant Settings:
   	positive Window_length 0.025
   	positive Maximum_formant 5500
   	positive Number_formants 5
   	positive Number_tracks 3
   	positive F1ref 500
   	positive F2ref 1485
   	positive F3ref 2450
   	positive F4ref 3550
   	positive F5ref 4650
endform
# Set values needed for formant extraction
# right_Frequency_cost = 1
freqcost = 1
# right_Bandwidth_cost = 1
bwcost = 1
# right_Transition_cost = 1
transcost = 1
# formant maximun
maxf = 5500

# Create Strings of file list from the directory
Create Strings as file list... sound_list 'directory$'*.wav
Create Strings as file list... textgrid_list 'directory$'*.TextGrid

# Check if the result file exists:
if fileReadable (resultfile$)
	pause The result file already exists! Do you want to overwrite it?
	filedelete 'resultfile$'
endif

# Header for result file
titleline$ = "Filename,Pre_phone,Phoneme,Post_phone,Phone_beg,Phone_end,Phone_dur,kWord_prono,eWord_prono,kWord_ortho,eWord_ortho,Utt_prono,Utt_ortho,Word_beg,Word_end,Word_dur,Utt_beg,Utt_end,Utt_dur"
fileappend "'resultfile$'" 'titleline$'
# Add headers for chunks
for k from 1 to chunk
	k$ = string$(k)
	titleline$ = ",Pitch_ch"+k$+",F1_ch"+k$+",F2_ch"+k$+",F3_ch"+k$+",Intensity_ch"+k$
	fileappend "'resultfile$'" 'titleline$'
endfor
titleline$ = "'newline$'"
fileappend "'resultfile$'" 'titleline$'

# Read files
select Strings sound_list
num_files = Get number of strings

# Clear info window
clearinfo 

# Count setting
file_counting = 0

# Print start time
startdate$ = date$()
printline Extracting began at ... 'startdate$''newline$'

## Go through files one by one

for ifile from 1 to num_files
	select Strings sound_list
	name$ = Get string... ifile 
	Read from file... 'directory$''name$'

	## Open sound file

	wavname$ = selected$("Sound",1)
	Resample... 16000 50
	sound_resampled = selected("Sound")

	# Pitch tracking

	select 'sound_resampled'
	To Pitch... 0 60 350
	pitch = selected("Pitch")
	Interpolate
	Rename... 'name$'_interpolated
	pitch_interpolated = selected("Pitch")

	# Intensity tracking

	select 'sound_resampled'
	To Intensity... 10 0.0 yes
	intensity = selected("Intensity")	

	## Open textgrid file

	gridname$ = "'directory$''wavname$'.TextGrid"
	if fileReadable (gridname$)
		Read from file... 'gridname$'
		textgrid = selected("TextGrid")
		select 'textgrid'
		phone_labels = Get number of intervals... 1  
		word_labels = Get number of intervals... 2  
		utter_labels = Get number of intervals... 4  

		## Check phoneme tier

		for iLabel from 1 to phone_labels
			select 'textgrid'
			p_label$ = Get label of interval... 1 iLabel
			if (p_label$ <> "<IVER>") and (p_label$ <> "<SIL>") and (p_label$ <> "<VOCNOISE>") and (p_label$ <> "<LAUGH>") and (p_label$ <> "<NOISE>") and (p_label$ <> "<UNKNOWN>") and (p_label$ <> "<PRIVATE.INFO>") and (index_regex(p_label$,"LAUGH") = 0)
				
				# 1. Phoneme extraction

				p_b = Get starting point... 1 iLabel
		      		p_e = Get end point... 1 iLabel
		      		p_d = p_e - p_b
				p_m = p_b + p_d/2			

				# Add Pre & Post phoneme

				if iLabel = 1
				pre_phone$ = "Start"
				elsif iLabel = phone_labels
				post_phone$ = "End"
				elsif iLabel <> 1 and iLabel <> phone_labels
				pretime = iLabel-1
				posttime = iLabel+1
				pre_phone$ = Get label of interval... 1 pretime
				post_phone$ = Get label of interval... 1 posttime
				endif

				# 2. Word & Utterance extraction

				# kWord_prono
				inter_time = Get interval at time... 2 p_m
				kWord_prono$ = Get label of interval... 2 inter_time
				# eWord_prono
				inter_time = Get interval at time... 3 p_m
				eWord_prono$ = Get label of interval... 3 inter_time
				# kWord_ortho
				inter_time = Get interval at time... 5 p_m
				kWord_ortho$ = Get label of interval... 5 inter_time
				# eWord_ortho
				inter_time = Get interval at time... 6 p_m
				eWord_ortho$ = Get label of interval... 6 inter_time
				# Utt_prono
				inter_time = Get interval at time... 4 p_m
				utt_prono$ = Get label of interval... 4 inter_time
				# Utt_ortho
				inter_time = Get interval at time... 7 p_m
				utt_ortho$ = Get label of interval... 7 inter_time

				w_b = Get start point... 2 inter_time
				w_e = Get end point... 2 inter_time
				w_d = w_e - w_b
				w_m = w_b + w_d/2

				u_b = Get start point... 4 inter_time
				u_e = Get end point... 4 inter_time
				u_d = u_e - u_b
				u_m = u_b + u_d/2

				# Write result to txt file

				resultline$ = "'wavname$','pre_phone$','p_label$','post_phone$','p_b','p_e','p_d','kWord_prono$','eWord_prono$','kWord_ortho$','eWord_ortho$','utt_prono$','utt_ortho$','w_b','w_e','w_d','u_b','u_e','u_d'"
				fileappend "'resultfile$'" 'resultline$'

				# 3. Formant & Pitch & Intensity extraction

				select 'sound_resampled'
				#regex$ = "^[aeiouxvwy]"
				#if index_regex(p_label$,regex$) <> 0
				jitter = 0.2

				####This part needs to be reexamined(problem: the extracted part doesn't seem to recognize the time info of the original sound file)###
				Extract part... p_b-jitter p_e+jitter "rectangular" 1 "no"
				extracted$ = selected$ ("Sound")
				sound_part = selected("Sound")

				part_b = Get start time
				part_bt = part_b + jitter
				part_e = Get end time
				part_et = part_e - jitter
				part_d = part_e - part_b
				part_dt = part_et - part_bt

				To Formant (burg)... 0 number_formants maxf window_length 50
				Rename... 'name$' beforetracking
				formant_beforetracking = selected("Formant")

				xx = Get minimum number of formants
				if xx > 2
				  Track... 3 'f1ref' 'f2ref' 'f3ref' 'f4ref' 'f5ref' 'freqcost' 'bwcost' 'transcost'
				else
				  Track... 2 'f1ref' 'f2ref' 'f3ref' 'f4ref' 'f5ref' 'freqcost' 'bwcost' 'transcost'
				endif

				Rename... 'name$'_aftertracking
				formant_aftertracking = selected("Formant")
				
				# Vowels

				for kounter from 1 to 'chunk'
					part_seg = part_dt / chunk
					part_md = part_bt + ((kounter - 1) * part_seg) + (part_seg / 2)
					p_seg = p_d / chunk
					p_md = p_b + ((kounter - 1) * p_seg) + (p_seg / 2)

					# Get the f1,f2,f3 measurements

					select 'formant_aftertracking'
					f1 = Get value at time... 1 part_md Hertz Linear
					f2 = Get value at time... 2 part_md Hertz Linear
					
					if xx > 2
						f3 = Get value at time... 3 part_md Hertz Linear
						else
						f3 = 0
					endif
											
					# Get F0
					select 'pitch_interpolated'
					pitch = Get value at time... 'p_md' Hertz Linear

					# Get the intensity values at chunk boundaries

					select 'intensity'
					int = Get value at time... 'p_md' Cubic
						
					# Write result to txt file
					resultline$ = ",'pitch','f1','f2','f3','int'"
					fileappend "'resultfile$'" 'resultline$'
				endfor

				# Clear object window

				minus 'intensity'
				select 'formant_aftertracking'
				plus 'formant_beforetracking'
				plus 'sound_part'
				Remove

				# Write result to txt file

				fileappend "'resultfile$'" 'newline$'
			endif
		endfor
	endif
	file_counting = file_counting + 1
	date$ = date$()
	printline FileNum:'file_counting' 'date$' 'directory$''name$'

	# Clear object window

	select all
	minus Strings sound_list
	minus Strings textgrid_list
	Remove
endfor

select all
Remove

enddate$ = date$()
printline All completed!'newline$'
printline Started at 'startdate$'
printline Ended at 'enddate$'

#####End of the script#####
