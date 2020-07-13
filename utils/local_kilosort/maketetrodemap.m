%%
% goal: to make tetrode maps compatible with kilosort2 data
% inspired by and borrowed from BeataKaminska-Kordowska
% created by EJ Dennis 20190823
%% 
function maketetrodemap(numberoftetrodes,samplingrate,filename)

if nargin < 2
    error('please enter the number of tetrodes and sampling rate')
end

 if~isnumeric(numberoftetrodes) || ~isnumeric(samplingrate)
    error('only enter numbers for the number of tetrodes and sampling rate')
 end
    
if nargin==2
    filename = sprintf('%dtetrodes_channelmap.mat',numberoftetrodes);
end

if nargin==3
    if ~length(strfind(filename,'.mat'))
        error('enter no filename or set the output filename to a .mat file')
    end
end
    
Nchannels=(numberoftetrodes*4);
chanMap=(1:Nchannels);
chanMap0ind=(0:(Nchannels-1));
connected=ones(Nchannels,1);
fs=samplingrate;
kcoords=repelem(1:numberoftetrodes,4)';
xcoords=repmat(1:4,1,numberoftetrodes);
ycoords=kcoords;

save(filename,'Nchannels','chanMap','chanMap0ind','connected','fs','kcoords','xcoords','ycoords');
%
%

end
