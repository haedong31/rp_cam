clc
close all
clear variables

% load time-delay embedded data
load("3D_embed_matrix")

% calculate necessary size of data
[len_wt_trc, ~] = size(wt_embed_mx);
[len_ko_trc, ~] = size(ko_embed_mx);
% num_wt = (len_wt_trc-1)*(len_wt_trc)/2;
% num_ko = (len_ko_trc-1)*(len_ko_trc)/2;
% num_wt_ko = len_wt_trc*len_ko_trc;

%% CRP within WT group
% wt_crp_mx = {};
cnt = 0;
for i = 1:len_wt_trc
    % first signal
    s1 = wt_embed_mx{i};
    [num_pts1, ~] = size(s1);

    % index of second signal
    jbegin = i + 1;
    if jbegin > len_wt_trc
        break
    end

    % construct cross recurrence plot matrix
    for j = jbegin:len_wt_trc
        % second signal
        s2 = wt_embed_mx{j};
        [num_pts2, ~] = size(s2);

        crp_mx = zeros(num_pts1, num_pts2);
        for k = 1:num_pts1
            for l = 1:num_pts2
                d = norm(s1(k, :) - s2(l, :));
                crp_mx(k, l) = d;
                crp_mx(l, k) = d;
            end
        end
        cnt = cnt + 1;
        fprintf("Within WT iteration %i \n", cnt)
        % wt_crp_mx{cnt} = crp_mx;

        % save image
        p = sprintf('./data/crp_wt/wt%i.png', cnt);

        figure('Position',[100, 100, 700, 700])
        imagesc(crp_mx)
        colormap jet
        axis image
        get(gcf, 'CurrentAxes')
        set(gca, 'YDir','normal')
        set(gca, 'Visible', 'off')
        
        saveas(gcf, p)
        close
    end
end

%% CRP within KO group
% ko_crp_mx = {};
cnt = 0;
for i = 1:len_ko_trc
    % first signal
    s1 = ko_embed_mx{i};
    [num_pts1, ~] = size(s1);

    % index of second signal
    jbegin = i + 1;
    if jbegin > len_ko_trc
        break
    end

    % construct cross recurrence plot matrix
    for j = jbegin:len_ko_trc
        % second signal
        s2 = ko_embed_mx{j};
        [num_pts2, ~] = size(s2);

        crp_mx = zeros(num_pts1, num_pts2);
        for k = 1:num_pts1
            for l = 1:num_pts2
                d = norm(s1(k, :) - s2(l, :));
                crp_mx(k, l) = d;
                crp_mx(l, k) = d;
            end
        end
        cnt = cnt + 1;
        fprintf("Within KO iteration %i \n", cnt)
        % ko_crp_mx{cnt} = crp_mx;

        % save image
        p = sprintf('./data/crp_ko/ko%i.png', cnt);

        figure('Position',[100, 100, 700, 700])
        imagesc(crp_mx)
        colormap jet
        axis image
        get(gcf, 'CurrentAxes')
        set(gca, 'YDir','normal')
        set(gca, 'Visible', 'off')
        
        saveas(gcf, p)
        close
    end
end

% CRP between two groups
% wtko_crp_mx = {};
cnt = 0;
for i = 1:len_wt_trc
    % first signal from WT
    s1 = wt_embed_mx{i};
    [num_pts1, ~] = size(s1);

    % construct cross recurrence plot matrix
    for j = 1:len_ko_trc
        % second signal from KO
        s2 = ko_embed_mx{j};
        [num_pts2, ~] = size(s2);

        crp_mx = zeros(num_pts1, num_pts2);
        for k = 1:num_pts1
            for l = 1:num_pts2
                d = norm(s1(k, :) - s2(l, :));
                crp_mx(k, l) = d;
                crp_mx(l, k) = d;
            end
        end
        cnt = cnt + 1;
        fprintf("Between two groups iteration %i \n", cnt)
        % wtko_crp_mx{cnt} = crp_mx;

        % save image
        p = sprintf('./data/crp_wtko/wtko%i.png', cnt);

        figure('Position',[100, 100, 700, 700])
        imagesc(crp_mx)
        colormap jet
        axis image
        get(gcf, 'CurrentAxes');
        set(gca, 'YDir','normal')
        set(gca, 'Visible', 'off')
        
        saveas(gcf, p)
        close
    end
end
