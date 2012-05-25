function projname(cfgin)

%-------------------------------------%
%-INFO--------------------------------%
%-------------------------------------%
%-----------------%
%-project folder
% You can have multiple cfg.nick within a cfg.proj
% A cfg.nick can make use of different cfg.rec
cfg = [];

%-project name
% /data1/projects/PROJ/
cfg.proj = 'PROJ'; % <- TO SPECIFY

%-nick name of the project
% /data1/projects/PROJ/subjects/0001/MOD/NICK/
cfg.nick = 'NICK'; % <- TO SPECIFY
%-----------------%

%-----------------%
%-recording folder
%-recording name
% /data1/projects/PROJ/recordings/REC/
cfg.rec  = 'REC'; % <- TO SPECIFY
% name of the modality used in recordings ('eeg' or 'meg')
cfg.mod  = 'eeg';
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-DIRECTORIES-------------------------%
%-------------------------------------%
%-----------------%
%-expected structure
% /data1/projects/PROJ/
%                     recordings/REC/ -> ln -s /data1/recordings/REC /data1/projects/PROJ/recordings
%                     subjects/ -> subfolders will be created automatically
%                     scripts/NICK/ -> folder containing this script
%                     analysis/ -> subfolders will be created automatically 
%                         log/ -> containing log info and folders
%                         erp/ -> for ERP analysis
%                         pow/ -> for POW and POWCORR analysis
%                         conn/ -> for connectivity analysis
%                     results/NICK/ -> if exists, png will be saved here
%-----------------%

cfg.base = ['/data1/projects/' cfg.proj filesep];
cfg.recd = [cfg.base 'recordings/' cfg.rec filesep];
cfg.recs = [cfg.recd 'subjects/'];

cfg.scrp = [cfg.base 'scripts/' cfg.nick filesep]; % working directory which contains the current file
cfg.qlog = [cfg.scrp 'qsublog/']; % use to keep log files from SGE
cfg.data = [cfg.base 'subjects/']; 
cfg.anly = [cfg.base 'analysis/'];
cfg.rslt = [cfg.base 'results/' cfg.nick filesep]; % folder to save images

cfg.derp = [cfg.anly 'erp/'];
cfg.dpow = [cfg.anly 'pow/'];
cfg.dcon = [cfg.anly 'conn/'];

%-------%
%-uncomment here if necessary
if isdir(cfg.qlog); rmdir(cfg.qlog, 's'); end; mkdir(cfg.qlog);
if isdir(cfg.derp); rmdir(cfg.derp, 's'); end; mkdir(cfg.derp);
if isdir(cfg.dpow); rmdir(cfg.dpow, 's'); end; mkdir(cfg.dpow);
if isdir(cfg.dcon); rmdir(cfg.dcon, 's'); end; mkdir(cfg.dcon);
%-------%
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-CFG---------------------------------%
%-------------------------------------%
%-----------------%
%-subjects index and step index
cfg.subjall = 1:8;
cfg.run = [1:14];

step.nooge = [];
step.sendemail = true;
%-----------------%

%-----------------%
%-which steps belong to 
% a) preprocessing (SGE, keep track of order and names)
% b) subject analysis (SGE, any order)
% c) group analysis (no SGE, any order)
st = 0;
step.prep = [1  2  3];
step.subj = [4  6  8 10];
step.grp  = [5  7  9 11 12 13];
%  4  5 -> erp  6  7 -> erpgrand
%  8  9 -> pow 10 11 -> powgrand
% 12 -> custom function 13 -> write to csv
cfg.clear = {'seldata' 'gclean'}; % clear the output of ...
%-----------------%

%-----------------%
%-elec info
cfg.sens.file = '/data1/toolbox/elecloc/EGI_GSN-HydroCel-256_new_cnfg.sfp'; % only for sens, but labels are lowercase
cfg.sens.dist = 4;
cfg.sens.layout = '/data1/toolbox/elecloc/EGI_GSN-HydroCel-256_new_cnfg.mat';
%-----------------%

%-----------------%
%-vol info
cfg.vol.type = 'template'; % 'template' or 'dipoli' ('dipoli' and the rest use subject-specific MRI)
if strcmp(cfg.vol.type, 'template')
  cfg.vol.template = [cfg.anly 'forward/gosd_avg_volleadsens_spmtemplate_dipoli.mat'];
else
  cfg.vol.mod = 'smri';
  cfg.vol.cond = 't1';
end
%-----------------%

%---------------------------%
%-step preprocessing
%-----------------%
%-01: select data
st = st + 1;
cfg.step{st} = 'seldata';

