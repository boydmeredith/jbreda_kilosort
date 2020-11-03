function res = find_ttl_match(sess, ratlist, behav_dir, mda_dir)  
% function res = find_ttl_match(sess, ratlist, behav_dir, mda_dir)  
% given a set of ttls and a date, search through a list of rats to find the best physiology session to match these ttls

overwrite   = 1; 
fs          = 30000;

if nargin < 2
    ratlist     = {'H191','H176'};
    behav_dir   = '/jukebox/brody/RATTER/SoloData/Data/Ahmed/';
    phys_dir    = '/jukebox/brody/physdata/Ahmed_SpikeGadgets/';
    mda_dir     = [phys_dir sess '.mda/'];
end
save_path   = fullfile(mda_dir, 'ttl_match.mat')
if exist(save_path) & ~overwrite
    d = load(save_path,'res','sess');
    if strcmp(d.sess, sess)
        res = d.res;
        return;
    else 
        clear d
    end
end

dio         = [mda_dir sess '.dio_RFINPUT.dat'];
if ~exist(dio)
    dio = [strrep(mda_dir,'.mda','.DIO') sess '.dio_RFINPUT.dat'];

end
fi=dir(dio);
if(isempty(fi))
  error(sprintf('dio missing %s',dio))
end

if strcmp(sess(1:4),'data')
    ratname = '';
    date_str = sess(12:17);
    fprintf('no ratname, will look for best match on date %s',date_str)
else
    ratname = sess(1:4);
    ratlist = {ratname};
    date_str = sess([14 15 6 7 9 10]);
    fprintf('ratname %s, date %s',ratname,date_str)
end



d=readTrodesExtractedDataFile(dio);
c=d.fields(1).data;
b=d.fields(2).data;
ttl_trodes=double(c(b==1))/fs;
inc = 0;
for rr = 1:length(ratlist)
    fntemp = fullfile(behav_dir, ratlist{rr}, ['data_*' date_str '*.mat']);
    ez=dir(fntemp);
    if isempty(ez)
        fprintf(['couldn''t find a match for ' fntemp])
        continue
    end
    for ff=1:length(ez)
        inc             = inc +1;
        rats{inc}       = ratlist{rr};
        this_behav_name = ez(ff).name;
        this_behav_path = fullfile(ez(ff).folder, this_behav_name);
        filename{inc}   = this_behav_name;
        allpath{inc}    = this_behav_path;
        load(this_behav_path, 'saved_history');
        
        parsed_events=saved_history.ProtocolsSection_parsed_events;
        % load TTLS for alignment with ephys
        ttls_fsm=nan(1,length(parsed_events));
        for i=1:length(parsed_events)
            if(isfield(parsed_events{i}.states,'sending_trialnum') && length(parsed_events{i}.states.sending_trialnum)>0 )
                ttls_fsm(i)=parsed_events{i}.states.sending_trialnum(1);
            else
                ttls_fsm(i)=NaN;
            end
        end
        ttls_fsm=ttls_fsm';
        
        trode_gaps  = diff(ttl_trodes);
        fsm_gaps    = diff(ttls_fsm);
        a = trode_gaps;
        b = fsm_gaps;
        
        trode_gaps_valid    = find(trode_gaps > 5 & trode_gaps < 10);
        inda = trode_gaps_valid;
        
        ttls_fsmall=[];
        ttl_trodesall=[];
        for i=1:length(trode_gaps_valid)
            fsm_trodes_diffs=find(abs(fsm_gaps - trode_gaps(trode_gaps_valid(i))) < 0.05);
            for k=1:length(fsm_trodes_diffs)
                indb=fsm_trodes_diffs(k);
                if (indb+5)>length(fsm_gaps)
                    continue
                end
                if (trode_gaps_valid(i)+5)>length(trode_gaps)
                    continue
                end
                vec1    = trode_gaps(trode_gaps_valid(i)+(0:5));
                vec2    = fsm_gaps(indb+(0:5));
                
                %if one of the distances is too long (timeout), abort
                if(max(abs(diff(vec1)))>30)
                    continue
                end
                
                if(norm(vec1-vec2)>.1)
                    continue
                else
                    ttl_trodes(trode_gaps_valid(i));
                    ttl_trodesall=[ttl_trodesall; ttl_trodes(trode_gaps_valid(i)+(0:5))];
                    ttls_fsmall=[ttls_fsmall; ttls_fsm(indb+(0:5))];
                end
            end
        end
        
        warning off
        p{inc}=polyfit(ttl_trodesall,ttls_fsmall,1);
        warning on
        
        ttl_trodes2fsm=ttl_trodesall*p{inc}(1)+p{inc}(2);
        
        if(isempty(ttl_trodes2fsm))
            max_residual(inc)     = 100;
            totaldur(inc)   = 0;
        else
            % max residual
            max_residual(inc)     = max(abs(ttl_trodes2fsm-ttls_fsmall));
            totaldur(inc)   = (max(ttls_fsmall)-min(ttls_fsmall))/60;
        end
        
        
    end
end
    
ind=find(max_residual<0.02 & totaldur>5);

if(length(ind)<1)
    error('no match!');
end


if(length(ind)>1)
    disp(valore(ind))
    disp(filename(ind))
    error('too many matches!')
end



res.goodval     = max_residual(ind);
res.gooddur     = totaldur(ind);
res.goodp       = p{ind};
res.goodpath    = allpath{ind};
res.behfile     = filename{ind};
res.ratname     = rats{ind};
res.save_path   = save_path;
res.date_str    = date_str;
save(save_path, 'res', 'sess')

