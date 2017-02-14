% Run acoustics1.4.praat from command line
% 2017-02-14 jkang

praat_dir = '/Applications/Praat.app/Contents/MacOS/Praat';
script_dir = './acoustics1.4.praat';
data_dir = './example/'; % add slash at the end
result_dir = './example';

result_file = fullfile(result_dir,'result.txt');
log_dir = fullfile(result_dir,'timelog.txt');

which_tier = 1;
phones = 'aa,eh,iy,ow,uh'; % comma separated phones
all_phones = 1;
chunks = 3;
extraction_method = 'Averaged'; % or 'Point-wise'
extraction_without_textgrid = 0;
duration = 1;
formants = 1;
pitch = 0;
intensity = 0;
H1minusH2 = 0;
H1minusA1_H1minusA2_H1minusA3 = 0;
sd_skewness_kurtosis_COG = 0;

cmd = sprintf('%s %s %s %s %d %s %d %d %s %d %d %d %d %d %d %d %d',...
    praat_dir, script_dir, data_dir, result_file, which_tier,...
    phones, all_phones,...
    chunks, extraction_method, extraction_without_textgrid,...
    duration, formants, pitch, intensity,...
    H1minusH2, H1minusA1_H1minusA2_H1minusA3, sd_skewness_kurtosis_COG);

fid = fopen('log.txt','wt');
fprintf(fid,'Started at %s\n',datestr(datetime('now')));
unix(cmd); % run command
fprintf(fid,'Finished at %s\n',datestr(datetime('now')));
fclose(fid);




