clc
close all
clear variables

ko_base_path = './data/KO-traces-25s/';
wt_base_path = './data/WT-traces-25s/';

ko_dir = dir(strcat(ko_base_path, '*.xlsx'));
wt_dir = dir(strcat(wt_base_path, '*.xlsx'));

downsample_rate = 10;

ko_trc = cell(1, length(ko_dir));
for i=1:length(ko_dir)
   p = strcat(ko_base_path, ko_dir(i).name);
   try
       df = readtable(p);
   catch ME
        fprintf(1, 'Error idetifier: %s \n', ME.identifier);
        fprintf(2, 'Error message: %s \n', ME.message);
   end
   ko_trc{i} = downsample(df, downsample_rate);
end

wt_trc = cell(1, length(wt_dir));
for i=1:length(wt_dir)
    p = strcat(wt_base_path, wt_dir(i).name); 
    try    
        df = readtable(p);
    catch ME
        fprintf(1, 'Error idetifier: %s \n', ME.identifier);
        fprintf(2, 'Error message: %s \n', ME.message);
    end
    wt_trc{i} = downsample(df, downsample_rate);
end

%% visualization; raw traces
for i=1:35
    df = ko_trc{i};
    figure(1)
    hold on
        plot(df.Time_ms_, df.Trace)
    hold off
    
    df = wt_trc{i};
    figure(2)
    hold on
        plot(df.Time_ms_, df.Trace)
    hold off
end

%% paste signals
time_step = 0.001;

% KO signals
ko_pasteT = [];
ko_pasteI = [];

t = ko_trc{1}.Time_ms_;
N = t(end);
ko_pasteT = [ko_pasteT; t];
ko_pasteI = [ko_pasteI; ko_trc{1}.Trace];

for i=2:length(ko_trc)
    t = ko_trc{i}.Time_ms_;
    newT = t + N + (i-1)*time_step;
    
    ko_pasteT = [ko_pasteT; newT];
    ko_pasteI = [ko_pasteI; ko_trc{i}.Trace];
    
    N = N + t(end);
end
ko_paste_trc = table(ko_pasteT, ko_pasteI, 'VariableNames',{'Time','Current'});

% WT signals
wt_pasteT = [];
wt_pasteI = [];

t = wt_trc{1}.Time_ms_;
N = t(end);
wt_pasteT = [wt_pasteT; t];
wt_pasteI = [wt_pasteI; wt_trc{1}.Trace];

for i=2:length(wt_trc)
    t = wt_trc{i}.Time_ms_;
    newT = t + N +(i-1)*time_step;

    wt_pasteT = [wt_pasteT; newT];
    wt_pasteI = [wt_pasteI; wt_trc{i}.Trace];
    
    N = N + t(end);
end
wt_paste_trc = table(wt_pasteT, wt_pasteI, 'VariableNames',{'Time','Current'});

%% save
save('downsampled2.mat', 'ko_trc','wt_trc')
save('pasted.mat', 'ko_paste_trc','wt_paste_trc')

