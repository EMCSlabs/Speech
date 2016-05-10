####### Extract total phoneme labels from seoul corpus

form phoneme extraction
	comment Directory of textgrid files:
	text Directory /Users/jaegukang/Desktop/tmp/SeoulCorpus/label/
	comment Result file:
	text Resultfile /Users/jaegukang/Desktop/tmp/SeoulCorpus/result.txt
	comment Tier number:
	integer Tier_number (e.g. 1)
endform

# Create Strings of file list from the directory
Create Strings as file list... textgrid_list 'directory$'*.TextGrid

# Header for result file
#titleline$ = "Filename,Phoneme"
#fileappend "'resultfile$'" 'titleline$''newline$'

# Read textgrid
select Strings textgrid_list
num_files = Get number of strings

# Clear info window
clearinfo 

# Count setting
file_counting = 0

# Extract phonemes iteratively
for ifile from 1 to num_files
	select Strings textgrid_list
	name$ = Get string... ifile
	Read from file... 'directory$''name$'
	selected = selected("TextGrid")
	num_interval = Get number of intervals... tier_number

	for i_interval from 1 to num_interval
		label$ = Get label of interval... tier_number i_interval
		resultline$ = "'name$','label$'"
		fileappend "'resultfile$'" 'resultline$''newline$'
	endfor
	Remove

	file_counting = file_counting + 1
	printline 'file_counting'
endfor
















