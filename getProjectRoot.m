function projectRoot = getProjectRoot()
% getProjectPath - Returns the root of the current project.
    proj = matlab.project.rootProject;
    projectRoot = proj.RootFolder;
end