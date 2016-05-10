function out = orthoAlign(seq1_origin, seq2_origin)

% This script align orthograph tier with phone tier in Seoul Corpus

%%%%%%%% prerequisite %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Bioinformatics toolbox should be installed!!
%
%%%%%%%% example inputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% seq1_origin = 'p0vv-nnaa-kkuu-yv';  % phones
% seq2_origin = 'p0yvnn-hhEEss-k0oo-yo'; % phonemes
% out will be 'p0yvnnEEk0ooyo'; % new phones
%
% edited 2015-4-20 JK
%
%%%%%%%%% minor problems: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (1) if seq1_origin = 'aamm' & seq2_origin = 'hhaann', then out = 'aamm'
%     ('mm' and 'nn' doesn't have association bar, but for other cases it has
%      due to the protein coding problem)
%
% (2) if seq1_origin = 'EE-nnii-phaa-iimm' & seq2_origin = 'EE-nnii-phaang-ee', then out = 'EEnniiphaaiimm'
%     'ii' should be changed to 'ee'
%
%     please keep recording of any problem you encounter here
%       - For this case, ortho2align('s0xx-mmuull-llee','s0xx-mmuull-nnee')
%         output comes as 's0xxmmuullllee'. Final 'll' should be 'nn'.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 1
    eval('help orthoAlign')
    return
end


AA = {'A', 'R', 'N', 'D', 'C', 'Q', 'E', 'G', 'H', 'I', 'L', 'K', 'M', 'F', 'P', 'S', 'T', 'W', 'Y', 'V', 'B', 'z', '*', '-', '?'};

seq1_long = length(regexp(seq1_origin,'-'));
seq2_long = length(regexp(seq2_origin,'-'));

seq1_rev = regexprep(seq1_origin, '-', '');
seq2_rev = regexprep(seq2_origin, '-', '');

