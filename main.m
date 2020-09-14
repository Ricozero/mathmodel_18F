%% 清理工作空间
clc
clear all

%% 读取表格，定义登机口数和航班数
[T, T_gate] = loadtables;
global n_gate
n_gate = 69;
n_puck = size(T, 1);

%% 编译登机口类型（宽/窄，到达D/I，出发D/I）
% 一共八个类型，分别为：WDD,WDI,WID,WII,NDD,NDI,NID,NII，对应1~8
% 一个登机口可能同时允许D/I，因此编译后登机口向量更长
% 从登机口的编译后编号（下标）映射到实际编号，先按照类型分为八行便于计算，后来再合并
gmm = zeros(8, n_gate); % gate map matrix
% 各个类别的数目
n_type = ones(1, 8);

for i = 1:n_gate
    t = 1;
    if T_gate{i, 'plane_type'}{1} == 'N'
        t = t + 4;
    end
    [at, dt] = T_gate{i, {'arrive_type', 'departure_type'}}{:};
    if contains(at, 'D') && contains(dt, 'D')
        gmm(t, n_type(t)) = i;
        n_type(t) = n_type(t) + 1;
    end
    if contains(at, 'D') && contains(dt, 'I')
        gmm(t + 1, n_type(t + 1)) = i;
        n_type(t + 1) = n_type(t + 1) + 1;
    end
    if contains(at, 'I') && contains(dt, 'D')
        gmm(t + 2, n_type(t + 2)) = i;
        n_type(t + 2) = n_type(t + 2) + 1;
    end
    if contains(at, 'I') && contains(dt, 'I')
        gmm(t + 3, n_type(t + 3)) = i;
        n_type(t + 3) = n_type(t + 3) + 1;
    end
end

n_type = n_type - 1;
global gate_map
gate_map = [];
for i = 1:8
    gate_map = [gate_map gmm(i, 1:n_type(i))];
end

%% 登机口数约束
lb = zeros(n_puck, 1);
ub = zeros(n_puck, 1);
ranges = zeros(8, 2);
s = 1;
for i = 1:8
    ranges(i, 1) = s;
    s = s + n_type(i);
    ranges(i, 2) = s - 1;
end
wide_types = {'332', '333', '33E', '33H', '33L', '773'};
for i = 1:n_puck
    t = 1;
    if ~ismember(T{i, 'plane_type'}{1}, wide_types)
        t = t + 4;
    end
    [at, dt] = T{i, {'arrive_type', 'departure_type'}}{:};
    if at == 'I'
        t = t + 2;
    end
    if dt == 'I'
        t = t + 1;
    end
    lb(i) = ranges(t, 1);
    ub(i) = ranges(t, 2);
end

%% 运行
% 不适用onehot编码，而是使用1-69表示分配的登机口，0表示不分配
% 这样做可以直接满足唯一性约束，避免收敛还无法满足约束的情况
tic
% TODO: 可以用gamultiobj，但为了实现整数规划，必须自己实现交配、变异、交叉
% TODO: 使用UseParallel会出现无法预料的bug，如何避免？
options = optimoptions(@ga, 'Display', 'iter', 'UseParallel', false);
disp(options)
[x, fval, exitflag, output, population, scores] = ga(@fitness, n_puck, [], [], [], [], lb, ub, [], 1:n_puck, options);
toc

%% 结果输出
result = gate_map(x);
