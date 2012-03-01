function projname(cfgin)

%-------------------------------------%
%-INFO--------------------------------%
%-------------------------------------%
%-----------------%
%-project folder
cfg = [];
% name of the project according to /data1/projects/PROJNAME/
cfg.proj = 'PROJNAME'; % <- FIXTHIS
% name to be used in PROJNAME/subjects/0001/MOD/CONDNAME/
% ideally identical to cfg.proj
cfg.cond = 'CONDNAME'; % <- FIXTHIS
%-----------------%

%-----------------%
%-recording folder
% name of the recordings according to /data1/recordings/RECNAME/
cfg.rec  = 'RECNAME'; % <- FIXTHIS
% name of the modality used in recordings ('eeg' or 'meg')
cfg.mod  = 'eeg';
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-DIRECTORIES-------------------------%
%-------------------------------------%
cfg.base = ['/data1/projects/' cfg.proj filesep];
cfg.recd = [cfg.base 'recordings/' cfg.rec filesep];
cfg.recs = [cfg.recd 'subjects/'];

cfg.scrp = [cfg.base 'scripts/' cfg.cond filesep]; % working directory which contains the current file % <- FIXTHIS
cfg.qlog = [cfg.scrp 'qsublog/']; % use to keep log files from SGE
cfg.data = [cfg.base 'subjects/']; 
cfg.anly = [cfg.base 'analysis/'];
cfg.rslt = [cfg.base 'results/' cfg.cond filesep]; % folder to save images

%-TODO: how to treat these 3 folders nicely?
cfg.derp = [cfg.anly 'erp/'];
cfg.dpow = [cfg.anly 'pow/'];
cfg.dcon = [cfg.anly 'conn/'];

%-------%
%-uncomment here if necessary
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
%-----------------%

%-----------------%
%-which steps belong to 
% a) preprocessing (SGE, keep track of order and names)
% b) subject analysis (SGE, any order)
% c) group analysis (no SGE, any order)
st = 0;
step.prep = [1  2  3  4];
step.subj = [5  7  9 11];
step.grp  = [6  8 10 12 13 14];
%  5  6 -> erp  7  8 -> erpgrand
%  9 10 -> pow 11  12 -> powgrand
% 13 -> custom function 14 -> write to csv
cfg.clear = [1  2  3]; % TODO: improve handling of clear, only meaningful for preprocessing
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

cfg.rcnd = '_recname-';
cfg.seldata.trialfun = 'trialfun_XXX';

cfg.seldata.selchan = 1:61;
cfg.seldata.label = cellfun(@(x) ['E' num2str(x)], num2cell(1:61), 'uni', 0);
%-----------------%

%-----------------%
%-02: gclean
st = st + 1;
cfg.step{st} = 'gclean';

cfg.gtool.fsample = 1024; % <- manually specify the frequency (very easily bug-prone, but it does not read "data" all the time)
cfg.gtool.saveall = false;
cfg.gtool.verbose = true;

cfg.gtool.lpfreqn = [.5 / (cfg.gtool.fsample/2)]; % normalized by half of the sampling frequency!

cfg.gtool.bad_samples.MADs = 5;
cfg.gtool.bad_channels.MADs = 8;

cfg.gtool.eog.correction = 50;
cfg.gtool.emg.correction = 30;
%-----------------%

%-----------------%
%-03: preprocessing on full trials
st = st + 1;
cfg.step{st} = 'preproc';
cfg.preproc.reref = 'yes';
cfg.preproc.refchannel = 'all';
cfg.preproc.implicit = [];

cfg.preproc.hpfilter = 'yes';
cfg.preproc.hpfreq = 0.5;
cfg.preproc.hpfiltord = 4;

cfg.csd.do = 'no';
cfg.csd.method = 'finite'; % finite or spline or hjorth
%-----------------%

