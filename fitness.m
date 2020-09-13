function f = fitness(x)
% 在遗传算法中计算个体适应度，即优化目标
% x：航班与登机口的对应矩阵的展开，依次存储各个登机口的向量
    global n_gate
    % 优化目标1：排上的航班数
    n_planned = sum(~~x);
    % 优化目标2：未使用登机口数
    gate_used = unique(x);
    gate_used(gate_used == 0) = [];
    n_unused = n_gate - size(gate_used, 2);
    f = n_planned + n_unused;
end
    