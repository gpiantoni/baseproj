function NICKNAME(cfgin)
%MAIN FUNCTION
% You should call this function and modify it with your parameters of interest
% 
% To use it in your project, you should change NICKNAME into the name of
% your project/subjproject. In this toolbox, PROJNAME is the name of the
% project (/data1/projects/PROJNAME/). One project can have multiple
% subprojects, called NICKNAME.

%-------------------------------------%
%-INFO--------------------------------%
%-------------------------------------%
info = info_NICKNAME;

%-----------------%
%-uncomment here if necessary
if isdir(info.qlog); rmdir(info.qlog, 's'); end; mkdir(info.qlog);
if isdir(info.derp); rmdir(info.derp, 's'); end; mkdir(info.derp);
if isdir(info.dpow); rmdir(info.dpow, 's'); end; mkdir(info.dpow);
%-----------------%

%-----------------%
%-subjects index and step index
info.subjall = 1:8;
info.run = 1:5;

info.nooge = 5;
info.sendemail = false;
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-CFG---------------------------------%
%-------------------------------------%
%---------------------------%
%-step preprocessing
%-----------------%
%-01: select data
st = 1;
cfg(st).function = 'seldata';
cfg(st).step = 'subj';

cfg(st).opt.rcnd = '_cond_to_read_';
cfg(st).opt.trialfun = 'trialfun_NICKNAME';

cfg(st).opt.selchan = 1:61;
cfg(st).opt.label = cellfun(@(x) ['E' num2str(x)], num2cell(cfg(st).opt.selchan), 'uni', 0);
%-----------------%

%-----------------%
%-02: gclean
st = st + 1;
cfg(st).function = 'gclean';
cfg(st).step = 'subj';

cfg(st).opt.fsample = 1000; % <- manually specify the frequency (very easily bug-prone, but it does not read "data" all the time)

cfg(st).opt.hpfreq = [.5 / (cfg(st).opt.fsample/2)]; % normalized by half of the sampling frequency!
cfg(st).opt.bad_samples.MADs = 5;
cfg(st).opt.bad_samples.Percentile = [25 75];
cfg(st).opt.bad_channels.MADs = 8;

cfg(st).opt.eog.correction = 50;
cfg(st).opt.emg.correction = 30;
%-----------------%

%-----------------%
%-03: redefine trials
st = st + 1;
cfg(st).function = 'redef';
cfg(st).step = 'subj';

%-------%
%-preproc before
cfg(st).opt.preproc1.hpfilter = 'yes';
cfg(st).opt.preproc1.hpfreq = 0.5;
cfg(st).opt.preproc1.hpfiltord = 4;
%-------%

%-------%
%-redefine
cfg(st).opt.event2trl = 'event2trl_NICKNAME'; % <- TO WRITE
cfg(st).opt.redef.trigger = 'event';
cfg(st).opt.redef.prestim = 1;
cfg(st).opt.redef.poststim = 2; % 
%-------%

%-------%
%-preproc after
cfg(st).opt.preproc2.reref = 'yes';
cfg(st).opt.preproc2.refchannel = 'all'; 
cfg(st).opt.preproc2.implicit = [];
%-------%
%-----------------%
%---------------------------%

%---------------------------%
%-ERP
%-----------------%
%-04: timelock analysis
st = st + 1;
cfg(st).function = 'erp_subj';
cfg(st).step = 'subj';

cfg(st).opt.cond = {'cond1*' 'cond2*'};

cfg(st).opt.erp.preproc.demean = 'yes';
cfg(st).opt.erp.preproc.baselinewindow = [-.2 0];
cfg(st).opt.erp.preproc.lpfilter = 'yes';
cfg(st).opt.erp.preproc.lpfreq = 30;
%-----------------%

%-----------------%
%-05: erp across subjects
st = st + 1;
cfg(st).function = 'erp_grand';
cfg(st).step = 'grand';

cfg(st).comp = {{'*cond1'} {'*cond1' '*cond2'}};
%-----------------%
%---------------------------%
%-------------------------------------%

%-------------------------------------%
%-EXECUTE
execute(info, cfg)
%-------------------------------------%
