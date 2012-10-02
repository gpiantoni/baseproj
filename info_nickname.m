function info = info_NICKNAME
%INFO_NICKNAME basic information about the TEMPLATE project
%
% You need to specify:
%  PROJNAME: the name of the project according to /data1/projects/PROJNAME/
%  NICKNAME: name to be used in PROJNAME/scripts/NICKNAME/ and in 
%            PROJNAME/subjects/0001/MOD/CONDNAME/ 
%  RECNAME: name of the recordings according to /data1/recordings/RECNAME/
%  MOD: name of the modality used in recordings ('eeg' or 'meg')

%-------------------------------------%
%-INFO--------------------------------%
%-------------------------------------%
%-----------------%
%-project folder
info = [];
info.proj = 'PROJNAME';
info.nick = 'NICKNAME';
%-----------------%

%-----------------%
%-recording folder
info.rec  = 'RECNAME';
info.mod  = 'eeg';
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-DIRECTORIES-------------------------%
%-------------------------------------%
info.base = ['/data1/projects/' info.proj filesep];
info.recd = [info.base 'recordings/' info.rec filesep];
info.recs = [info.recd 'subjects/'];

info.scrp = [info.base 'scripts/' info.nick filesep]; % working directory which contains the current file
info.qlog = [info.scrp 'qsublog/']; % use to keep log files from SGE
info.data = [info.base 'subjects/']; 
info.anly = [info.base 'analysis/'];
info.rslt = [info.base 'results/' info.nick filesep]; % folder to save images

info.derp = [info.anly 'erp/'];
info.dpow = [info.anly 'pow/'];
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-DATASET-----------------------------%
%-------------------------------------%
%-----------------%
%-elec info
info.sens.file = '/path/to/sensors/location/in/3D.mat';
info.sens.dist = 50; % same units as channel location
info.sens.layout = '/path/to/sensors/layout/in/2D.mat';
%-----------------%

%-----------------%
%-source info
info.vol.type = 'dipoli'; % 'template' or 'dipoli' ('dipoli' 'bemcp' 'openmeeg' and the rest use subject-specific MRI)
if strcmp(info.vol.type, 'template')
  info.vol.template = '/path/to/template/file.mat'; % which contains "vol" "lead" "elec"
else
  info.vol.mod = 'smri';
  info.vol.cond = 't1';
end
info.sourcespace = 'surface'; % 'surface' or 'volume' or 'volume_warp'
%-----------------%
%-------------------------------------%