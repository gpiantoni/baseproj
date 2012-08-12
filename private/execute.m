function execute(cfg, step)

%-------------------------------------%
%-LOG---------------------------------%
%-------------------------------------%
if ~isfield(step, 'sendemail')
  step.sendemail = true;
end

%-----------------%
%-don't include cfg.run if it's not part of preproc
% f.e. you might write cfg.run=1:10 bc it's faster, but you don't want to
% run ICA, so we need to remove the ICA step from cfg.run
[~, runpreproc] = intersect( cfg.run(cfg.run <= numel(step.prep)), step.prep);
cfg.run = [cfg.run(runpreproc) cfg.run(cfg.run > numel(step.prep))];
%-----------------%

%-----------------%
%-Log file
logdir = [cfg.anly 'log/'];
if ~isdir(logdir); mkdir(logdir); end

cfg.log = sprintf('%slog_%s_%s_%s', ...
  logdir, cfg.proj, datestr(now, 'yy-mm-dd'), datestr(now, 'HH-MM-SS'));
if ~isdir(cfg.log); mkdir(cfg.log); end % logdir for images

fid = fopen([cfg.log '.txt'], 'w');

output = sprintf('Analysis started at %s on %s\n', ...
  datestr(now, 'HH:MM:SS'), datestr(now, 'dd-mmm-yy'));
fprintf(output)
fwrite(fid, output);
%-----------------%

%-----------------%
%-add toolbox and cfg in log
outtool = addtoolbox(cfg);
cfg.prepstep = sprintf('%s ', cfg.step{step.prep}); % string
output = sprintf('%s\n%s\n', outtool, struct2log(cfg));

fwrite(fid, output);
output = regexprep(output, '%', '%%'); % otherwise fprint and fwrite gets confused for normal % sign
fprintf(output)
fclose(fid);
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-PREPROCESSING-----------------------%
%-------------------------------------%
cd(cfg.qlog)
subjcell = num2cell(cfg.subjall);

for r = intersect(cfg.run, step.prep) % only preproc steps
  disp(cfg.step{r})

  %-------%
  %-ending of the name to be used for the processing step
  prevsteps = intersect(1:r-1, step.prep);
  if isempty(prevsteps)
    cfg.endname = '';
  else
    cfg.endname = sprintf('_%s', cfg.step{prevsteps});
  end
  %-------%
  
  %-----------------%
  %-run for all the subjects
  if intersect(r, step.nooge)
    %-------%
    for s = cfg.subjall
      feval(cfg.step{r}, cfg, s);
    end
    %-------%
    
  else
    %-------%
    cfgcell = repmat({cfg}, 1, numel(cfg.subjall));
    qsubcellfun(cfg.step{r}, cfgcell, subjcell, 'memreq', 8*1024^3, 'timreq', 48*60*60, 'batchid', [cfg.nick '_' cfg.step{r}]);
    %-------%
  end
  %-----------------%
  
end
%-------------------------------------%

%-------------------------------------%
%-SINGLE-SUBJECT AND GROUP------------%
%-------------------------------------%
%-------%
%-ending of the name to be used for the processing step
cfg.endname = sprintf('_%s', cfg.step{step.prep});
cfgcell = repmat({cfg}, 1, numel(cfg.subjall));
%-------%

for r = intersect(cfg.run, union(step.subj, step.grp))
  disp(cfg.step{r})
  
  if intersect(r, step.subj)
    %---------------------------%
    %-SINGLE SUBJECT
    %-----------------%
    %-run for all the subjects
    if intersect(r, step.nooge)
      %-------%
      for s = cfg.subjall
        feval(cfg.step{r}, cfg, s);
      end
      %-------%
      
    else
      
      %-------%
      qsubcellfun(cfg.step{r}, cfgcell, subjcell, 'memreq', 8*1024^3, 'timreq', 48*60*60, 'batchid', [cfg.nick '_' cfg.step{r}]);
      %-------%
      
    end
    %-----------------%
    %---------------------------%
    
  else
    %---------------------------%
    %-GROUP
    %-----------------%
    %-run for all the subjects
    if intersect(r, step.nooge)
      %-------%
      feval(cfg.step{r}, cfg)
      %-------%
    else
      %-------%
      qsubcellfun(cfg.step{r}, {cfg}, 'memreq', 20*1024^3, 'timreq', 48*60*60, 'backend', 'system')
      %-------%
      
    end
    %---------------------------%
  end
  
end

%-----------------%
%-clear preprocessing
if ~isempty(cfg.clear) && numel(cfg.clear) == numel(step.prep)
  for subj = cfg.subjall
    ddir = sprintf('%s%04.f/%s/%s/', cfg.data, subj, cfg.mod, cfg.nick); % data
    rmdir(ddir, 's');
  end
end
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-send email
if step.sendemail
  send_email(cfg)
end
cd(cfg.scrp)
%-------------------------------------%
