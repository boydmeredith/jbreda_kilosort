%%  
function kilosort_preprocess(varargin)

% ---------------------
% written by Emily Jane Dennis 2020-06-14 (during pandemic!)
% purpose is to take in binary files for each tetrode bundle from a 128
% channel (32 tetrode) drive and remove/zero/interpolate giant sections where
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

if isempty(varargin)
    homedirectory=pwd;
    chan=32;
    ops.fs     = 32000;    
    ops.fshigh = 300;        
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
    ops.fshigh = 400;
elseif length(varargin)==2
    chan = varargin{2};
    ops.fs     = 32000;    
    ops.fshigh = 300;
elseif varargin == 3
    chan=varargin{2};
    ops.fs = varargin{3};
    ops.fshigh=300;
else
    ops.fs=varargin{3};
    ops.fshigh=varargin{4};
end

    % make a filter for the data based on ops inputs/defaults
    [b1, a1] = butter(3, ops.fshigh/ops.fs, 'high'); 
    % butterworth filter with only 3 nodes (otherwise it's unstable for float32)
    % Wn (ops.fshigh/ops.fs) is the cutoff frequency, and must be between 0.0 and 1.0. 1.0 is half the
    % sample rate
    % high means it's a highpass filter
    
    %outputs filter coefficients b1 (numerator) and a1 (denominator)
   
% make list of files to process
listofbinaryfiles=dir('*.bin');
%make empty fftosave
fftosave=[];

for i = 1:length(listofbinaryfiles)

    % first, open the binary file to read
    fname = listofbinaryfiles(i).name;
    fid=fopen(fname,'r');

    % next, name and open a new binary file to write to
    fidw = fopen(sprintf('%s_forkilosort.bin',fname(1:end-4)), 'w');

    while 1
    % now, read in a PORTION of the data. Format it as a matrix with chan rows and
    % 1e5 values - we will loop through this for each file until all data is
    % read in
        dataRAW = fread(fid, [chan 1e5], 'int16');
        sizeofdata=size(dataRAW);
        if sizeofdata(2) == 0
            break %breaks the while loop
        end

        % transpose
        dataRAW = dataRAW';
        % divide by 1000
        dataRAW = double(dataRAW)/1000;

        % apply the filter
        datr = filtfilt(b1, a1, dataRAW);

        % make a binary 'mask' for the data, looking for big changes to
        % remove
            % first we want absolute values, so we square datr, take the means of each
            % row (channel), and then take the square root
        ff = mean(datr.^2, 2).^.5; 
            % for the rows where ff > 1, use a window of every 1000 data
            % points and if the moving average is above 1
        ff1 = movmean(double(ff>1), 2000);
        ff2=ff1<.01;
        
        % TODO add if statement once we have a favorite output for default

        % TODO add as option, remove noise and save binary mask for data
        % points
%         datr=datr(ff2, :);
%         newff=~ff2;
%         fftosave=[fftosave newff];

        %save with zeroed out
       datr(~ff2, :) = 0;
        
        %save as interp'd
%        TODO pull out good/bad times, interp end of good blocks to start
%        of next good block, steal from rmartifacts

        %TODO end if statement
        
        % save
        dat16 = int16(1000*datr');
        fwrite(fidw, dat16, 'int16');
    end
    %%

if ispc
    delim='\';
else
    delim='/';
end

fclose(fid);
fclose(fidw);

%if running as 'remove noise' mode
%save([homedirectory,delim,fname, '_timemask.mat'],fftosave)

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
    
sprintf('finished file %d of %d files to process',i,length(listofbinaryfiles))

end


%%



end