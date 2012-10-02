function execute(info, cfg)
%EXECUTE the core function, which calls the subfunctions
% 
% Use as:
%   execute(info, cfg)
%
% INFO
%  .sendemail: send email to hard-coded email address (logical)
%  .anly: folder with group analysis
%  .proj: name of the project
%  .qlog: directory with output of SGE
%
% CFG should be a Nx1 struct with obligatory fields:
%  .function: function to call
%  .step: whether the function is subject-specific ('subj') or a
%         grand-average ('grand')
%  .opt: optional configuration for that function
%

%-------------------------------------%
%-LOG---------------------------------%
%-------------------------------------%
if ~isfield(info, 'sendemail')
  info.sendemail = true;
end

%-----------------%
%-Log file
logdir = [info.anly 'log/'];
if ~isdir(logdir); mkdir(logdir); end

info.log = sprintf('%slog_%s_%s_%s', ...
  logdir, info.proj, datestr(now, 'yy-mm-dd'), datestr(now, 'HH-MM-SS'));
if ~isdir(info.log); mkdir(info.log); end % logdir for images

fid = fopen([info.log '.txt'], 'w');

output = sprintf('Analysis started at %s on %s\n', ...
  datestr(now, 'HH:MM:SS'), datestr(now, 'dd-mmm-yy'));
fprintf(output)
fwrite(fid, output);
%-----------------%

%-----------------%
%-add toolbox and prepare log
outtool = addtoolbox(info);
output = sprintf('%s\n%s\n%s\n', outtool, struct2log(info), struct2log(cfg));

fwrite(fid, output);
output = regexprep(output, '%', '%%'); % otherwise fprint and fwrite gets confused for normal % sign
fprintf(output)
fclose(fid);
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-CALL EACH FUNCTION------------------%
%-------------------------------------%
cd(info.qlog)

%-----------------%
%-transform into cell
infocell = repmat({info}, 1, numel(cfg.subjall));
subjcell = num2cell(info.subjall);
%-----------------%

for r = info.run
  disp(cfg(r).function)
  cfgcell = repmat({cfg(r).opt}, 1, numel(cfg.subjall));
  
  switch cfg(r).step
    
    case 'subj'
      %---------------------------%
      %-SINGLE SUBJECT
      %-----------------%
      %-run for all the subjects
      if intersect(r, info.nooge)
        
        %-------%
        for s = cfg.subjall
          feval(cfg(r).function, info, cfg, s);
        end
        %-------%
        
      else
        
        %-------%
        qsubcellfun(cfg(r).function, infocell, cfgcell, subjcell, 'memreq', 8*1024^3, 'timreq', 48*60*60, 'batchid', [cfg.nick '_' cfg(r).function]);
        %-------%
        
      end
      %-----------------%
      %---------------------------%
      
    case 'grand'
      %---------------------------%
      %-GROUP
      %-----------------%
      %-run for all the subjects
      if intersect(r, info.nooge)
        
        %-------%
        feval(cfg(r).function, info, cfg)
        %-------%
        
      else
        
        %-------%
        qsubcellfun(cfg(r).function, {info}, {cfg}, 'memreq', 20*1024^3, 'timreq', 48*60*60, 'backend', 'system')
        %-------%
        
      end
      %---------------------------%
      
    otherwise
      warning([cfg(r).step ' is neither ''subj'' nor ''grand'''])
      
  end
  
end
%-------------------------------------%

%-------------------------------------%
%-send email
if info.sendemail
  send_email(info, cfg)
end
cd(info.scrp)
%-------------------------------------%
