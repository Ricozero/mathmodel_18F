function x_new = exclude2(x)
global n_gate
global n_puck
global time_unified

occupy = zeros(n_gate, n_puck); % 各个登机口的转场表
n_occupy = ones(1, n_gate); % 每个登机口的转场数
for i = 1:n_puck
    gate_no = x(i);
    occupy(gate_no, n_occupy(gate_no)) = i;
    n_occupy(gate_no) = n_occupy(gate_no) + 1;
end
n_occupy = n_occupy - 1;

% 贪心算法，从持续时间最短的转场开始判断
x_new = x;
interval = 1 / 24 * 0.75;
for i = 1:n_gate
    % 占用此登机口的转场编号
    pucks = occupy(i, 1:n_occupy(i));
    % 转场的到达和出发时间
    time_pucks = time_unified(pucks, :);
    d = time_pucks(:, 2) - time_pucks(:, 1);
    % 排序后的时间间隔
    [~, I] = sort(d);
    sel = false(1, size(d, 1)); % selection map
    for j = 1:size(d, 1)
        % 是否冲突
        flag = false;
        for k = 1:j - 1
            if sel(k) && time_pucks(I(j), 2) + interval > time_pucks(I(k), 1) && time_pucks(I(j), 1) < time_pucks(I(k), 2) + interval
                flag = true;
                break;
            end
        end
        if ~flag
            sel(j) = true;
        end
    end
    %disp(sel)
    for j = 1:size(d, 1)
        if ~sel(j)
            x_new(pucks(I(j))) = 0;
        end
    end
end
end