%-----------------%
%-04: redefine trials
st = st + 1;
cfg.step{st} = 'redef';
cfg.redef.event2trl = 'event2trl_XXX';

%-------%
%-these parameters depend on event2trl_XXX
% they should be removed if not used
cfg.redef.trigger = 'switch';
cfg.redef.prestim = 2;
cfg.redef.poststim = 2;
%-------%
%-----------------%
%---------------------------%

%---------------------------%
%-info for analysis
% how you want to group your data. It specifies the 4th field (condition).
% Use * carefully (don't add it if not necessary)
cfg.test = {'*cond1' '*cond2'};
%---------------------------%

%---------------------------%
%-ERP
%-----------------%
%-05: timelock analysis
st = st + 1;
cfg.step{st} = 'erp_subj';
cfg.erp.preproc.demean = 'yes';
cfg.erp.preproc.baselinewindow = [-.2 0];
cfg.erp.preproc.lpfilter = 'yes';
cfg.erp.preproc.lpfreq = 30;
%-----------------%

%-----------------%
%-06: erp across subjects
st = st + 1;
cfg.step{st} = 'erp_grand';

cfg.erpeffect = 1;
cfg.gerp.chan(1).name = 'occipital1';
cfg.gerp.chan(1).chan =  {'E122','E123','E124','E133','E134','E135','E136','E137','E145','E146','E147','E148','E149','E156','E157','E158','E165','E166','E167','E174'};
cfg.gerp.bline = cfg.erp.preproc.baselinewindow;
%-----------------%

%-----------------%
%-07: lcmv on erp
st = st + 1;
cfg.step{st} = 'erpsource_subj';

cfg.erpsource.erp   = cfg.erp;
cfg.erpsource.bline = -.2; % use for covariance (this is the center, the length depends on erppeak)

cfg.erpsource.areas = 'erppeak'; % 'manual' or 'erppeak' (peaks from granderp)
switch cfg.erpsource.areas
  
  case 'manual'
    cfg.erpsource.erppeak(1).name = 'vis1';
    cfg.erpsource.erppeak(1).time = 0.10; % center of the time window
    cfg.erpsource.erppeak(1).wndw = 0.05; % length of the time window
       
  case 'erppeak'
    
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

cfg.pow.method = 'mtmconvol';
cfg.pow.output = 'pow';
cfg.pow.taper = 'hanning';
cfg.pow.foi = [2:.5:50];
cfg.pow.t_ftimwin = 5  ./ cfg.pow.foi;
cfg.pow.toi = [-1.5:.1:1.5];

cfg.pow.bl.baseline = []; % [] (no baseline)
%-----------------%

%-----------------%
%-10: pow across subjects
st = st + 1;
cfg.step{st} = 'pow_grand';

cfg.poweffect = 1;

cfg.gpow.chan(1).name = 'occ';
cfg.gpow.chan(1).chan = {'E26' 'E27' 'E41' 'E42' 'E43' 'E55'};
cfg.gpow.freq{1} = [8 12];
%-----------------%

%-----------------%
%-11: power analysis at source level
st = st + 1;
cfg.step{st} = 'powsource_subj';

cfg.powsource.bline = 0;

cfg.powsource.areas = 'manual'; % 'manual' or 'powpeak' (peaks from grandpow)
switch cfg.powsource.areas
  
  case 'manual'
    cfg.powsource.powpeak(1).time = 1;
    cfg.powsource.powpeak(1).wndw = .6;
    cfg.powsource.powpeak(1).freq = 10;
    cfg.powsource.powpeak(1).band = 2;
    cfg.powsource.powpeak(1).name = 'alpha';
    
  case 'powpeak'
    
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
%-EXTRA FUNCTIONS (put these functions in PROJNAME_private)
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
cfg.csvf = [cfg.anly cfg.cond '_complete.csv']; % file to write results to
cfg.export2csv.extrainfo = 'exportneckersd';
%---------------------------%
%---------------------------%

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
