%%  
function kilosort_preprocess(varargin)

% ---------------------
% written by Emily Jane Dennis 2020-06-14 (during pandemic!)
% purpose is to take in binary files for each tetrode bundle from a 128
% channel (32 tetrode) drive and remove/interpolate giant sections where
% there is huge noise that we want to ignore. We also want to output some
% plots and save them so we can do some quick validation by eye.
%
%
% TODO:
% - clean up ifelse checks for inputs
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
        directorywithbinaries=varargin{1};
        cd directorywithbinaries
    else
        error('input must be in the format of a string leading to a directory')
    end    
    chan=32;    
    ops.fs     = 32000;    
    ops.fshigh = 300;
elseif length(varargin)==2
    chan = varargin{2}
    ops.fs     = 32000;    
    ops.fshigh = 300;
elseif varargin == 3
    chan=varargin{2}
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
    
listofbinaryfiles=dir('*.bin');

for i = 1:length(listofbinaryfiles)
    fname = listofbinaryfiles(i).name;

% first, open the binary file to read
fid=fopen(fname,'r');

% next, name and open a new binary file to write to
fidw = fopen(sprintf('%s_forkilosort.bin',fname(1:end-4)), 'w');



%% k loop here
% now, read in a PORTION of the data. Format it as a matrix with chan rows and
% 1e5 values - we will loop through this for each file until all data is
% read in
    dataRAW = fread(fid, [chan 1e5], 'int16');
    % transpose
    dataRAW = dataRAW';
    % divide by 1000
    dataRAW = double(dataRAW)/1000;

    % apply the filter
    datr = filtfilt(b1, a1, dataRAW);
    
    % find the moving mean of filtered data
        % first we want absolute values, so we square datr, take the means of each
        % row (channel), and then take the square root
    ff = mean(datr.^2, 2).^.5; 
        % for the rows where ff > 1, use a window of every 1000 data points
    ff = movmean(double(ff>1), 1000)<.01;
       
%     if t0 + sum(ff)>size(dat,2)
%        break; 
%     end 
%end of while loop
%     
    dat16 = int16(1000*datr(ff, :)');
    
    fwrite(fidw, dat16, 'int16');
    
    t0 = t0 + sum(ff);
    % tell us how far we are through the file
    sprintf('for file %s we have processed %d of the data',fname,(100*(t0/ops.fs)))
   
%     datr(~ff, :) = 0;
%     plot(abs(fft(mean(datr,2))))
%     drawnow
%     pause


%%
fclose(fid1);
fclose(fid2);
fclose(fid3);
fclose(fidw);

figure;
    plot(abs(fft(mean(datr,2))))
        title('datr2','fontsize',14,'fontweight','bold');
        legend('y','x');
    saveas(gcf,[homedirectory, '_datr2'],'epsc')
    close gcf



%%


end