cfg.rcnd = '_recname-'; % unique identifier for your dataset
cfg.seldata.trialfun = 'trialfun_XXX';

cfg.seldata.selchan = 1:257;
cfg.seldata.label = cellfun(@(x) ['E' num2str(x)], num2cell(cfg.seldata.selchan), 'uni', 0);
%-----------------%

%-----------------%
%-02: gclean
st = st + 1;
cfg.step{st} = 'gclean';

cfg.gtool.fsample = 500; % <- manually specify the frequency (very easily bug-prone, but it does not read "data" all the time)
cfg.gtool.saveall = false;
cfg.gtool.verbose = true;

cfg.gtool.lpfreqn = [.5 / (cfg.gtool.fsample/2)]; % normalized by half of the sampling frequency!

cfg.gtool.bad_samples.MADs = 5;
cfg.gtool.bad_channels.MADs = 7;

cfg.gtool.eog.correction = 50;
cfg.gtool.emg.correction = 30;
%-----------------%

%-----------------%
%-03: redefine trials
st = st + 1;
cfg.step{st} = 'redef';
cfg.redef.event2trl = 'event2trl_XXX';

%-------%
%-preproc before
cfg.preproc1.hpfilter = 'yes';
cfg.preproc1.hpfreq = 0.5;
cfg.preproc1.hpfiltord = 4;
%-------%

%-------%
%-preproc after
cfg.preproc2.reref = 'yes';
cfg.preproc2.refchannel = 'all'; 
cfg.preproc2.implicit = 'E257';
%-------%

%-------%
%-these parameters depend on event2trl_XXX
% they should be removed if not used
cfg.redef.trigger = 'event_of_interest';
cfg.redef.prestim = 2;
cfg.redef.poststim = 2;
%-------%
%-----------------%
%---------------------------%

%---------------------------%
%-ERP
%-----------------%
%-04: timelock analysis
st = st + 1;
cfg.step{st} = 'erp_subj';

cfg.erp.cond = {'cond1*' 'cond2*'};

cfg.erp.preproc.demean = 'yes';
cfg.erp.preproc.baselinewindow = [-.2 0];
cfg.erp.preproc.lpfilter = 'yes';
cfg.erp.preproc.lpfreq = 30;
%-----------------%

%-----------------%
%-06: erp across subjects
st = st + 1;
cfg.step{st} = 'erp_grand';

cfg.gerp.comp = {{'*cond1'} {'*cond1' '*cond2'}};
cfg.cluster.thr = 0.05;

cfg.gerp.chan(1).name = 'occipital';
cfg.gerp.chan(1).chan =  {'E122','E123','E124','E133','E134','E135','E136','E137','E145','E146','E147','E148','E149','E156','E157','E158','E165','E166','E167','E174'};
cfg.gerp.chan(2).name = 'frontal';
cfg.gerp.chan(2).chan = {'E2', 'E3', 'E4', 'E5', 'E6', 'E7', 'E8', 'E9', 'E10', 'E11', 'E12', 'E13', 'E14', 'E15', 'E16', 'E17', 'E19', 'E20', 'E21', 'E22', 'E23', 'E24', 'E27', 'E28', 'E29', 'E30', 'E33', 'E34', 'E35', 'E36', 'E38', 'E39', 'E40', 'E41', 'E42', 'E43', 'E46', 'E47', 'E48', 'E49', 'E50', 'E51', 'E58', 'E186', 'E195', 'E196', 'E197', 'E198', 'E204', 'E205', 'E206', 'E207', 'E213', 'E214', 'E215', 'E222', 'E223', 'E224'};
cfg.gerp.bline = cfg.erp.preproc.baselinewindow;
%-----------------%

%-----------------%
%-07: lcmv on erp
st = st + 1;
cfg.step{st} = 'erpsource_subj';

cfg.erpsource.cond = {'*cond1' '*cond2'};

cfg.erpsource.erp   = cfg.erp;
cfg.erpsource.bline = -.2; % use for covariance (this is the center, the length depends on erp_peak)

cfg.erpsource.areas = 'erp_peak'; % 'manual' or 'erp_peak' (peaks from granderp)
switch cfg.erpsource.areas
  
  case 'manual'
    cfg.erpsource.erp_peak(1).name = 'vis1';
    cfg.erpsource.erp_peak(1).time = 0.10; % center of the time window
    cfg.erpsource.erp_peak(1).wndw = 0.05; % length of the time window
       
  case 'erp_peak'
    cfg.erpsource.refcomp = cfg.gerp.comp{1};
    
end

