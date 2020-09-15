function f = fitness(x)
% 在遗传算法中计算个体适应度，即优化目标
global n_gate
global gate_map
x = gate_map(x);

% 优化目标1：排上的航班数
n_planned = sum(~~x);
% 优化目标2：未使用登机口数
gate_used = unique(x);
gate_used(gate_used == 0) = [];
n_unused = n_gate - size(gate_used, 2);

f = n_planned + n_unused;
end