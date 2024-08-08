%This script takes the resulting accuracy maps from the decoding analysis and the
%mask which shows the significant voxel clusters from second level glm
%analysis and extracts the mean svm accuracy minus chance and standard error mean for each cluster to obtain
% measures of classifier performance. 

%Stimulation condition 

%First load the significant cluster mask for the stimulation condition
data_dir = '/Users/coxon/Downloads/Stim_output_new';
subjects = {'sub-001', 'sub-002', 'sub-003', 'sub-004', 'sub-005', 'sub-006', 'sub-007', 'sub-008', 'sub-009', 'sub-010'};


% Obtain Coordinates for each cluster (x, y, z) from the GUI
% Cluster 1 (mid occipital, BA 18)
%[20, -102, 4; 32, -98, -4; 30, -98, 4],  % Voxel coordinates for cluster 1
%(size 303)
% Cluster 2 (Insula)
%[-40, -28, 20; -52, -40, 10; -56, -26, 14], 
%(size 374)
%Cluster 3 (Superior temporal gyrus R)
%[42, -28, 22; 60, -24, 4; 62, -34, 10],
%(size 819)
%Cluster 4 (BA2/3)
%[50, -14, 56], [52, -12, 48], [44, -80, 4]
%(size 50)


% Load the reference image to find image dimensions
reference_nifti = '/Users/coxon/Downloads/second_level_stim_results/spmT_0001';
info = niftiinfo(reference_nifti);
dims = info.ImageSize; % 

cluster_mask_paths = {
    '/Users/coxon/Downloads/second_level_stim_results/cluster_masks/cluster_mask_1.nii',
    '/Users/coxon/Downloads/second_level_stim_results/cluster_masks/cluster_mask_2.nii',
    '/Users/coxon/Downloads/second_level_stim_results/cluster_masks/cluster_mask_3.nii',
    '/Users/coxon/Downloads/second_level_stim_results/cluster_masks/cluster_mask_4.nii',
};

% Load subject-specific accuracy maps
num_subjects = 10; % Number of subjects
accuracy_maps = cell(num_subjects, 1);

% four different clusters
% Number of clusters
num_clusters = length(cluster_mask_paths);

%Accuracy maps
for subj = 1:num_subjects
    accuracy_map_path = fullfile(data_dir, subjects{subj}, 'res_accuracy_minus_chance.nii');
    accuracy_map_info = niftiinfo(accuracy_map_path);
    accuracy_maps{subj} = niftiread(accuracy_map_info);
end

% Initialize cell array to hold mean accuracy for each cluster
mean_accuracies = zeros(num_clusters, 1);

for cluster_idx = 1:num_clusters;
    cluster_mask_info = niftiinfo(cluster_mask_paths{cluster_idx});
    cluster_mask = niftiread(cluster_mask_info);
    
    % Initialize an array to hold accuracy values for the current cluster
    cluster_accuracies = [];
    
    for subj = 1:num_subjects
        if isequal(size(accuracy_maps{subj}), size(cluster_mask))
            % Extract accuracy values for the current cluster
            current_accuracies = accuracy_maps{subj}(cluster_mask > 0);
            cluster_accuracies = [cluster_accuracies; current_accuracies];
        else
            error('Accuracy map and cluster mask dimensions do not match for subject %d.', subj);
        end
    end

     % Calculate mean accuracy for the current cluster
    mean_accuracies(cluster_idx) = mean(cluster_accuracies);
    std_accuracies(cluster_idx) = std(cluster_accuracies)
    
    % Display the results for each cluster
    fprintf('Mean Accuracy for Cluster %d: %.4f\n', cluster_idx, mean_accuracies(cluster_idx));
    fprintf('Standard deviation for Cluster %d: %.4f\n', cluster_idx, std_accuracies(cluster_idx));
end

%Mean accuracies and standard deviations for the stimulation condition
%Mean Accuracy for Cluster 1: 20.1101, Standard deviation 12.2670
%Mean Accuracy for Cluster 2: 13.1462, Standard deviation 8.1609
%Mean Accuracy for Cluster 3: 14.5218, Standard deviation 8.9259
%Mean Accuracy for Cluster 4: 11.2889, Standard deviation 7.0145