cfg.erpsource.lambda = '10%';
cfg.erpsource.powmethod = 'lambda1'; % 'trace' or 'lambda1'
%-----------------%

%-----------------%
%-08: lcmv on erp across subjects
st = st + 1;
cfg.step{st} = 'erpsource_grand';

cfg.erpsource.clusterstatistics = 'maxsize'; % 'maxsize' or 'max'
cfg.erpsource.clusteralpha = 0.05;
cfg.erpsource.maxvox = 50; % max number of voxels anyway
%-----------------%
%---------------------------%

%---------------------------%
%-POWER
%-----------------%
%-09: power analysis
st = st + 1;
cfg.step{st} = 'pow_subj';

cfg.pow.cond = {'*cond1' '*cond2'};

cfg.pow.method = 'mtmconvol';
cfg.pow.output = 'pow';
cfg.pow.taper = 'hanning';
cfg.pow.foi = [2:.5:50];
cfg.pow.t_ftimwin = 5  ./ cfg.pow.foi;
cfg.pow.toi = [-1.5:.1:1.5];
%-----------------%

%-----------------%
%-10: pow across subjects
st = st + 1;
cfg.step{st} = 'pow_grand';

cfg.pow.bl.baseline = [-.2 -.1];
cfg.pow.bl.baselinetype = 'relchange';

% for statistics
cfg.gpow.comp = {{'*cond1'} {'*cond1' '*cond2'}};

cfg.gpow.chan(1).name = 'occ';
cfg.gpow.chan(1).chan = {'E87' 'E98' 'E99' 'E100' 'E101' 'E107' 'E108' 'E109' 'E110' 'E117' 'E118' 'E119' 'E126' 'E127' 'E128' 'E129' 'E139' 'E140' 'E141' 'E151' 'E152' 'E153' 'E160' 'E161' 'E162'};
cfg.gpow.chan(2).name = 'frontal';
cfg.gpow.chan(2).chan = {'E5' 'E6' 'E7' 'E8' 'E15' 'E16' 'E23' 'E24' 'E29' 'E30' 'E36' 'E41' 'E42' 'E50' 'E204' 'E205' 'E206' 'E207' 'E213' 'E214' 'E215' 'E224'};
cfg.gpow.freq(1).name = 'alpha';
cfg.gpow.freq(1).freq = [8 12];
cfg.gpow.freq(2).name = 'beta';
cfg.gpow.freq(2).freq = [13 20];

cfg.gpow.stat.time = [0 1];
%-----------------%

%-----------------%
%-11: power analysis at source level
st = st + 1;
cfg.step{st} = 'powsource_subj';

cfg.powsource.cond = {'*cond1' '*cond2'};

cfg.powsource.bline = 0;

cfg.powsource.areas = 'manual'; % 'manual' or 'pow_peak' (peaks from grandpow)
switch cfg.powsource.areas
  
  case 'manual'
    cfg.powsource.pow_peak(1).time = 1;
    cfg.powsource.pow_peak(1).wndw = .6;
    cfg.powsource.pow_peak(1).freq = 10;
    cfg.powsource.pow_peak(1).band = 2;
    cfg.powsource.pow_peak(1).name = 'alpha';
    
  case 'pow_peak'
    cfg.powsource.refcomp = cfg.gpow.comp{1};
    
end

cfg.powsource.lambda = '1%';
cfg.powsource.powmethod = 'trace'; % 'trace' or 'lambda1'
%-----------------%

%-----------------%
%-12: power analysis at source level
st = st + 1;
cfg.step{st} = 'powsource_grand';

cfg.powsource.clusterstatistics = 'maxsize'; % 'maxsize' or 'max'
cfg.powsource.clusteralpha = 0.0001;
cfg.powsource.maxvox = 50; % max number of voxels anyway
%-----------------%
%---------------------------%

%---------------------------%
%-EXTRA FUNCTIONS (put these functions in PROJ_private)
%-----------------%
%-13: custom function
st = st + 1;
cfg.step{st} = 'yourfunction';
cfg.yourfunction.parameter = 'test';
%-----------------%
%---------------------------%

%---------------------------%
%-14: write to csv
st = st + 1;
cfg.step{st} = 'export2csv';
cfg.csvf = [cfg.anly cfg.nick '_complete.csv']; % file to write results to
cfg.export2csv.extrainfo = [];
%---------------------------%
%-------------------------------------%

%-------------------------------------%
%-EXECUTE
%-----------------%
%-use extra info from cfgin
if nargin == 1
  cfg = catstruct(cfg, cfgin);
end
%-----------------%

execute(cfg, step)
%-------------------------------------%
