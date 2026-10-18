function subdirs = getSubdirs(baseDir)
% subdirs = getSubdirs(baseDir) get a list of the specified base dir 
% subdirectories. Defaults is pwd.

    arguments
        baseDir (:, :) string = pwd;
    end

    dirList = dir;

    % Exclude relative refs and files
    dirList = dirList(~strcmp(string({dirList.name}), "."));
    dirList = dirList(~strcmp(string({dirList.name}), ".."));
    dirList = dirList([dirList.isdir]);

    subdirs = repelem(baseDir, numel(dirList), 1) + filesep + string({dirList.name})';
end