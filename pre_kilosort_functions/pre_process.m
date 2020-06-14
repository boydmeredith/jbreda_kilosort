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

if ~isempty(varargin)
    %if user provides input, check that it is a string for a directory
    if isfolder(varargin{1})
        homedirectory=pwd;
        directorywithbinaries=varargin{1};
        cd directorywithbinaries
    else 
        error('input must be in the format of a string leading to a directory')
    end
else
    % if user does not input a directory- run here and save things to this folder
    homedirectory=pwd;
end

if length(varargin)<3
    ops.fshigh = 300;
    ops.fs     = 32000;    
    % make a filter for the data
    [b1, a1] = butter(3, ops.fshigh/ops.fs, 'high'); % butterworth filter with only 3 nodes (otherwise it's unstable for float32)
else
end

listofbinaryfiles=dir('*.bin');

%% NEED TO LOOP THIS THROUGH THE LIST! FIRST I'M MAKING THE FIRST LOOP.

for i = 1:length(listofbinaryfiles)
    fname = listofbinaryfiles(i).name;

% while loop started here

% first, open the binary file to read
fid=fopen(fname,'r')

% next, open the binary file to write
fidw = fopen('xxx.bin', 'w');

% now, read in a PORTION of the data. Format it as a matrix with X rows and
% Y values

% d1 = fread(fid1, [32 2e6], 'int16');
% d2 = fread(fid2, [32 2e6], 'int16');
% d3 = fread(fid3, [32 2e6], 'int16');
    dataRAW = fread(fid1, [32 1e5], 'int16');
    dataRAW = dataRAW';
    dataRAW = double(dataRAW)/1000;
    
    
    % apply the filter
    datr = filtfilt(b1, a1, dataRAW); % causal forward filter
    
    % find the moving mean
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