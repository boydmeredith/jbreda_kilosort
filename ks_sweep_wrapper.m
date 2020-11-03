clear

main_dir =  'D:\Ahmed\H191\';
sess_list = {'data_sdc_20190905_170428_fromSD' 'data_sdc_20190911_174821_fromSD'};
%defaults = {'batchsec',2,'spkTh',-6,'Th',[10 4],'lam',10,'ThPre',8}
sweeps =  {{'lam',10,'ThPre',2,'Th',[10 4],'spkTh',-1.5} ...
    };
for ss = 1:length(sess_list)
    sess = sess_list{ss};
    for bb = 1:4
        sweep_dir = fullfile(main_dir, sess, [sess '_bundle' num2str(bb)]);
        cd(sweep_dir);
        nsweeps = length(sweeps);
        for ii = 1:nsweeps
            this_args = sweeps{ii};
            kilosort_ops_sweep(this_args{:});
        end
    end
end