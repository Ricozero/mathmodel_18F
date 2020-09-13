function f = fitness(x)
% 在遗传算法中计算个体适应度，即优化目标
% x：航班与登机口的对应矩阵的展开，依次存储各个登机口的向量
    global n_gate
    global n_flight
    x = reshape(x, n_gate, n_flight);
    x = x';
    % 优化目标1：排上的航班数
    flight_planned = sum(x, 2);
    n_planned = sum(logical(flight_planned));
    % 优化目标2：未使用登机口数
    gate_used = sum(x);
    n_unused = sum(~gate_used);
    f = n_planned + n_unused;
end
    