%% setup.m
% Setup MATLAB path for internal solitary wave simulations

% Find project root directory (location of this file)
project_root = fileparts(mfilename('fullpath'));

% Add source code
src_path = fullfile(project_root, 'src');
addpath(genpath(src_path))

% Add DJLES
djles_path = fullfile(project_root, 'external', 'DJLES');
addpath(genpath(djles_path))

disp('MATLAB environment configured.')
disp('Source code and DJLES added to path.')