function output = addtoolbox(cfg)
% add various toolbox:
%   - fieldtrip
%
%   - gtoolbox
%
%   - eventbased
%   - mri2lead
%   - detectsleep
%
%   - project specific (with subdirectories)
% The project-specific folder should be called [cfg.cond '_private']

%-------------------------------------%
%-FIELDTRIP (always necessary)
ftpath = '/data1/toolbox/fieldtrip/'; % fieldtrip (svn)

%-----------------%
%-addpath
addpath(ftpath) 
global ft_default
ft_default.checksize = Inf; % otherwise it deletes cfg field which are too big
ft_defaults
addpath([ftpath 'qsub/'])
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
%-GTOOLBOX
gpath = [cfg.scrp 'gtoolbox/']; % gtoolbox (bitbucket, with subdirectories)

if isdir(gpath)
  %-----------------%
  %-add gtool toolbox (here, otherwise matlab does not recognize "import"
  % statement in subfunctions) and remove matlab_bgl, because one function
  % has the same name as a built-in functions, giving tons of warnings
  oldpath = genpath(gpath);
  dirs = regexp(oldpath, ':', 'split');
  goodpath = dirs(cellfun(@isempty, regexp(dirs, 'matlab_bgl')));
  addpath(sprintf('%s:', goodpath{:}))
  %-----------------%
  
  %-----------------%
  %-get gtoolbox version
  gtool = dir(gpath);
  for i = 3:numel(gtool)
    try % so many thing can go wrong here
      [~, gver] = system(['hg --debug tags --cwd ' gpath gtool(i).name ' | awk ''{print $2}''']);
    catch ME
      gver = ME.message;
    end
    outtmp = sprintf('gtoolbox %s:\t%s', gtool(i).name, gver);
    output = [output outtmp];
  end
  %-----------------%
end
%-------------------------------------%

%-------------------------------------%
%-POTENTIAL TOOLBOXES
%-----------------%
%-check which toolboxes are present (git)
toolbox = {'eventbased' 'detectsleep' 'mri2lead' [cfg.cond '_private']};
dirtools = dir(cfg.scrp);
toolbox = intersect(toolbox, {dirtools.name}); % only those that are present
%-----------------%

%-----------------%
%-add present toolbox
for i = 1:numel(toolbox)
  
  tpath = [cfg.scrp toolbox{i} filesep];
  addpath(genpath(tpath)) % with subdirectories
  
  %-------%
  %-get git version
  try % so many thing can go wrong here
    [~, tver] = system(['git --git-dir=' tpath '.git log |  awk ''NR==1'' | awk ''{print $2}''']);
  catch ME
    tver = ME.message;
  end
  outtmp = sprintf('%s:\t%s', toolbox{i}, tver);
  output = [output outtmp];
  %-------%
  
end
%-----------------%
%-------------------------------------%