%Calculate SEMs (standard deviation/ square root of sample size (n)
mean_accuracies = [20.1101, 13.1462, 14.5218, 11.2889];
std_devs = [12.2670, 8.1609, 8.9259, 7.0145];
n = 10; 
sem = std_devs / sqrt(n);

% Display the results
disp('Standard Error of the Mean (SEM) for each cluster:');
disp(sem);

% SEMs: Cluster 1: 3.8792, Cluster 2: 2.5807, Cluster 3: 3.4258, Cluster 4: 2.2182

%Imagery Condition
data_dir = '/Users/coxon/Downloads/Imag_output_new';

%Use the spm GUI to find voxel coordinates (p < 0.001)
%Cluster 1 [-36, -52, 58] = Left Inferior parietal lobule
%Cluster 2 [-56 -42 18] superior temporal sulcus Left ba13
%Cluster 3 [60 -8 14;, 62 -2 24] = right precentral gyrus ba43 ba6
%Cluster 4 [28,-94,12; 34, -88,13; 24, -90,18] (occipital gyrus R)
%Cluster 5 [54 -54 38; 56, -52, 46] (inferior parietal lobule 


% Load the reference image to get dimensions
reference_nifti = '/Users/coxon/Downloads/second_level_imagery_results/spmT_0001';
info = niftiinfo(reference_nifti);
dims = info.ImageSize; % Get the dimensions of the image


cluster_mask_im_paths = {
    '/Users/coxon/Downloads/second_level_imagery_results/cluster_masks_im/cluster_1_mask.nii',
    '/Users/coxon/Downloads/second_level_imagery_results/cluster_masks_im/cluster_2_mask.nii',
    '/Users/coxon/Downloads/second_level_imagery_results/cluster_masks_im/cluster_3_mask.nii',
    '/Users/coxon/Downloads/second_level_imagery_results/cluster_masks_im/cluster_4_mask.nii',
    '/Users/coxon/Downloads/second_level_imagery_results/cluster_masks_im/cluster_5_mask.nii',
};

% subject-specific accuracy maps
num_subjects = 10; % Number of subjects
accuracy_maps = cell(num_subjects, 1);

% five different clusters
% Number of clusters
num_clusters = length(cluster_mask_im_paths);

for subj = 1:num_subjects
    accuracy_map_path = fullfile(data_dir, subjects{subj}, 'res_accuracy_minus_chance.nii');
    accuracy_map_info = niftiinfo(accuracy_map_path);
    accuracy_maps{subj} = niftiread(accuracy_map_info);
end

mean_accuracies = zeros(num_clusters, 1);

for cluster_idx = 1:num_clusters
    cluster_mask_info = niftiinfo(cluster_mask_im_paths{cluster_idx});
    cluster_mask = niftiread(cluster_mask_info);
    cluster_accuracies = [];
    
    for subj = 1:num_subjects;
        if isequal(size(accuracy_maps{subj}), size(cluster_mask))
            current_accuracies = accuracy_maps{subj}(cluster_mask > 0);
            cluster_accuracies = [cluster_accuracies; current_accuracies];
        else
            error('Accuracy map and cluster mask dimensions do not match for subject %d.', subj);
        end
    end

     % mean accuracy for the current cluster
    mean_accuracies(cluster_idx) = mean(cluster_accuracies);
    std_accuracies(cluster_idx) = std(cluster_accuracies);
    
    % results for each cluster
    fprintf('Mean Accuracy for Cluster %d: %.4f\n', cluster_idx, mean_accuracies(cluster_idx));
    fprintf('Standard deviation for Cluster %d: %.4f\n', cluster_idx, std_accuracies(cluster_idx));
end


%Mean accuracy for Cluster 1: 13.3611, standard deviation: 8.1493
%Mean accuracy for Cluster 2: 12.4826, standard deviation: 7.6160
%Mean accuracy for Cluster 3: 11.7157, standard deviation: 7.2729
%Mean accuracy for Cluster 4: 11.4757, standard deviation: 7.2657
%Mean accuracy for Cluster 5: 10.5556, standard deviation: 6.6357

%Calculate SEM for imagery 
mean_accuracies = [13.3611, 12.4826, 11.7157,11.4757, 10.5556];
std_devs_im = [8.1493, 7.6160, 7.2729, 7.2657, 6.6357];
n = 10; % Sample size
% Calculate SEM
sem_im = std_devs_im / sqrt(n);
disp('Standard Error of the Mean (SEM) for each cluster:');
disp(sem_im);

% SEMs: Cluster 1: 2.5770, Cluster 2: 2.4084, Cluster 3: 2.2999, Cluster 4: 2.2976, Cluster 5: 2.0984


% Now,to display these statistics in a graph: stimulation 
clusterLabels = {'Cluster 1 (mid occipital/BA 18)', 'Cluster 2 (Insula)', 'Cluster 3 (Superior Temporal Gyrus R)', 'Cluster 4 (BA2/3)'};
mean_accuracies = [20.1101, 13.1462, 14.5218, 11.2889];

figure; % Create a new figure window
bar(mean_accuracies); % Create a bar graph

set(gca, 'XTickLabel', clusterLabels); % Set the x-axis labels
title('Mean Accuracy Minus Chance for Each Cluster in Stimulation Condition');
xlabel('Clusters');
ylabel('Mean Accuracy Minus Chance');
% error bars
hold on;
errorbar(mean_accuracies, sem, 'k', 'LineStyle', 'none', 'LineWidth', 1.5);

%save figure
saveas(gcf, 'mean_acc_minus_chance_stim.jpg');


%Graph for imagery clusters 
clusterLabels = {'Cluster 1 (Left IPL)', 'Cluster 2 (Left Superior Temporal Gyrus)', 'Cluster 3 (Right Precentral Gyrus, BA43)', 'Cluster 4 (Mid Occipital Gyrus)', 'Cluster 5 (Right IPL) '};
mean_accuracies = [13.3611, 12.4826, 11.7157,11.4757, 10.5556];

figure; % Create a new figure windowxjvi
bar(mean_accuracies, 'FaceColor', 'g'); % Create a bar graph

set(gca, 'XTickLabel', clusterLabels); % Set the x-axis labels
title('Mean Accuracies for Each Cluster in Imagery Condition');
xlabel('Clusters');
ylabel('Mean Accuracy Minus Chance');
hold on;
errorbar(mean_accuracies, sem_im, 'k', 'LineStyle', 'none', 'LineWidth', 1.5);

%save figure
saveas(gcf, 'mean_acc_minus_chance_imag.jpg');