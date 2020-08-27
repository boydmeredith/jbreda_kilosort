function ops = config_ks_ops(chan_map_fpath)
% function ops = config_ks_opts(p)
% sets up the ops struct to pass settings to kilosort
% takes input struct p containing a field 'chan_map_fpath'
% which contains the full file path to the channel map
% if no input is given, it just uses the default created by running p =
% path_config()

if nargin  < 1
    chan_map_fpath = '';
end

ops.trange      = [60 Inf]; % time range to sort (in seconds)
ops.NchanTOT    = 32; % total number of channels in your recording

ops.chanMap             = fullfile(chan_map_fpath);
% ops.chanMap = 1:ops.Nchan; % treated as linear probe if no chanMap file

% sample rate
ops.fs = 30000;  

% frequency for high pass filtering (150)
ops.fshigh = 300;   
ops.FILTERON = 1; 

% minimum firing rate on a "good" channel (0 to skip)
ops.minfr_goodchannels = 0.1; 

% threshold on projections (like in Kilosort1, can be different for last pass like [10 4])
ops.Th = [6 2];  

% how important is the amplitude penalty (like in Kilosort1, 0 means not used, 10 is average, 50 is a lot) 
ops.lam = 20;  

% splitting a cluster at the end requires at least this much isolation for each sub-cluster (max = 1)
ops.AUCsplit = 0.9; 

% minimum spike rate (Hz), if a cluster falls below this for too long it gets removed
ops.minFR = 1/50; 

% number of samples to average over (annealed from first to second value) 
ops.momentum = [20 400]; 

% spatial constant in um for computing residual variance of spike
ops.sigmaMask = 30; 

% threshold crossings for pre-clustering (in PCA projection space)
ops.ThPre = 8; 

% noise
% ops.criterionNoiseChannels = 0.01

% CAR filter (because why not at this point)
ops.CAR = 1;


%% danger, changing these settings can lead to fatal errors
% options for determining PCs
ops.spkTh           = -1.5;      % spike threshold in standard deviations (-6)
ops.reorder         = 1;       % whether to reorder batches for drift correction. 
ops.nskip           = 25;  % how many batches to skip for determining spike PCs

ops.GPU                 = 1; % has to be 1, no CPU version yet, sorry
% ops.Nfilt               = 1024 * 2; % max number of clusters (doubling this JB)
ops.nfilt_factor        = 4; % max number of clusters per good channel (even temporary ones)
ops.ntbuff              = 64;    % samples of symmetrical buffer for whitening and spike detection
ops.NT                  = 64*1024+ ops.ntbuff; % must be multiple of 32 + ntbuff. This is the batch size (try decreasing if out of memory). 
ops.whiteningRange      = 32; % number of channels to use for whitening each channel
ops.nSkipCov            = 25; % compute whitening matrix from every N-th batch
ops.scaleproc           = 200;   % int16 scaling of whitened data
ops.nPCs                = 3; % how many PCs to project the spikes into
ops.useRAM              = 0; % not yet available

%%