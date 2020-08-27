function p = path_config()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

p.utils_dir = fileparts(mfilename('fullpath'));
p.repo_dir  = strrep(p.utils_dir,'utils','');
p.local_ks  = fullfile(p.utils_dir,'local_kilosort');
p.chan_map_fpath = fullfile(p.local_ks,'KSchanMap_thousands.mat');
addpath(genpath(p.repo_dir));
p.default_ks_ops = config_ks_ops(p.chan_map_fpath);

end