if seq1_long == seq2_long % if seq1 and seq2 have the same num of sylls, continue.
    
    seq1 = seq1_origin;
    seq2 = seq2_origin;
    
    seq1 = regexprep(seq1, '(ii|ee|EE|aa|xx|vv|uu|oo)', 'VV'); % monophthong replacement
    seq1 = regexprep(seq1, '(ye|YE|ya|yv|yo|yu|wi|we|wE|WE|wa|wv|xi|xx)', 'VV'); % diphthong replacement
    seq1 = regexprep(seq1, 'hh', 'qq'); % consonant replacement
    seq1 = regexprep(seq1, 'ph', 'pp'); % consonant replacement
    seq1 = regexprep(seq1, 'kh', 'kk'); % consonant replacement
    seq1 = regexprep(seq1, 'ks', 'kk'); % consonant replacement
    seq1 = regexprep(seq1, 'th', 'tt'); % consonant replacement
    seq1 = regexprep(seq1, 'p0', 'pp'); % consonant replacement
    seq1 = regexprep(seq1, 'k0', 'kk'); % consonant replacement
    seq1 = regexprep(seq1, 't0', 'tt'); % consonant replacement
    seq1 = regexprep(seq1, 's0', 'ss'); % consonant replacement
    seq1 = regexprep(seq1, 'c0', 'cc'); % consonant replacement
    seq1 = regexprep(seq1, 'ch', 'cc'); % consonant replacement
    seq1 = regexprep(seq1, 'nh', 'nn'); % complex consonant replacement
    seq1 = regexprep(seq1, 'nc', 'nn'); % complex consonant replacement
    seq1 = regexprep(seq1, 'ps', 'pp'); % complex consonant replacement
    seq1 = regexprep(seq1, 'ng', 'nn'); % complex consonant replacement
    seq1 = regexprep(seq1, 'lp', 'll'); % complex consonant replacement
    seq1 = regexprep(seq1, 'lm', 'll'); % complex consonant replacement
    seq1 = regexprep(seq1, 'lT', 'll'); % complex consonant replacement
    seq1 = regexprep(seq1, 'lh', 'll'); % complex consonant replacement
    seq1 = regexprep(seq1, 'lk', 'll'); % complex consonant replacement
    seq1 = regexprep(seq1, '-', '');
    
    seq2 = regexprep(seq2, '(ii|ee|EE|aa|xx|vv|uu|oo)', 'VV'); % monophthong replacement
    seq2 = regexprep(seq2, '(ye|YE|ya|yv|yo|yu|wi|we|wE|WE|wa|wv|xi|xx)', 'VV'); % diphthong replacement
    seq2 = regexprep(seq2, 'hh', 'qq'); % consonant replacement
    seq2 = regexprep(seq2, 'ph', 'pp'); % consonant replacement
    seq2 = regexprep(seq2, 'kh', 'kk'); % consonant replacement
    seq2 = regexprep(seq2, 'ks', 'kk'); % consonant replacement
    seq2 = regexprep(seq2, 'th', 'tt'); % consonant replacement
    seq2 = regexprep(seq2, 'p0', 'pp'); % consonant replacement
    seq2 = regexprep(seq2, 'k0', 'kk'); % consonant replacement
    seq2 = regexprep(seq2, 't0', 'tt'); % consonant replacement
    seq2 = regexprep(seq2, 's0', 'ss'); % consonant replacement
    seq2 = regexprep(seq2, 'c0', 'cc'); % consonant replacement
    seq2 = regexprep(seq2, 'ch', 'cc'); % consonant replacement
    seq2 = regexprep(seq2, 'nh', 'nn'); % complex consonant replacement
    seq2 = regexprep(seq2, 'nc', 'nn'); % complex consonant replacement
    seq2 = regexprep(seq2, 'ps', 'pp'); % complex consonant replacement
    seq2 = regexprep(seq2, 'ng', 'nn'); % complex consonant replacement
    seq2 = regexprep(seq2, 'lp', 'll'); % complex consonant replacement
    seq2 = regexprep(seq2, 'lm', 'll'); % complex consonant replacement
    seq2 = regexprep(seq2, 'lT', 'll'); % complex consonant replacement
    seq2 = regexprep(seq2, 'lh', 'll'); % complex consonant replacement
    seq2 = regexprep(seq2, 'lk', 'll'); % complex consonant replacement
    seq2 = regexprep(seq2, '-', '');
    
    n = 0;
    for i=1:2:length(seq1)-1
        n=n+1;
        ph1{n} = seq1(i:i+1);
    end
    n_ph1 = length(ph1);
    
    n = 0;
    for i=1:2:length(seq2)-1
        n=n+1;
        ph2{n} = seq2(i:i+1);
    end
    n_ph2 = length(ph2);
    
    ph_unique = unique([ph1 ph2]);
    
    for i = 1:n_ph1
        m1(i) = regexpcell(ph_unique, ph1{i});
        s1(i) = AA{m1(i)};
    end
    
    for i = 1:n_ph2
        m2(i) = regexpcell(ph_unique, ph2{i});
        s2(i) = AA{m2(i)};
    end
    
    [Score, Alignment] = nwalign(s1, s2);
    idx_t = strfind(Alignment(1,:),'-'); % top
    idx_m = strfind(Alignment(2,:),' '); % middle
    idx_b = strfind(Alignment(3,:),'-'); % bottom
    idx_bar = regexp(Alignment(2,:),'[|:]'); % bar and colon
    
    out = [];
    k = 1; % length of Alignment(1,:)
    i = 1; % length of phone
    n = 1; % length of ortho
    until = length(Alignment(1,:));
    while k <= until
        if sum(idx_t == k) == 1
            out = out;
            n = n + 1;
        elseif sum(idx_t == k) == 0 && sum(idx_bar == k) == 1
            out = [out seq2_rev(n*2-1:n*2)];
            i = i + 1;
            n = n + 1;
        elseif sum(idx_t == k) == 0 && sum(idx_bar == k) == 0 && sum(idx_b == k) == 0
            out = [out seq2_rev(i*2-1:i*2)];
            i = i + 1;
            n = n + 1;
        elseif sum(idx_t == k) == 0 && sum(idx_bar == k) == 0 && sum(idx_b == k) == 1
            out = [out seq1_rev(i*2-1:i*2)];
            i = i + 1;
        end
        k = k + 1;
    end
    
else
    
    % if seq1 and seq2 have different num of sylls, do not change anything.
    out = seq1_rev;
    
end


function cellIdx = regexpcell(cellArray,expression)
is_a_match = ~cellfun(@isempty,regexp(cellArray,expression));
cellIdx = find(is_a_match);