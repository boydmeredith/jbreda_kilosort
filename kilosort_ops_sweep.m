%---------------------
% written by Jess Breda 20200717
% purpose is to run kilosort on single file with multiple different ops
% configurations
%
% TODO:
% - adjust kilosort main into fx
% 
%
% INPUT PARAMETERS:
% none
%
% OPTIONAL PARAMETERS:
% - string directing us to a folder with subfolders containing config files
% to sweep over
% note: .bin file should be in the first folder in the directory with
% config files
% note: config files = StandardConfig_8tetrodes_ParamSweeps.m (edit ops in this) and
% 8tetrode_channelmap.mat (just leave this along)
%
% RETURNS:
% - none, but calls kilosort & runs on file of interest with associted
% configurations
%
% 
%
% = EXAMPLE CALLS:
% - kilosort_ops_sweep('directory/with/config/folders/here')
% ---------------------
%%
%determine computer type
if ispc
    delim='\';
else
    delim='/';
end





