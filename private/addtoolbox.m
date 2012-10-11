function output = addtoolbox(info)
% add various toolbox:
%   - fieldtrip
%
%   - gtoolbox
%
%   - eventbased
%   - mri2lead
%   - detectsleep (and spm8)
%   - dti
%
%   - project specific (with subdirectories)
% The project-specific folder should be called [info.nick '_private']

ftpath = '/data1/toolbox/fieldtrip/'; % fieldtrip (svn)
spmpath = '/data1/toolbox/spm8/'; % no svn
eegpath = '/data1/toolbox/eeglab/'; % eeglab (svn, but only for plotting)

%-------------------------------------%
%-FIELDTRIP (always necessary)
%-----------------%
%-addpath
addpath(ftpath)
global ft_default
ft_default.checksize = Inf; % otherwise it deletes cfg field which are too big
ft_defaults
addpath([ftpath 'qsub/'])
% addcleanpath([], 'compat') % ft_defaults keeps on readding compat, just
% remove the folders "compat" and "utilities/compat" from the fieldtrip folder
%-----------------%

%-----------------%
%-get fieldtrip version
try % so many thing can go wrong here
  [~, ftver] = system(['awk ''NR==4'' ' ftpath '.svn/entries']);
catch ME
  ftver = ME.message;
end
output = sprintf('fieldtrip:\t%s', ftver);
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-POTENTIAL TOOLBOXES
%---------------------------%
%-check which toolboxes are present (git)
toolbox = {'eegpipe' 'eventbased' 'detectsleep' 'mri2lead' 'dti' [info.nick '_private']};
dirtools = dir(info.scrp);
toolbox = intersect(toolbox, {dirtools.name}); % only those that are present
%---------------------------%

%---------------------------%
%-add present toolbox
for i = 1:numel(toolbox)
  
  tpath = [info.scrp toolbox{i} filesep];
  
  if strcmp(toolbox{i}, 'eegpipe')

    addcleanpath(eegpath, {'fieldtrip' 'octavefunc'}) % no fieldtrip or octave functions
    addcleanpath(tpath, 'matlab_bgl')
    
  else
    addpath(genpath(tpath)) % with subdirectories
    
  end
  
  %-----------------%
  %-get git version
  try % so many thing can go wrong here
    [~, tver] = system(['git --git-dir=' tpath '.git log |  awk ''NR==1'' | awk ''{print $2}''']);
  catch ME
    tver = ME.message;
  end
  outtmp = sprintf('%s:\t%s', toolbox{i}, tver);
  output = [output outtmp];
  %-----------------%
  
  %-----------------%
  %-add SPM if using detectsleep
  if strcmp(toolbox{i}, 'detectsleep')
    
    addpath(spmpath)
    spm defaults eeg
    addcleanpath([], 'spm8/external/fieldtrip')
    
  end
  %-----------------%
  
end
%---------------------------%
%-------------------------------------%

%-------------------------------------%
%-Remove folders before adding to the path, to avoid naming conflicts
function addcleanpath(tpath, nopath)

if ~iscell(nopath)
  nopath = {nopath};
end

if isempty(tpath)
  oldpath = path;
else
  oldpath = genpath(tpath);
end

goodpath = regexp(oldpath, ':', 'split');
for i = 1:numel(nopath)
  goodpath = goodpath(cellfun(@isempty, regexp(goodpath, nopath{i})));
end

if isempty(tpath)
  path(sprintf('%s:', goodpath{:}))
else
  addpath(sprintf('%s:', goodpath{:}))
end
%-------------------------------------%
