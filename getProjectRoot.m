function projectRoot = getProjectRoot()
%GETPROJECTROOT Returns the root of the current project.

    proj = matlab.project.rootProject;
    projectRoot = proj.RootFolder;

end