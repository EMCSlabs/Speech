function WritePraatTier(tierName,tierLabel,tierTime,fn_new)

% Textgrid file should be saved as short format first.
%
% Input arguments:
%   tierName: a string vector of tier name(s)
%   tierLabel: an array of new labels in each interval (e.g. output of
%   ReadPraatTier, 'labs')
%   tierTime: a Nx2 matrix of interval times (e.g. output of ReadPraatTier, 'segs')
%   fn_new: new file name (with extension)
%
% usage: WritePraatTier({'phone', 'word', 'utt'}, {labs_phone, labs_word, labs_utt}, {segs_phone, segs_word, segs_utt}, 'test.TextGrid')

warning off
format short

% help
if nargin < 1,
    eval('help WritePraatTier');
    return;
end;

% read textgrid
nTier = num2str(size(tierLabel, 2));
uttBegT = num2str(tierTime{1}(1,1),10);
uttEndT = num2str(tierTime{1}(end,2),10);
uttInit = {'File type = "ooTextFile short"', '"TextGrid"', '', uttBegT, uttEndT, '<exists>', nTier}';


AllTier = uttInit;
for n = 1:str2num(nTier)
    tierLength = num2str(length(tierLabel{n}));
    begT = num2str(tierTime{n}(1,1),10);
    endT = num2str(tierTime{n}(end,2),10);
    tierInit = {'"IntervalTier"' ; ['"' tierName{n} '"'] ; begT ; endT ; tierLength};
    
    % create a new tier
    tmp = [];
    Tier = [];
    for i = 1:length(tierLabel{n})
        tmp{1,1} = num2str(tierTime{n}(i,1),10);
        tmp{2,1} = num2str(tierTime{n}(i,2),10);
        tmp{3,1} = ['"' tierLabel{n}{i} '"'];
        Tier = [Tier ; tmp];
    end
    Tier = [tierInit; Tier];
    AllTier = [AllTier; Tier];
end

% write new textgrid
fid = fopen(fn_new,'wt','n','UTF-8'); % Praat doesn't read Korean in UTF-16 properly.
for i = 1:length(AllTier)
    fprintf(fid,'%s\n',AllTier{i});
end
fclose(fid);