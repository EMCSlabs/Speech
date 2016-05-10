function phones = graph2phone(graphemes)
% This script converts input graphemes(Korean/English) to
% output phones(English/Korean) in both ways
%
% usage1: phones = GRAPH2PHONE('aanf-nnyvng p0aanf-k0aa-wv')
% usage2: phones = GRAPH2PHONE(/Korean words/)
%
% 2015-10-24
% 2016-01-15: check for special characters

if nargin < 1
    eval('help graph2phone')
end

%% Check characters
exp = '[.,;:''"{}\|/?!@#$%^&*()_+=]';
regIdx = regexp(graphemes,exp);
if ~isempty(regIdx)
   error(sprintf('Your graphemes contain special characters\nPlease remove them first')) 
end

%% phone list

global ONS NUC COD
ONS = {'k0', 'kk', 'nn', 't0', 'tt', 'rr', 'mm', 'p0', 'pp', 's0', 'ss', 'oh', 'c0', 'cc', 'ch', 'kh', 'th', 'ph', 'hh'};
NUC = {'aa', 'qq', 'ya', 'yq', 'vv', 'ee', 'yv', 'ye', 'oo', 'wa', 'wq', 'wo', 'yo', 'uu', 'wv', 'we', 'wi', 'yu', 'xx', 'xi', 'ii'};
COD = {'' 'kf', 'kk', 'ks', 'nf', 'nc', 'nh', 'tf', 'll', 'lk', 'lm', 'lb', 'ls', 'lt', 'lp', 'lh', 'mf', 'pf', 'ps', 's0', 'ss', 'oh', 'c0', 'ch', 'kh', 'th', 'ph', 'hh'};

% For more detail about unicode conversion, read this page:
% http://warmz.tistory.com/717

%% execute function
korbase = 44032;
korend = 55199;
engbase = 97;
engend = 122;
if double(graphemes(1)) >= korbase && double(graphemes(1)) <= korend
    phones = kor2eng(graphemes);
elseif double(graphemes(1)) >= engbase && double(graphemes(1)) <= engend
    phones = eng2kor(graphemes);
elseif double(graphemes(1)) == 32
    error('Only single space ('' '') was put as an input or the string starts with space')
else
    error('Input is not either Korean or English or the format is wrong')
end

%% Korean to English
    function eng = kor2eng(kor)
        n = double(kor);
        eng = '';
        idx = (n ~= 32); % non-space index
        k = 1;
        while k <= length(n)
            if idx(k) == 1
                df = n(k) - korbase;
                iONS = floor(df/588)+1;
                iNUC = floor(mod(df, 588)/28)+1;
                iCOD = mod(mod(df, 588), 28)+1;
                
                s1 = ['-' ONS{iONS}]; s2 = [NUC{iNUC}];
                if ~isempty(COD{iCOD})
                    s3 = [COD{iCOD}];
                else
                    s3 = '';
                end
                tmp = [s1 s2 s3];
                eng = [eng tmp];
                
            elseif idx(k) == 0
                tmp = ' ';
                eng = [eng tmp];
            end
            eng = regexprep(eng,'-(oh)','-');
            k = k + 1;
            tmp = [];
        end
        
        if length(eng) > 1
            eng = eng(2:end);
        end
        eng = regexprep(eng,'\s\-',' ');
        
        eng = regexprep(eng,'^oh','');
        eng = regexprep(eng,'-(oh)','-');
        eng = regexprep(eng,'oh(-)','ng-');
        eng = regexprep(eng,'oh$','ng');
        eng = regexprep(eng,'oh ','ng ');
    end

%% English to Korean
    function kor = eng2kor(eng)
        n = eng;
        idx = (n == 32);    % space index
        sylBeg = unique(sort([1,regexp(n,'-')+1,find(idx),find(idx)+1])); % syllable initial index with space idx
        sylEnd = unique(sort([regexp(n,'-')-1,find(idx),find(idx)-1,length(n)])); % syllable end index with space idx
        sylBeg(max(sylEnd) < sylBeg) = [];
        ucFunc = @(x,y,z) 44032 + ((x*588) + (y*28) + z); % define unicode conversion function
                 % x for onset
                 % y for nucleus
                 % z for coda
        
        kor = [];
        for i = 1:length(sylBeg)
            ss = n(sylBeg(i):sylEnd(i));
            switch length(ss)
                case 1    % space
                    syl = ' ';
                    kor = [kor syl];
                case 2    % NUC
                    val = find(~cellfun(@isempty,regexp(NUC,ss)))-1;
                    syl = char(ucFunc(11,val,0));
                    kor = [kor syl];
                case 4    % {ONC + NUC, NUC + COD}
                    s1 = ss(1:2);
                    s2 = ss(3:4);
                    val1 = find(~cellfun(@isempty,regexp(ONS,s1)))-1;
                    if ~isempty(val1) % ONC + NUC
                        val2 = find(~cellfun(@isempty,regexp(NUC,s2)))-1;
                        syl = char(ucFunc(val1,val2,0));
                        kor = [kor syl];
                    else  % NUC + COD
                        val1 = find(~cellfun(@isempty,regexp(NUC,s1)))-1;
                        val2 = find(~cellfun(@isempty,regexp(COD,s2)))-1;
                        syl = char(ucFunc(11,val1,val2));
                        kor = [kor syl];
                    end
                case 6    % ONC + NUC + COD
                    s1 = ss(1:2);
                    s2 = ss(3:4);
                    s3 = ss(5:6);
                    val1 = find(~cellfun(@isempty,regexp(ONS,s1)))-1;
                    val2 = find(~cellfun(@isempty,regexp(NUC,s2)))-1;
                    val3 = find(~cellfun(@isempty,regexp(COD,s3)))-1;
                    if isempty(val3) % if coda is velar nasal
                        val3 = 21;
                    end
                    syl = char(ucFunc(val1,val2,val3));
                    kor = [kor syl];
            end
        end
    end

end