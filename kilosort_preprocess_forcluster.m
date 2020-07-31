%%  
function kilosort_preprocess_forcluster(varargin)

% ---------------------
% written by Emily Jane Dennis 2020-06-14 (during pandemic!) 
% Edited by Jess Breda 2020-07 (just literally all july)
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
% - make threshold and window optional inputs
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
    threshold = 0.5;
    window = 10000;
    chan=32;
    ops.fs     = 32000;    
    ops.fshigh = 300;
   

%if user provides input, check that it is a string for a directory
elseif length(varargin)==1
    if isfolder(varargin{1})
        homedirectory=varargin{1}; %#ok<NASGU>
        cd(homedirectory)
    else
        error('input must be in the format of a string leading to a directory')
    end    
    threshold = 0.5;
    window = 10000;
    chan=32;
    ops.fs     = 32000;    
    ops.fshigh = 300;
    
elseif length(varargin)==2
     if isfolder(varargin{1})
        homedirectory=varargin{1}; %#ok<NASGU>
        cd(homedirectory)
    else
        error('input must be in the format of a string leading to a directory')
    end 
    threshold = varargin{2};
    window = 10000;
    chan=32;
    ops.fs     = 32000;    
    ops.fshigh = 300;
  
elseif length(varargin) == 3
     if isfolder(varargin{1})
        homedirectory=varargin{1}; %#ok<NASGU>
        cd(homedirectory)
    else
        error('input must be in the format of a string leading to a directory')
    end 
    threshold = varargin{2};
    window = varargin{3};
    chan=32;
    ops.fs     = 32000;    
    ops.fshigh = 300;
    
elseif length(varargin) == 4
     if isfolder(varargin{1})
        homedirectory=varargin{1}; %#ok<NASGU>
        cd(homedirectory)
    else
        error('input must be in the format of a string leading to a directory')
    end 
    threshold = varargin{2};
    window = varargin{3};
    chan = varargin{4};
    ops.fs     = 32000;    
    ops.fshigh = 300;

elseif length(varargin) == 5
     if isfolder(varargin{1})
        homedirectory=varargin{1}; %#ok<NASGU>
        cd(homedirectory)
    else
        error('input must be in the format of a string leading to a directory')
    end 
    threshold = varargin{2};
    window = varargin{3};
    chan = varargin{4};
    ops.fs     = varargin{5};    
    ops.fshigh = 300;
else
     if isfolder(varargin{1})
        homedirectory=varargin{1}; %#ok<NASGU>
        cd(homedirectory)
    else
        error('input must be in the format of a string leading to a directory')
    end 
    threshold = varargin{2};
    window = varargin{3};
    chan = varargin{4};
    ops.fs     = varargin{5};    
    ops.fshigh = varargin{6};
    
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

%% loop over binary files
for i = 1:length(listofbinaryfiles)

    % first, open the binary file to read
    fname = listofbinaryfiles(i).name;
    fid=fopen(fname,'r');

    
    % next, name and open a new binary file to write to, and put it in it's
    % own folder
    mkdir(fullfile(homedirectory, delim, sprintf('%s_T%s_W%s_forkilosort%s',fname(1:end-4), num2str(threshold*10), num2str(window))))
    kilosortbinfolder = [homedirectory, delim, sprintf('%s_T%s_W%s_forkilosort',fname(1:end-4), num2str(threshold*10), num2str(window))]
    
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
        
        % save
        dat16 = int16(1000*dataMASK');
        fwrite(fidw, dat16, 'int16');
    end

fclose(fid);
fclose(fidw);

sprintf('finished file %d of %d files to process',i,length(listofbinaryfiles))
cd .. %return to directory with other binary files

end

end