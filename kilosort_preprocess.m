%%  
function kilosort_preprocess(varargin)

% ---------------------
% written by Emily Jane Dennis 2020-06-14 (during pandemic!)
% purpose is to take in binary files for each tetrode bundle from a 128
% channel (32 tetrode) drive and zero giant sections where
% there is huge noise that we want to ignore. We also want to output some
% plots and save them so we can do some quick validation by eye.
%
%
% TODO:
% - clean up ifelse checks for inputs
% - add more plots to outputs
% - come back after some kilosort testing and add a if/else statement for
% if we should be saving the new binary files with the bad sections
% removed, zerod, or interpd
% 
%
% INPUT PARAMETERS:
% - none needed - it should be able to be run from a local folder
% 
% OPTIONAL PARAMETERS:
% - string directing us to a folder
% - chan = number of channels in the binary file, defaults to 32
% - ops.fs - param for butterworth filter
% - ops.fshigh - param for butterworth filter
% 
% RETURNS:
% - nothing, but saves a new binary file and outputs several plots for
% quality control
% 
% = EXAMPLE CALLS:
% - 
% ---------------------
%% inputs
if isempty(varargin)
    homedirectory=pwd;
    chan=32;
    ops.fs     = 32000;    
    ops.fshigh = 300;
%     threshold = 0.5
%     window = 10000

%if user provides input, check that it is a string for a directory
elseif length(varargin)==1
    if isfolder(varargin{1})
        homedirectory=pwd;
        directorywithbinaries=varargin{1}; %#ok<NASGU>
        cd directorywithbinaries
    else
        error('input must be in the format of a string leading to a directory')
    end    
    chan=32;    
    ops.fs     = 32000;    
    ops.fshigh = 300;
%     threshold = 0.5
%     window = 10000
    
elseif length(varargin)==2
    chan = varargin{2};
    ops.fs     = 32000;    
    ops.fshigh = 300;
%     threshold = 0.5
%     window = 10000
    
elseif varargin == 3
    chan=varargin{2};
    ops.fs = varargin{3};
    ops.fshigh=300;
%     threshold = 0.5
%     window = 10000
    
elseif varagin == 4
    chan=varargin{2};
    ops.fs = varargin{3};
    ops.fshigh =varagin{4}
%     threshold = 0.5
%     window = 10000
    
% elseif varagin == 5
%     chan=varargin{2};
%     ops.fs = varargin{3};
%     ops.fshigh = varagin{4}
%     threshold = varagin{5}
%     window = 10000
% else
%     chan=varargin{2};
%     ops.fs = varargin{3};
%     ops.fshigh = varagin{4}
%     threshold = varagin{5}
%     window = varagin{6}
    
end
%% filter & initialization

