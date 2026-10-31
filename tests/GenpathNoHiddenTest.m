classdef GenpathNoHiddenTest < matlab.unittest.TestCase
    % MATLAB's test framework does not support arguments blocks on test methods.
    properties (Access = private)
        rootFolder
    end

    methods (TestMethodSetup)
        function createFolderTree(testCase)
            fixture = testCase.applyFixture( ...
                matlab.unittest.fixtures.TemporaryFolderFixture);
            testCase.rootFolder = fixture.Folder;
            projectFolder = fileparts(fileparts(mfilename('fullpath')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(projectFolder));

            folders = {fullfile('alpha', 'child'), 'empty', 'with spaces', 'v1.2', ...
                fullfile('.git', 'objects'), fullfile('.hidden', 'visible'), ...
                fullfile('alpha', '.nested', 'visible'), fullfile('...', 'visible'), ...
                fullfile('..hidden', 'visible'), fullfile('private', 'visible'), ...
                fullfile('resources', 'visible'), fullfile('+package', 'visible'), ...
                fullfile('@ExampleClass', 'visible')};
            for folderIndex = 1:numel(folders)
                [status, message] = mkdir(fullfile(testCase.rootFolder, folders{folderIndex}));
                testCase.assertTrue(logical(status), message);
            end
        end
    end

    methods (Test)
        function excludesHiddenFoldersAndPreservesGenpathOrder(testCase)
            root = testCase.rootFolder;
            expected = strjoin({root, fullfile(root, 'alpha'), ...
                fullfile(root, 'alpha', 'child'), fullfile(root, 'empty'), ...
                fullfile(root, 'v1.2'), fullfile(root, 'with spaces'), ''}, pathsep);
            testCase.verifyEqual(genpathNoHidden(root), expected);
            testCase.verifyEqual(genpathNoHidden(string(root)), expected);
            testCase.verifyClass(genpathNoHidden(root), 'char');
        end

        function matchesGenpathForVisibleAndEmptyFolders(testCase)
            folders = {'empty', 'v1.2', 'with spaces'};
            for folderIndex = 1:numel(folders)
                folder = fullfile(testCase.rootFolder, folders{folderIndex});
                testCase.verifyEqual(genpathNoHidden(folder), genpath(folder));
            end
        end

        function preservesRelativeReferences(testCase)
            testCase.applyFixture( ...
                matlab.unittest.fixtures.CurrentFolderFixture(testCase.rootFolder));
            folders = {fullfile('.', 'empty'), fullfile('alpha', '..', 'empty')};
            for folderIndex = 1:numel(folders)
                testCase.verifyEqual(genpathNoHidden(folders{folderIndex}), ...
                    genpath(folders{folderIndex}));
            end
        end

        function excludesHiddenRootsAndAncestors(testCase)
            testCase.verifyEqual(genpathNoHidden( ...
                fullfile(testCase.rootFolder, '.hidden')), '');
            testCase.verifyEqual(genpathNoHidden( ...
                fullfile(testCase.rootFolder, '.hidden', 'visible')), '');
        end

        function handlesEmptyAndMissingInputs(testCase)
            testCase.verifyEqual(genpathNoHidden(''), genpath(''));
            testCase.verifyEqual(genpathNoHidden(""), genpath(""));
            testCase.verifyEqual(genpathNoHidden( ...
                fullfile(testCase.rootFolder, 'missing')), '');
        end

        function rejectsNonScalarAndNonTextInputs(testCase)
            testCase.verifyError(@() genpathNoHidden(["a", "b"]), ...
                'MATLAB:validators:mustBeTextScalar');
            testCase.verifyError(@() genpathNoHidden(42), ...
                'MATLAB:validators:mustBeTextScalar');
        end
    end
end
