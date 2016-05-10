function [phones,prono] = graph2prono(graphemes)

% graph2prono
%
% This function converts (1) Korean grapheme into romanized orthography
% and (2) romanized orthography into Korean pronunication.
%   Input:
%   - graphemes: e.g. 'im-ni-da'(in Korean grapheme)
%   Output:
%   - phones: e.g. 'iip0-nnii-t0aa'
%   - prono: e.g. 'iimmnniit0aa'
%
% usage: [phones,prono] = graph2prono(graphemes)
%
% 2015-7-1 updated with new phones (e.g. wE -> w2)
% 2015-7-10 updated with new phones
%          (i.e. EE|e2 -> zz, YE|y2 -> yz, wE|w2 -> wo, WE|w3 -> wz)
% 2015-7-14 updated with changes
%          (i.e. zz -> qq, yz -> yq, wz -> wq)
%           space is included
% 2015-7-31 updated with changes
%          (i.e. onset ll -> rr, coda p0 -> pf, t0 -> tf, k0 -> kf
%           mm -> mf, nn -> nf)
%
% - ruleset.mat is based on two files:
% rules_G2p(2015.11.14).xls
% romanization_list(2015.7.29).xlsx

if nargin < 1
    eval('help graph2prono')
end

phones = '';

ONS = {'k0', 'kk', 'nn', 't0', 'tt', 'rr', 'mm', 'p0', 'pp', 's0', 'ss', 'oh', 'c0', 'cc', 'ch', 'kh', 'th', 'ph', 'hh'};
NUC = {'aa', 'qq', 'ya', 'yq', 'vv', 'ee', 'yv', 'ye', 'oo', 'wa', 'wq', 'wo', 'yo', 'uu', 'wv', 'we', 'wi', 'yu', 'xx', 'xi', 'ii'};
COD = {'' 'kf', 'kk', 'ks', 'nf', 'nc', 'nh', 'tf', 'll', 'lk', 'lm', 'lb', 'ls', 'lt', 'lp', 'lh', 'mf', 'pf', 'ps', 's0', 'ss', 'oh', 'c0', 'ch', 'kh', 'th', 'ph', 'hh'};

n = double(uint16(graphemes));
idx = n~=32;
k = 1;
while k <= length(n)
    if idx(k) == 1
        base = 44032;
        df = n(k) - base;
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
        phones = [phones tmp];
        
    elseif idx(k) == 0
        tmp = ' ';
        phones = [phones tmp];
    end
    phones = regexprep(phones,'-(oh)','-');
    k = k + 1;
    tmp = [];
end

% for i = 1:length(n)
%     base = 44032;
%     df = n(i) - base;
%     iONS = floor(df/588)+1;
%     iNUC = floor(mod(df, 588)/28)+1;
%     iCOD = mod(mod(df, 588), 28)+1;
%
%     s1 = ['-' ONS{iONS}]; s2 = [NUC{iNUC}];
%     if ~isempty(COD{iCOD})
%         s3 = [COD{iCOD}];
%     else
%         s3 = '';
%     end
%     phones = [phones  s1 s2 s3];
% end
if length(phones) > 1
    phones = phones(2:end);
end
phones = regexprep(phones,'\s\-',' ');

phones = regexprep(phones,'^oh','');
phones = regexprep(phones,'-(oh)','-');
phones = regexprep(phones,'oh-','ng-');
phones = regexprep(phones,'oh$','ng');
phones = regexprep(phones,'oh ','ng ');

% import ruleset
% try
%     R = evalin('base','R');
% catch err
%     error('ruleset.mat is not loaded. Please load it first.');
% end
try
    R = evalin('base','R');
catch err
    error('ruleset.mat is not loaded. Please load it first.');
end



% convert
for i = 1:length(R)
    if i == 1
        tmp = regexprep(phones,R{i,1},R{i,2});
    else
        tmp = regexprep(tmp,R{i,1},R{i,2});
    end
end
tmp = regexprep(tmp,'-','');
prono = tmp;

