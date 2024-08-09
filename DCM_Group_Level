
%% DCM Level 2 Group Analysis
% Initializing SPM
spm_path = '/Users/greta/Desktop/spm12';
data_folder_path = '/Volumes/GRETA/DCM_project'; % Enter the root path of where your data is stored

% Add paths
addpath(spm_path);
addpath(data_folder_path);

spm('defaults', 'fmri');
spm_jobman('initcfg');

% Specifying data and participant paths
subject_folder = {'sub-002' , 'sub-003' , 'sub-004', 'sub-005', 'sub-006', 'sub-007', 'sub-008', 'sub-009', 'sub-010'};

% Group level output directory
group_output_dir = fullfile(data_folder_path, 'GroupLevelAnalysis');
if ~exist(group_output_dir, 'dir')
    mkdir(group_output_dir);
end

%% Step 1: GCM Specification

% Initialize the batch structure for DCM estimation
matlabbatch = cell(1,1);
matlabbatch{1}.spm.dcm.estimate.dcms = struct();
matlabbatch{1}.spm.dcm.estimate.dcms.subj = repmat(struct('dcmmat', {}), numel(subject_folder), 1);

for i = 1:numel(subject_folder) % Loop through each subject
    dcm_files = {
        fullfile(data_folder_path, subject_folder{i}, 'DCM', 'DCM_m16_full.mat'),
        fullfile(data_folder_path, subject_folder{i}, 'DCM', 'DCM_m1_no_imagery.mat'),
        fullfile(data_folder_path, subject_folder{i}, 'DCM', 'DCM_m2_forward_imagery.mat'),
        fullfile(data_folder_path, subject_folder{i}, 'DCM', 'DCM_m3_backwards_imagery.mat'),
        fullfile(data_folder_path, subject_folder{i}, 'DCM', 'DCM_m4_backward_imag_forward_stim.mat')
    };

    % Assigning DCM files to the batch for each subject
    matlabbatch{1}.spm.dcm.estimate.dcms.subj(i).dcmmat = dcm_files;
end

matlabbatch{1}.spm.dcm.estimate.output.single.dir = {group_output_dir};
matlabbatch{1}.spm.dcm.estimate.output.single.name = 'group_est';
matlabbatch{1}.spm.dcm.estimate.est_type = 3; % Full Bayesian estimation
matlabbatch{1}.spm.dcm.estimate.fmri.analysis = 'time';

% Run the job
spm_jobman('run', matlabbatch);


%% Step 2: PEB Estimation
% Clear previous batch setup
matlabbatch = [];

% Define the PEB model
matlabbatch{1}.spm.dcm.peb.specify.name = 'group_PEB';
matlabbatch{1}.spm.dcm.peb.specify.model_space_mat = {fullfile(group_output_dir, 'GCM_group_est.mat')};
matlabbatch{1}.spm.dcm.peb.specify.dcm.index = 1;
matlabbatch{1}.spm.dcm.peb.specify.cov.none = struct([]);
matlabbatch{1}.spm.dcm.peb.specify.fields.default = {
                                                     'A'
                                                     'B'
                                                     }';
matlabbatch{1}.spm.dcm.peb.specify.priors_between.components = 'All';
matlabbatch{1}.spm.dcm.peb.specify.priors_between.ratio = 16;
matlabbatch{1}.spm.dcm.peb.specify.priors_between.expectation = 0;
matlabbatch{1}.spm.dcm.peb.specify.priors_between.var = 0.0625;
matlabbatch{1}.spm.dcm.peb.specify.priors_glm.group_ratio = 1;
matlabbatch{1}.spm.dcm.peb.specify.estimation.maxit = 64;
matlabbatch{1}.spm.dcm.peb.specify.show_review = 0;

% Run the job
spm_jobman('run', matlabbatch);

%% Step 3: PEB Comparison

% Clear previous batch setup
matlabbatch = [];

% Path definitions using previously set variables
peb_mat_path = fullfile(group_output_dir, 'PEB_group_PEB.mat');  % Path to the PEB results
model_space_mat_path = fullfile(group_output_dir, 'GCM_group_est.mat');  % Path to the model space file

% Setup PEB comparison
matlabbatch{1}.spm.dcm.peb.compare.peb_mat = {peb_mat_path};
matlabbatch{1}.spm.dcm.peb.compare.model_space_mat = {model_space_mat_path};
matlabbatch{1}.spm.dcm.peb.compare.show_review = 1;  % Set to 1 to enable graphical review

% Run the job
spm_jobman('run', matlabbatch);


