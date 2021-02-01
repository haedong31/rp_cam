%% individual signal
clc
close all
clear variables

load('downsampled.mat')

len_ko_trc = length(ko_trc);
len_wt_trc = length(wt_trc);

%% choose tau
% 1 index step = 5 ms
tau = 1:100;
len_tau = length(tau);

ko_mi = cell(1, len_ko_trc);
ko_tau = zeros(1, len_ko_trc);
for i=1:len_ko_trc
    trc = ko_trc{i};
    x = trc.Trace;

    mi = zeros(1, len_tau);
    for j=1:len_tau
        mi(j) = mutual_info(x, tau(j), 2);        
    end
    
    if any(isnan(mi))
        fprintf('NaN MI at %i \n', i)
    end

    ko_mi{i} = mi;

    knee_tau = knee_pt(mi);
    if mi(knee_tau+1) < mi(knee_tau)
        ko_tau(i) = knee_tau+1;
    else
        ko_tau(i) = knee_tau;
    end
end

wt_mi = cell(1, len_wt_trc);
wt_tau = zeros(1, len_wt_trc);
for i=1:len_wt_trc
    trc = wt_trc{i};
    x = trc.Trace;

    mi = zeros(1, len_tau);
    for j=1:len_tau
        mi(j) = mutual_info(x, tau(j), 2);        
    end
    
    if any(isnan(mi))
        fprintf('NaN MI at %i \n', i)
    end

    wt_mi{i} = mi;

    knee_tau = knee_pt(mi);
    if mi(knee_tau+1) < mi(knee_tau)
        wt_tau(i) = knee_tau+1;
    else
        wt_tau(i) = knee_tau;
    end
end

%% choose embedding dimension n
dim = 1:10;
r = 1;
tol = 5;

ko_fnn = cell(1, len_ko_trc);
ko_dim = zeros(1, len_ko_trc);
for i=1:len_ko_trc
    trc = ko_trc{i};
    x = trc.Trace;

    fnn_ratios = FNN(x, ko_tau(i), dim, r, tol);
    ko_fnn{i} = fnn_ratios;

    knee_dim = knee_pt(fnn_ratios);
    if fnn_ratios(knee_dim+1) < fnn_ratios(knee_dim)
        ko_dim(i) = knee_dim + 1;
    else
        ko_dim(i) = knee_dim;
    end
end

wt_fnn = cell(1, len_wt_trc);
wt_dim = zeros(1, len_wt_trc);
for i=1:len_wt_trc
    trc = wt_trc{i};
    x = trc.Trace;

    fnn_ratios = FNN(x, wt_tau(i), dim, r, tol);
    wt_fnn{i} = fnn_ratios;

    knee_dim = knee_pt(fnn_ratios);
    if fnn_ratios(knee_dim+1) < fnn_ratios(knee_dim)
        wt_dim(i) = knee_dim + 1;
    else
        wt_dim(i) = knee_dim;
    end
end

%% save intermediate results
save('MI.mat', 'ko_mi','ko_tau','wt_mi','wt_tau')
save('FNN.mat', 'ko_fnn','ko_dim','wt_fnn','wt_dim')

%% visualizarion; 3-D embedding
new_ko_trc = cell(1, len_ko_trc);
new_wt_trc = cell(1, len_wt_trc);

% KO group
trc = ko_trc{1};
x = trc.Trace;

[embedX, ~] = time_delay_embed(x, ko_tau(1), 3);

figure(1)
plot3(embedX(:, 1), embedX(:, 2), embedX(:, 3), '-o')
grid on
xlabel('x(t)')
ylabel('x(t+\tau)')
zlabel('x(t+2\tau)')

hold on
for i=2:len_ko_trc
    trc = ko_trc{i};
    x = trc.Trace;

    [embedX, ~] = time_delay_embed(x, ko_tau(i), 3);
    
%     plot3(embedX(:, 1), embedX(:, 2), embedX(:, 3), '-o', 'Color','b', 'MarkerFaceColor','#D9FFFF')
    hold on
        plot3(embedX(:, 1), embedX(:, 2), embedX(:, 3), '-o')
    hold off
    
end
hold off
axis tight

% WT group
trc = wt_trc{1};
x = trc.Trace;

[embedX, ~] = time_delay_embed(x, wt_tau(1), 3);

figure(2)
plot3(embedX(:, 1), embedX(:, 2), embedX(:, 3), '-o')
grid on
xlabel('x(t)')
ylabel('x(t+\tau)')
zlabel('x(t+2\tau)')

hold on
for i=2:len_wt_trc
    trc = wt_trc{i};
    x = trc.Trace;

    [embedX, ~] = time_delay_embed(x, wt_tau(i), 3);
    
    hold on
        plot3(embedX(:, 1), embedX(:, 2), embedX(:, 3), '-o')
    hold off
    
end
hold off
axis tight

%% embedding according to FNN criteria
% KO group
ko_embed_mx = cell(len_ko_trc, 1);
for i=1:len_ko_trc
    trc = ko_trc{i};
    x = trc.Trace;

    [embedX, ~] = time_delay_embed(x, ko_tau(i), ko_dim(i));
    ko_embed_mx{i} = embedX;
end

% WT group
wt_embed_mx = cell(len_wt_trc, 1);
for i=1:len_wt_trc
    trc = wt_trc{i};
    x = trc.Trace;

    [embedX, ~] = time_delay_embed(x, wt_tau(i), wt_dim(i));
    wt_embed_mx{i} = embedX;
end

%% save
save('embedding.mat')
save('embed_matrix', 'ko_embed_mx','wt_embed_mx')
