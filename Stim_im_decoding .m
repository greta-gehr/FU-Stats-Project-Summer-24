% This script uses existing beta images from Nierhaus et al., (2023) and runs a searchlight
% decoding analysis. We train a linear support vector machine to
% discriminate between different stimuli types in tactile and imagery
% conditions and apply a leave-one-out cross validation using the Decoding Toolbox (Hebart et al., 2015). 

%Add paths to Decoding toolbox and SPM
% TDT
addpath('/Users/coxon/Downloads/tdt_3.999F/decoding_toolbox')
% SPM/AFNI
addpath('/Users/coxon/Downloads/spm12')

subjects = {'sub-001', 'sub-002', 'sub-003', 'sub-004', 'sub-005', 'sub-006', 'sub-007', 'sub-008', 'sub-009', 'sub-010'}


% Set cfg defaults
cfg = decoding_defaults;
cfg.decoding.method = 'classification';

% Set the searchlight analysis
cfg.analysis = 'searchlight'; 
cfg.searchlight.radius = 3; %
cfg.searchlight.spherical = 1;


% Set the label names to the regressor names (stimulation + imagery)

labelname1 = 'StimPress';
labelname2 = 'StimFlutt';
labelname3 = 'StimVibro';

%labelname1 = 'ImagPress';
%labelname2 = 'ImagFlutt';
%labelname3 = 'ImagVibro';


labelvalue1 = 1; % value for labelname1, 2, 3
labelvalue2 = 2;
labelvalue3 = 3;


%% Set additional parameters

cfg.verbose = 2; % 
%cfg.decoding.train.classification.model_parameters = '-s 0 -t 0 -c 1 -b 0 -q'; 

% Scaling method
cfg.scale.method = 'min0max1';
cfg.scale.estimation = 'all'; % 


%%

% choose decoding software - libsvm
cfg.decoding.software = 'libsvm'; 
cfg.decoding.train.classification.model_parameters = struct();
cfg.decoding.train.classification.model_parameters.shrinkage = 'lw2';

cfg.plot_selected_voxels  = 0; % 0: no plotting



%% cfg results measures (accuracy minus chance)
cfg.results.overwrite = 1;
cfg.results.output = {'accuracy_minus_chance', 'confusion_matrix'}; % 'accuracy_minus_chance' maps for searchlight analysis


%% leave-one-run out cross validation analysis for all 10 subjects

for i = 1:length(subjects)
    subject = subjects{i};

     cfg.results.dir = ['/Users/coxon/Downloads/Stim_output_new/', subject];
     %cfg.results.dir = ['/Users/coxon/Downloads/Imag_output_new/', subject];
     if ~exist(cfg.results.dir, 'dir')
        mkdir(cfg.results.dir);
     end
     beta_loc = ['/Users/coxon/Desktop/tact_data/', subject, '/1st_level_good_bad_Imag'];
     cfg.files.mask = [beta_loc, '/mask.nii'];
     regressor_names = design_from_spm(beta_loc);
     cfg = decoding_describe_data(cfg,{labelname1 labelname2 labelname3},[labelvalue1 labelvalue2 labelvalue3],regressor_names,beta_loc);
     cfg.design = make_design_cv(cfg); 
     results = decoding(cfg);
end 


%Perform one sample t-test to compare the accuracies against 0 
% second level GLM with accuracy maps 
% see the script secondlevelglm.m


