function archive = update_archive(archive, P, Z, picks, Global)
global disable_flag;
if disable_flag
    return;
end
if ~isempty(archive)
    P = [archive, P];
end
[O, ia, ~] = unique([P.objs], 'rows');
P = P(ia);
[index_frontiers, ~] = find_frontiers(O, [P.cons]);
archive = P(index_frontiers);
O = [archive.objs];
if numel(archive) > picks
    O = normalize(O);
    %% Associate each frontier solution with one reference point
    [min_metric, allocation] = pair(O, Z, 'sin');
    %% Identify the active reference lines
    index_active_clusters = unique(allocation);
    %% calculate metric and sort the frontier solutions
    cluster.center = [];
    cluster.select_queue = [];
    cluster = repmat(cluster, numel(index_active_clusters), 1);
    for i = 1: numel(index_active_clusters)
        Cluster_F_index = find(allocation == index_active_clusters(i));
        if numel(Cluster_F_index) == 1
            ascend_index = 1;
        else
            F_metric = min_metric(Cluster_F_index)';
            if numel(cluster) >= Global.N
                [~, ascend_index] = min(F_metric);
            else
                [~, ascend_index] = sort(F_metric, 'ascend');
            end
        end
        Cluster_F_index = Cluster_F_index(ascend_index);
        cluster(i).center = Cluster_F_index(1);
    end
    center_index = [cluster.center];
    archive = [archive(center_index), crowding_pick(archive, picks, 'fast')];
    [~, ia, ~] = unique([archive.objs], 'rows');
    archive = archive(ia);
end
% fprintf('size of archive: %d\n', numel(archive));
end