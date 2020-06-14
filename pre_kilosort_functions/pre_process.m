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
% - 
%
% INPUT PARAMETERS:
% - none needed - it should be able to be run from a local folder BUT 
%   it would be nice to have an optional input for a string directing us to
%   a folder
% 
% OPTIONAL PARAMETERS:
% - 
% 
% RETURNS:
% - 
% 
% = EXAMPLE CALLS:
% - 
% ---------------------

if ~isempty(varargin)
    %if user provides input, check that it is a string for a directory
    if isdir(varargin{1})
        homedirectory=pwd;
        cd varargin{1}
    else 
        error('input must be in the format of a string leading to a directory')
    end
else
    % if user does not input a directory- run here and save things to this folder
    homedirectory=pwd;
end


fname = dir('*_firstbundle.bin');
fid1 = fopen(fname, 'r');
fname = 'C:/DATA/emily\Dennis_secondbundle.bin';
fid2 = fopen(fname, 'r');
fname = 'C:/DATA/emily\Dennis_thirdbundle.bin';
fid3 = fopen(fname, 'r');

fidw = fopen('//dm11/pachitariulab/spikes/temp/concat96.bin', 'w');

% d1 = fread(fid1, [32 2e6], 'int16');
% d2 = fread(fid2, [32 2e6], 'int16');
% d3 = fread(fid3, [32 2e6], 'int16');

t0 = 0;

while 1
    ops.fshigh = 300;
    ops.fs     = 32000;
    
    
    d1 = fread(fid1, [32 1e5], 'int16');
    d2 = fread(fid2, [32 1e5], 'int16');
    d3 = fread(fid3, [32 1e5], 'int16');
    dataRAW = cat(1, d1, d2, d3);
%     dataRAW = d1;
    
    dataRAW = dataRAW';
    dataRAW = double(dataRAW)/1000;
    
%     dat2 = notch_filter(dataRAW, ops.fs, 3125, 150, 3);
    
    [b1, a1] = butter(3, ops.fshigh/ops.fs, 'high'); % butterworth filter with only 3 nodes (otherwise it's unstable for float32)
    
    % next four lines should be equivalent to filtfilt (which cannot be used because it requires float64)
    datr = filtfilt(b1, a1, dataRAW); % causal forward filter
    
    ff = mean(datr.^2, 2).^.5;
    ff = movmean(double(ff>1), 1000)<.01;
       
%     if t0 + sum(ff)>size(dat,2)
%        break; 
%     end
%     
    dat16 = int16(1000*datr(ff, :)');
    
    fwrite(fidw, dat16, 'int16');
    
    t0 = t0 + sum(ff);
   
    disp(t0/ops.fs)
   
%     datr(~ff, :) = 0;
%     plot(abs(fft(mean(datr,2))))
%     drawnow
%     pause
end
fclose(fid1);
fclose(fid2);
fclose(fid3);
fclose(fidw);


%%

plot(abs(fft(mean(dat, 1))))
end