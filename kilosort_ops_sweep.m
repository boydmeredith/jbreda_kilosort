function kilosort_ops_sweep(varargin)
% function kilosort_ops_sweep(varargin)
% run kilosort on a binary file with a desired parameter set and
% save the results in a folder named to reflect the parameter set
% e.g. kilosort_ops_sweep('bindir',bindir, 'Th', [10 4], 'lam', 5)
% looks for a .bin file in bindir sorts it using the kilosort ops 
% parameters found in config_ks_ops.m but with Th set to [10 4] and 
% lam set to 5. Put the results in a new folder in bindir called 
% 'ops_lam_10_Th_10_4'
% written by Jess Breda 20200720
% modified by Tyler Boyd-Meredith to flexibly handle changing many parameters
%
%
% ---------------------
%% inputs (new code)

p = inputParser()
addParameter(p, 'spkTh', [])
addParameter(p, 'lam', [])
addParameter(p, 'Th',[])
addParameter(p, 'ThPre', [])
addParameter(p, 'fshigh', [])
addParameter(p, 'batchsec',[])
addParameter(p, 'bindir',[])
addParameter(p, 'ops',[])
addParameter(p, 'sweep_prefix','ops')

parse(p,varargin{:});

if isempty(p.Results.ops)
    ksp =  path_config();
    ops = ksp.default_ks_ops;
end
sweep_prefix = p.Results.sweep_prefix;
sweep_suffix = '';

if ~isempty(p.Results.spkTh)
    ops.spkTh = p.Results.spkTh;
    sweep_suffix = sprintf('%s_%s_%.1f',sweep_suffix,'spkTh',ops.spkTh);
end
    
if ~isempty(p.Results.lam)
    ops.lam = p.Results.lam;
    sweep_suffix = sprintf('%s_%s_%i',sweep_suffix,'lam',ops.lam);
end

if ~isempty(p.Results.Th)
    ops.Th = p.Results.Th;
    sweep_suffix = sprintf('%s_%s_%i_%i',sweep_suffix,'Th',ops.Th(1),ops.Th(2));
end

if ~isempty(p.Results.ThPre)
    ops.ThPre = p.Results.ThPre;
    sweep_suffix = sprintf('%s_%s_%i',sweep_suffix,'ThPre',ops.ThPre);
end
    
if ~isempty(p.Results.batchsec)
     k      = ceil(p.Results.batchsec * ops.fs / ops.ntbuff);
     ops.NT = k * ops.ntbuff + 32;
     sweep_suffix = sprintf('%s_%s_%is',sweep_suffix,'batch',p.Results.batchsec);
end

if ~isempty(p.Results.fshigh)
    ops.fshigh = p.Results.fshigh;
    sweep_suffix = sprintf('%s_%s_%i',sweep_suffix,hpf,ops.fshigh);
end

sweep_name = [sweep_prefix sweep_suffix];
    
if ~isempty(p.Results.bindir)
    bindir = p.Results.bindir;
else
    bindir = pwd;
end
 
% grab the name of the .bin file to use it later
bininfo = dir(fullfile(bindir, '*.bin'));
assert(length(bininfo)==1);
binfile = fullfile(bindir, [bininfo.name ]);
% first, make a folder, add it to the path, and move the .bin
% file into the folder
sweep_dir = fullfile(bindir, sweep_name);
temp_binfile = fullfile(sweep_dir, [bininfo.name ]);
mkdir(sweep_dir)

% move binfile into directory
movefile(binfile, temp_binfile)

% run kilosort 
try
main_kilosort_fx(sweep_dir, ops);
catch
    fprintf('kilosort failed')
end
fprintf('putting binary file back where we found it')
% move binfile back out of directory
movefile(temp_binfile, binfile)
end





