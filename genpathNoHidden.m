function pathString = genpathNoHidden(folder)
%GENPATHNOHIDDEN Generate a recursive MATLAB path without hidden folders.
%   P = GENPATHNOHIDDEN(FOLDER) accepts a character vector or string scalar
%   and returns GENPATH(FOLDER) with dot-prefixed folders and their descendants
%   removed. Relative path components '.' and '..' are preserved.
%   P = GENPATHNOHIDDEN uses the same default folder as GENPATH.
%   The output is a character row vector with GENPATH's order, exclusions,
%   and trailing path separator preserved. Missing folders return ''.

    arguments
        folder {mustBeTextScalar} = fullfile(matlabroot, 'toolbox')
    end

    if nargin == 0
        pathString = genpath();
    else
        pathString = genpath(folder);
    end

    if isempty(pathString)
        return
    end

    separator = regexptranslate('escape', filesep);
    % Match dot-prefixed components, except the relative references '.' and '..'.
    hiddenPattern = ['(^|' separator ')\.(?!\.?(' separator '|$))'];
    folders = strsplit(pathString, pathsep, 'CollapseDelimiters', false);
    isHidden = ~cellfun('isempty', regexp(folders, hiddenPattern, 'once'));
    pathString = strjoin(folders(~isHidden), pathsep);
end
