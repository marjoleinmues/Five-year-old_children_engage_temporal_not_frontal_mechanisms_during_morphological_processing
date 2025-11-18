%% Second level analysis by Jin Wang 3/19/2019
% Currently I only write the one sample t test and regression analysis, which are the two mostly used. 

%% Modified to be used for Morphology Project

% Last modified: 08/20/2024 by Marjolein, script for the correlation of
% grammatical with language (word structure)

%% Set paths to analysis code, spm, and analysis directories
% Requires the expand_path.m script to be in the analyses folder

% add path to current script folder
addpath(genpath('/panfs/accrepfs.vampire/data/booth_lab/Marjolein/Morph_5/scripts/Second_Level')); 

% add path to spm folder
spm_path='/panfs/accrepfs.vampire/data/booth_lab/LabCode/typical_data_analysis/spm12_elp';
addpath(genpath(spm_path));

% add path to project folder
root='/panfs/accrepfs.vampire/data/booth_lab/Marjolein/Morph_5/preprocessed';

% specifcy output folder for secondlevel analysis results
out_dir='/panfs/accrepfs.vampire/data/booth_lab/Marjolein/Morph_5/secondlevel_gensen_ws';

%% Specify participants
% can specify participants by manually adding in subject names or calling
% in a file with names listed

% manually define participants below e.g. subjects={'sub-5004' 'sub-5009'}

% %syn subjects after checking for movement, acc, bias, etc.
%subjects={...
     %'sub-5008','sub-5009'};

% leave the above variable empty and define a path of an excel that contains subject numbers as indicated below 
data_info='/panfs/accrepfs.vampire/data/booth_lab/Marjolein/Morph_5/Subjects.xlsx'; %In this excel, there should be a column of subjects with the header (subjects). The subjects should all be sub plus numbers (sub-5002).
%if isempty(subjects)
M=readtable(data_info);
subjects=M.subjects;
%cov=M.covar;
 
%% Specify folder structure for analysis
% usually, no need to modify if you follow the rule of the folder structure convention in the walkthrough

global CCN;

CCN.session = 'ses-5'; %time points you want to analyze 
CCN.func_pattern = 'sub*Gram*'; %name of your functional folders
analysis_folder = 'ses5_analysis_gram_perceptual'; % the name of your folder to be analyzed (first-level analysis)
model_deweight = 'deweight'; % the deweigthed modeling folder, it will be inside of your analysis folder

%% Specify analysis parameters 

% choose analysis method
test = 2; %1 = one-sample t test, 2 = mutiple regression analysis

% choose covariates in your second level modeling
cov = 1; % 1 = if you have covariates, 0 = if you do not have covariates

%% Ignore these lines if you DO NOT have covariates. 
% You do not need to comment the following information out if you put cov=0
% because it won't be read in the analysis. Only when you put
%cov=1, the following covariates will be read in the analysis.

% define your covariates of control for your one-sample t test. Or define your covariates of interest for your multiple regression
% analysis if you have covariates. 
cov_num = 2; %number of your covariates

% Define as many covariates as you want by adding name and values. 
% This should be the SAME ORDER as your subject numbers. 

% Syntax Recalling Sentences - Raw Score
%SES-7 
name{1} = 'celf_word_structure'; %scaled score
val{1} = [11, 13, 14, 13, 12, 10, 12, 16, 8, 12, 10, 17, 16, 10, 13, 10, 12, 11, 11, 10, 13, 12, 11, 14, 15, 10, 8, 12, 10, 16, 10, 12, 10, 8, 5, 12, 12, 10, 13, 16, 13, 17, 13, 12, 9, 11, 8, 9];
name{2} = 'kbit_scaled_score'; %scaled score
val{2} = [120, 107, 99, 104, 104, 118, 115, 131, 92, 105, 96, 115, 121, 103, 114, 123, 115, 89, 106, 103, 115, 99, 130, 100, 129, 120, 89, 96, 86, 151, 120, 106, 103, 96, 96, 118, 118, 89, 96, 128, 92, 89, 80, 106, 117, 136, 93, 112];

%SES-9 
%name{1} = 'celf_rs_raw_9'; %raw score
%val{1} = [67 65 65 59 51 63 48 67 52 43 53 68 73 64 58 61 55 57 57 47 61 64 71 42 51 48 30 57 57 44 37 35 34 47 55 35 55 39 48 49 38];

%% %%%%%%%%%%%%%%%%%%%%%%Do not edit below here%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%

% Initialize
%addpath(spm_path);
spm('defaults','fmri');
spm_jobman('initcfg');
spm_figure('Create','Graphics','Graphics');

% Dependency and sanity checks
if verLessThan('matlab','R2013a')
    error('Matlab version is %s but R2013a or higher is required',version)
end

req_spm_ver = 'SPM12 (6225)';
spm_ver = spm('version');
if ~strcmp( spm_ver,req_spm_ver )
    error('SPM version is %s but %s is required',spm_ver,req_spm_ver)
end

%Start to analyze the data from here
    
%load the contrast file path for each subject
scan=[];
for i=1:length(subjects)
deweight_spm=[root '/' subjects{i} '/' analysis_folder '/' model_deweight '/SPM.mat'];
deweight_p=fileparts(deweight_spm);
load(deweight_spm);
contrast_names=[];
scan_files=[];
for ii=1:length(SPM.xCon)
    contrast_names{ii,1}=SPM.xCon(ii).name;
    scan_files{ii,1}=[deweight_p '/' SPM.xCon(ii).Vcon.fname];
end
contrast{i}=contrast_names;
scan{i}=scan_files;
end
scans=[];
for i=1:length(scan{1})
    for j=1:length(subjects)
        scans{i}{j,1}=[scan{j}{i} ',1'];
    end
end

%make output folder for each contrast
if ~exist(out_dir)
    mkdir(out_dir);
end
cd(out_dir);
for ii=1:length(contrast{1})
    out_dirs{ii}=[out_dir '/' contrast{1}{ii}];
    if ~exist(out_dirs{ii})
        mkdir(out_dirs{ii}); 
    end
end

%covariates 
%pass the covariates to a struct
if cov==1
    covariates.name=name;
    for i=1:cov_num
     values{i}=transpose(val{i});
    end
    covariates.values=values;
else
    covariates={};
end

if test==1 % one-sample t test
    onesample_t(out_dirs,scans,covariates);
    
elseif test==2 %multiple regression analysis
    multiple_regression(out_dirs,scans,covariates);
   
end