% make a filter for the data based on ops inputs/defaults 
% butterworth filter with only 3 nodes (otherwise it's unstable for float32)
% Wn (ops.fshigh/ops.fs) is the cutoff frequency, and must be between 0.0 and 1.0. 1.0 is half the
% sample rate
% high means it's a highpass filter
%outputs filter coefficients b1 (numerator) and a1 (denominator)
[b1, a1] = butter(3, ops.fshigh/(ops.fs/2), 'high');
    
% make list of files to process
listofbinaryfiles=dir('*.bin');
%make empty fftosave
fftosave=[];

%determine computer type
if ispc
    delim='\';
else
    delim='/';
end

% for optimizing filter (TODO: add this to function inputs)
threshold = 0.5
window = 10000
jobid = randi(1000)


%% loop over binary files
for i = 1:length(listofbinaryfiles)

    % first, open the binary file to read
    fname = listofbinaryfiles(i).name;
    fid=fopen(fname,'r');

    
    % next, name and open a new binary file to write to, and put it in it's
    % own folder
    mkdir(fullfile(homedirectory, delim, sprintf('%s_%s_T%s_W%s_forkilosort%s',num2str(jobid),fname(1:end-4), num2str(threshold*10), num2str(window))))
    kilosortbinfolder = [homedirectory, delim, sprintf('%s_%s_T%s_W%s_forkilosort',num2str(jobid),fname(1:end-4), num2str(threshold*10), num2str(window))]
    
    addpath(kilosortbinfolder)
    cd(kilosortbinfolder)
    
    fidw = fopen(sprintf('%s_T%s_W%s_forkilosort.bin',fname(1:end-4), num2str(threshold*10), num2str(window)), 'w');

    while 1
    % now, read in a PORTION of the data. Format it as a matrix with chan rows and
    % 1e5 values - we will loop through this for each file until all data is
    % read in
        dataRAW = fread(fid, [chan 1e6], 'int16');
        sizeofdata=size(dataRAW);
        if sizeofdata(2) == 0
            break %breaks the while loop
        end

        % transpose
        dataRAW = dataRAW';
        % divide by 1000 because the filter prefers that
        dataRAW = double(dataRAW)/1000;
               
        % apply the filter
        datr = filtfilt(b1, a1, dataRAW);
        dataFILT = datr; %renaming now so I can plot later without overwriting

        % make a binary 'mask' for the data, looking for big changes to
        % remove
            % first we want absolute values, so we square datr, take the means of each
            % row (channel), and then take the square root
        dataABSVAL = mean(datr.^2, 2).^.5; 
            % create a binary mask where dataABSVAL > threshold
            % then, take moving mean of mask with window size
        mask1MEAN = movmean(double(dataABSVAL>threshold), window);
        
        % binary mask 'signal' = 1, 'noise' = 0
        mask2= mask1MEAN < 0.00001;
        
        % mask data & set noise to 0
        dataMASK = datr .* mask2;
        
        % TODO add if statement once we have a favorite output for default

        % TODO add as option, remove noise and save binary mask for data
        % points
%         datr=datr(ff2, :);
%         newff=~ff2;
%         fftosave=[fftosave newff];
        %save as interp'd
%        TODO pull out good/bad times, interp end of good blocks to start
%        of next good block, steal from rmartifacts

        %TODO end if statement
        
        % save
        dat16 = int16(1000*dataMASK');
        fwrite(fidw, dat16, 'int16');
    end

fclose(fid);
fclose(fidw);

%% plots for debugging

%  figure(200);subplot(5,1,1);plot(dataRAW(:,2))
%         title('data','fontsize',14,'fontweight','bold')
%      subplot(5,1,2);plot(ff);
%         title('abs mean of filter','fontsize',14,'fontweight','bold')
%      subplot(5,1,3);plot(ff1);
%         title('rolling mean of filter','fontsize',14,'fontweight','bold')
%      subplot(5,1,4);plot(ff2);
%         title('binarized mask for data','fontsize',14,'fontweight','bold');
%     subplot(5,1,5);plot(datr);
%         title('saved data')
%     saveas(gcf,[homedirectory,delim,fname, '_exampleplot'],'epsc')
%     close gcf


% see what is happening on 8 channels
% figure(1); 
% for z = 1:8
% subplot(8,1,z); plot(dataMASK(:,z)); ylim([-1,1])
% end

% post filter plot
% figure(2); 
% for z = 1:8
% subplot(8,1,z); plot(datr(:,z)); ylim
% end


% comparing absolute value & filtered data
% test_chan = 6
% clf;
% figure(1); plot(datr(:,test_chan));
% hold on
% plot(ff); ylim([0, 1]);
% legend('butter data', 'abs val data'); title(test_chan);

% playing with window sizes

% figure(3); subplot(5,1,1); plot(ff_1000); title('window: 1000'); ylim([0, 0.6]);
% subplot(5,1,2); plot(ff_2000); title('window: 2000');ylim([0, 0.6]);
% subplot(5,1,3); plot(ff_3000); title('window: 3000');ylim([0, 0.6]);
% subplot(5,1,4); plot(ff_4000); title('window: 4000');ylim([0, 0.6]);
% subplot(5,1,5); plot(ff_10000); title('window: 10000');ylim([0, 0.6]);


% playing with threshold

% ff_10 = movmean(double(dataABSVAL>1), 2000); % should be 10 but 
% ff_5 = movmean(double(dataABSVAL>0.5), 2000);
% ff_7 = movmean(double(dataABSVAL>0.75), 2000);
% ff_4 = movmean(double(dataABSVAL>0.4), 2000);
% ff_3 = movmean(double(dataABSVAL>0.3), 2000);
% ff_2 = movmean(double(dataABSVAL>0.2), 2000);
% 
% ffs = [ff_10, ff_5, ff_7, ff_4, ff_3, ff_2];
% ff2s = ffs < 0.01;
% not sure how to pass this into later
% set(gcf,'color','w');

% ff5 = movmean(double(ff>0.5), window);
% ff5_2 = ff1 <.01;
% dataMASK_5 = datr .* ff5_2;

% overall
% clf;
% figure(3);subplot(5,1,1); plot(datr(:,6)); title('raw data');
% subplot(5,1,2);plot(ff); title('abs value');
% subplot(5,1,3); plot(ff1); title('rolling mean');
% subplot(5,1,4); plot(ff2); title('mask');
% subplot(5,1,5); plot(dataMASK(:,6)); title('masked data');
%%

sprintf('finished file %d of %d files to process',i,length(listofbinaryfiles))
cd .. %return to directory with other binary files

end




end