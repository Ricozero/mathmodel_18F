function x_new = exclude(x)
global n_gate
global n_puck
global time_unified

occupy = zeros(n_gate, n_puck); % 占用登机口的转场表
n_occupy = ones(1, n_gate); % 占用每个登机口的转场数
for i = 1:n_puck
    gate_no = x(i);
    occupy(gate_no, n_occupy(gate_no)) = i;
    n_occupy(gate_no) = n_occupy(gate_no) + 1;
end
n_occupy = n_occupy - 1;

x_new = x;
for i = 1:n_gate
    % 占用此登机口的转场编号
    pucks = occupy(i, 1:n_occupy(i));
    % 转场的到达和出发时间
    time_pucks = time_unified(pucks, :);
    % 根据到达时间的排序以及原向量的索引
    [at, I] = sort(time_pucks(:, 1));
    d = time_pucks(:, 2) - time_pucks(:, 1);
    j = 1;
    while j <= size(pucks, 2)
        % 所有到达时间相等的转场在排序数组中的索引
        I1 = find(at == at(j));
        if j > 1 && time_pucks(I(j - 1), 2) + 1 / 24 * 0.75 > time_pucks(I(j), 1)
            for k = 1:size(I1, 1)
                x_new(pucks(I(I1(k)))) = 0;
            end
            j = j + size(I1, 1);
            continue
        end
        if size(I1, 1) > 1
            [~, ichosen] = min(d(I1));
            % 被选转场在排序数组中的索引
            ichosen = ichosen + j - 1;
            for k = 1:size(I1, 1)
                if I1(k) ~= ichosen
                    x_new(pucks(I(I1(k)))) = 0;
                end
            end
        end
        j = j + size(I1, 1);
    end
end
end