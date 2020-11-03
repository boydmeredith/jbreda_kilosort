expmtr      = 'Ahmed';
extradir    = 'SpikeGadgets'; % this can be the empty string 
brody_dir   = 'Y:\';
raw_dir     = fullfile(brody_dir, 'RATTER', 'PhysData', 'Raw');
sorted_dir  = fullfile(brody_dir, 'RATTER', 'PhysData', 'Sorted');
ratlist     = {'H191','H176'};
mda_parentdir = fullfile(raw_dir, expmtr, extradir);
mdadir_fn      = @(sess_name) fullfile(mda_parentdir, [sess_name '.mda']);
localexpmtrdir = fullfile('D:', expmtr);
localsessdir_fn = @(sess_name, ratname) fullfile(localexpmtrdir, ratname, sess_name);
serversessdir_fn = @(sess_name, ratname) fullfile(sorted_dir, expmtr, ratname, sess_name); 
do_preprocess  = false;

%%
% err_inc = 0;
% retry_list = dir(fullfile(mda_parentdir,'*.mda'));
% for dd = 47:length(retry_list)
%     fprintf('working on %i\n', dd)
%     [~, sess] = fileparts(retry_list(dd).name);
%     try
%         find_wireless_sess(sess);
%     catch MExc
%         err_inc = err_inc + 1;
%         errs{err_inc} = lasterr;
%         continue
%     end
%     fprintf('finised %i\n', dd)
% 
% end
% fail_list = dir(fullfile(mda_parentdir,'*/no_ttl_match.mat'));

%%
% sess_name   = 'data_sdc_20191111_180809_fromSD';
% list = dir([mda_parentdir '\*\ttl_match.mat']);
% sorted = zeros(size(list));
% n = 0;
% sess_list = {};
% for ss = 1:length(list)
%     [~, fldr]  = fileparts(list(ss).folder);
%     if length(dir(fullfile('D:\Ahmed\H191\',fldr,'*\params.py')))
%         sorted(ss) = 1;
%     else
%         n = n + 1;
%         sess_list{n} = fldr;
%     end
% end

%%
    
sess_list = {  'data_sdc_20190829_173738_fromSD'...
        'data_sdc_20190821_124816_fromSD', ...
    'data_sdc_20190823_131411_fromSD', ...
    'data_sdc_20190828_131703_fromSD', ...
    'data_sdc_20190828_171807_fromSD', ...
        'data_sdc_20190819_175710_fromSD', ...
    'data_sdc_20190816_173840_fromSD'};

sess_list = {  'data_sdc_20190829_173738_fromSD'};
    
do_preprocess   = 0;
p               =  path_config();
ops             = p.default_ks_ops;
ops.trange(1)   = 60;
ops.trange(end)   = 60*60*2;
ops.NT                  = 3*64*1024 + ops.ntbuff;
ops.ThPre = 3;
ops.Th = [4 2]; 
ops.lam = 10;  

logfname = sprintf('ks_logfile_%s.txt', datetime('now','format','yyyyMMdd_HHmmss'));
logfpath = fullfile(localexpmtrdir, logfname);
logfid = fopen(logfpath, 'w');

for ss =1:length(sess_list)
    %%
    sess_name = sess_list{ss};
    
    sm  = find_wireless_sess(sess_name, 'ratlist', ratlist, 'expmtr', expmtr);
    
    ratname         = sm.ratname;
    mdadir          = mdadir_fn(sess_name);
    localsessdir    = localsessdir_fn(sess_name, ratname);
    
    if ~exist(localsessdir)
        mkdir(localsessdir);
    end
    
    % check to see if we already have the bundled binary files
    files = dir(fullfile(localsessdir,'*bundle?'));
    isbundled = sum([files.isdir]) == 4;
    
    if ~isbundled
        try
            tetrode_32_mdatobin(mdadir, localsessdir)
        catch
            continue
        end
    end
    
    %%
    %basedir = 'C:\Users\brodylab\Documents\Tyler\Kilosort\H191\';
    bundle_fn = @(sess_name, bb) sprintf('%s_bundle%i',sess_name,bb);
    for bb=1:4
        bundledir = fullfile(localsessdir, bundle_fn(sess_name,bb))
        if do_preprocess
            kilosort_preprocess(bundledir);
        end
        main_kilosort_fx(bundledir, ops);
%         try
%             main_kilosort_fx(bundledir);
%             fprintf(logfid, 'success: %s\n', bundledir);
% 
%         catch
%             fprintf(logfid, 'failure: %s\n', bundledir);
%         end
    end
end

%{
  NOTE: rerun 11-11(?) with main_kilosort_fx on kilosort_preprocess outputs 
%}
