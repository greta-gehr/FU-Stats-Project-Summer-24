% Add path to SPM
addpath('/Users/coxon/Downloads/spm12');

% Directory containing the accuracy masks (Comment out Stim or Im depending
% on analysis)
data_dir = '/Users/coxon/Downloads/Imag_output_new';
%data_dir = '/Users/coxon/Downloads/Stim_output_new')
subjects = {'sub-001', 'sub-002', 'sub-003', 'sub-004', 'sub-005', 'sub-006', 'sub-007', 'sub-008', 'sub-009', 'sub-010'};

% Directory for the second-level analysis results
second_level_dir = '/Users/coxon/Downloads/second_level_imagery_results';

% Create second-level results directory if it doesn't exist
if ~exist(second_level_dir, 'dir')
    mkdir(second_level_dir);
end

% Initialize SPM
spm('Defaults', 'fMRI');
spm_jobman('initcfg');

% Create a batch job
matlabbatch = {};
spm fmri

% Add each subject's accuracy mask to the design
for i = 1:length(subjects)
    mask_file = fullfile(data_dir, subjects{i}, 'res_accuracy_minus_chance.nii');
    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans{end+1} = mask_file;
end

% Specify other design parameters
matlabbatch{1}.spm.stats.factorial_design.dir = {second_level_dir};
matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = matlabbatch{1}.spm.stats.factorial_design.des.t1.scans';
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.des.t1.im = 1; % Independence of measurements
matlabbatch{1}.spm.stats.factorial_design.des.t1.variance = 1; % Equal variance
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1; % No explicit masking
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1; % Implicit masking
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''}; % No explicit mask
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1; % No global calculation
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1; % No grand mean scaling
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1; % Normalization

spm_jobman('run', matlabbatch);

clear matlabbatch;
% Estimate the model
matlabbatch{2}.spm.stats.fmri_est.spmmat = {fullfile(second_level_dir, 'SPM.mat')};
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0; % Don't write residuals
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1; % Classical estimation

spm_jobman('run', matlabbatch);

% Set up the contrast for the one-sample t-test
clear matlabbatch
matlabbatch{3}.spm.stats.con.spmmat = {fullfile(second_level_dir, 'SPM.mat')};
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'one sample t test Accuracy > 0';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{1}.spm.stats.con.delete = 0;

% Run the batch job
spm_jobman('run', matlabbatch);

% View the results in the SPM GUI 
% See cluster_accuracies.m

