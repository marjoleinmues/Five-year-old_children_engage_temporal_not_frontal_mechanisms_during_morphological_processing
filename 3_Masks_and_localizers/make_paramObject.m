%% Script to find top x or x% voxels for each subject for a given contrast, masked by an ROI or not. This script puts all the necessary 
%info into an object. After running this script, you should run the command: makeroi(paramObject). 
% Written by Jerome Prado updated by Marjolein for Morphology prject
% 6/21/24

%% specify file paths 

addpath(genpath('/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/neelima/ELP/analysis_code/spm12_elp'));
spm('defaults','fmri');

addpath('/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/fmriTools/util'); % ensures that marsbar is in your path

%% define data path

paramObject.data_root = '/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/Marjolein/ELP/Morph_5/preprocessed'; %the parent directory for all the subject folders
paramObject.SPM_mat_folder = '/ses5_analysis_phon/deweight'; %the name of the directory under the subject data folder containing the SPM.mat file with contrast info
paramObject.contrast_name = 'RhymeOnset_Cont'; %the name of the contrast associated with the statistical map you want to use. Check your SPM.mat file for names

%% select regions

% all regions
paramObject.regions = {};

%paramObject.regions={'fPPI_LIPL' 'fPPI_RSPL' 'fPPI_LMFG' 'fPPI_MeFG' 'LMFG' 'LeftNA_005'}; %for each region 'XXX', there should be a tab-delimited list of xyz coordinates called XXX.txt in the working directory. (I think the purpose of this line has been lost, and you can just leave the paramObjects.regions blank -JY)

paramObject.images = {'/postSTG'}; %The ROI you want to use (you can also specify the names of .nii files to be used in lieu of or in addition to your sphere coordinates)

% PLAUS SUBJECTS N=26
% paramObject.subjects = {'5008' '5009' '5010' '5025' '5054' '5055' '5058' '5070' '5094' '5099'...
%                         '5102' '5137' '5143' '5149' '5159' '5161' '5167' '5169' '5179' '5185'...
%                         '5192' '5215' '5270' '5286' '5304' '5338'};

% GRAM SUBJECTS N=30 
paramObject.subjects = {'5008' '5009' '5015' '5025' '5029' '5031' '5034' '5045' '5054' '5055'...
                        '5065' '5069' '5070' '5075' '5077' '5099' '5102' '5104' '5109' '5125'...
                        '5137' '5140' '5141' '5159' '5160' '5167' '5179' '5199' '5242' '5352'};

%% OPTIONAL PARAMETERS 
% If these values are not specified, defaults will be used (p=.05, radius=8mm, k=100%)

paramObject.p=1; %uncorrected p-value for statistical map with which sphere is intersected
%paramObject.radius=6; %sphere radius, in mm (again, the utility of this line I think has been lost -JY)

paramObject.k='100'; %specify paramObject.k as either 'k%' or just 'k'
			%if k is specified as k%, it will take the top k percentile of voxels
			%if k is specified as k, then it will take the top k voxels
			%It will always select at least 1 voxel (e.g., top 10% of a 9 voxel blob < 1, so select the top 1 voxel)

paramObject.savesphere=0; %do you want to save the base spheres for each person? Might be useful for debugging failed ROI attempts
paramObject.savedir='/postSTG_ROIs';%name of the subdirectory to be created in the current directory into which the ROIs will be saved
				%if a savedir is not specified, a directory with today's date will be created
                
                
