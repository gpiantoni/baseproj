function output = addtoolbox(cfg)
% add various toolbox:
%   - fieldtrip
%   - gtoolbox
%   - eventbased
%   - project specific

%-------------------------------------%
%-toolbox names
%-------%
ftpath = '/data1/toolbox/fieldtrip/'; % fieldtrip (svn)
gpath = [cfg.scrp 'gtoolbox/']; % gtoolbox (bitbucket, with subdirectories)
epath = [cfg.scrp 'eventbased/']; % eventbased toolbox (github)
ppath = [cfg.scrp cfg.proj '_private/']; % project private (github)
%-------%

%-----------------%
%-addpath
addpath(ftpath) 
ft_defaults
addpath([ftpath 'qsub/'])

%-------%
%-add gtool toolbox (here, otherwise matlab does not recognize "import"
% statement in subfunctions) and remove matlab_bgl, because one function
% has the same name as a built-in functions, giving tons of warnings
oldpath = genpath(gpath);
dirs = regexp(oldpath, ':', 'split');
goodpath = dirs(cellfun(@isempty, regexp(dirs, 'matlab_bgl')));
addpath(sprintf('%s:', goodpath{:}))
%-------%

addpath(epath)
addpath(ppath)
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-keep track of version
%-----------------%
%-get fieldtrip version
try % so many thing can go wrong here
  [~, ftver] = system(['awk ''NR==4'' ' ftpath '.svn/entries']);
catch ME
  ftver = ME.message;
end
output = sprintf('fieldtrip:\t\t%s', ftver);
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

%-----------------%
%-get eventbased version
try % so many thing can go wrong here
  [~, ever] = system(['git --git-dir=' epath '.git log |  awk ''NR==1'' | awk ''{print $2}''']);
catch ME
  ever = ME.message;
end
outtmp = sprintf('eventbased:\t\t%s', ever);
output = [output outtmp];
%-----------------%

%-----------------%
%-get project_private version
try % so many thing can go wrong here
  [~, pver] = system(['git --git-dir=' ppath '.git log |  awk ''NR==1'' | awk ''{print $2}''']);
catch ME
  pver = ME.message;
end
outtmp = sprintf('%s_private:\t\t%s', cfg.proj, pver);
output = [output outtmp];
%-----------------%
%-------------------------------------%