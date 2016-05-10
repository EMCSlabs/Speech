
form Change tier names
	comment Directory of input files (Textgrid)
	text Directory /Users/jaegukang/Desktop/tmp/SeoulCorpus/sound/
	comment Tier names:
	comment 2nd Tier
	text tier2 pWord.Kprono
	comment 3rd Tier
	text tier3 pWord.Eprono
	comment 4th Tier
	text tier4 utt.prono
	comment 5th Tier
	text tier5 pWord.Kortho
	comment 6th Tier
	text tier6 pWord.Eortho
	comment 7th Tier
	text tier7 utt.ortho
endform

# Create string
Create Strings as file list... textgrid_list 'directory$'*.TextGrid

# Read files
select Strings textgrid_list
numFiles = Get number of strings

for ifile from 1 to numFiles
	select Strings textgrid_list
	name$ = Get string... ifile
	Read from file... 'directory$''name$'

	textgrid = selected("TextGrid")
	select 'textgrid'
	Set tier name... 2 'tier2$'
	Set tier name... 3 'tier3$'
	Set tier name... 4 'tier4$'
	Set tier name... 5 'tier5$'
	Set tier name... 6 'tier6$'
	Set tier name... 7 'tier7$'
	Save as short text file... 'directory$''name$'
	Remove
endfor









