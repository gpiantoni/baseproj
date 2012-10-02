function info = info_nickname
%INFO_NICKNAME basic information about the TEMPLATE project
%
% You need to specify:
%  PROJNAME (

%-------------------------------------%
%-INFO--------------------------------%
%-------------------------------------%
%-----------------%
%-project folder
info = [];
% name of the project according to /data1/projects/PROJNAME/
info.proj = 'PROJNAME';
% name to be used in PROJNAME/subjects/0001/MOD/CONDNAME/
info.nick = 'NICKNAME';
%-----------------%

%-----------------%
%-recording folder
% name of the recordings according to /data1/recordings/RECNAME/
info.rec  = 'RECNAME';
% name of the modality used in recordings ('eeg' or 'meg')
info.mod  = 'eeg';
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-DIRECTORIES-------------------------%
%-------------------------------------%
info.base = ['/data1/projects/' info.proj filesep];
info.recd = [info.base 'recordings/' info.rec filesep];
info.recs = [info.recd 'subjects/'];

info.scrp = [info.base 'scripts/' info.nick filesep]; % working directory which contains the current file % <- FIXTHIS
info.qlog = [info.scrp 'qsublog/']; % use to keep log files from SGE
info.data = [info.base 'subjects/']; 
info.anly = [info.base 'analysis/'];
info.rslt = [info.base 'results/' info.nick filesep]; % folder to save images

info.derp = [info.anly 'erp/'];
info.dpow = [info.anly 'pow/'];
info.dcor = [info.anly 'corr/'];
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-DATASET-----------------------------%
%-------------------------------------%
%-----------------%
%-elec info
info.sens.file = '/data1/toolbox/elecloc/easycap_61_FT.mat'; % it uses 'elec' with 'E1' electrode names
info.sens.dist = 50; % same units as channel location
info.sens.layout = '/data1/toolbox/elecloc/easycap_61_FT.mat';
%-----------------%

%-----------------%
%-source info
info.vol.type = 'dipoli'; % 'template' or 'dipoli' ('dipoli' 'bemcp' 'openmeeg' and the rest use subject-specific MRI)
if strcmp(info.vol.type, 'template')
  info.vol.template = [info.anly 'forward/vigd_volleadsens_spmtemplate_dipoli.mat'];
else
  info.vol.mod = 'smri';
  info.vol.cond = 't1';
end
info.sourcespace = 'surface'; % 'surface' or 'volume' or 'volume_warp'
%-----------------%
%-------------------------------------%