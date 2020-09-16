%% 清理工作空间
clc
clear all

%% 读取表格，定义登机口数和航班数
[T_puck, T_gate] = loadtables;
global n_gate
global n_puck
n_gate = 69;
n_puck = size(T_puck, 1);

%% 编译登机口类型（宽/窄，到达D/I，出发D/I）
% 一共八个类型，分别为：WDD,WDI,WID,WII,NDD,NDI,NID,NII，对应1~8
% 一个登机口可能同时允许D/I，因此编译后登机口向量更长
% 从登机口的编译后编号（下标）映射到实际编号，先按照类型分为八行便于计算，后来再合并
gmm = zeros(8, n_gate); % gate map matrix
% 各个类别的数目
n_types = ones(1, 8);

for i = 1:n_gate
    t = 1;
    if T_gate{i, 'plane_type'}{1} == 'N'
        t = t + 4;
    end
    [at, dt] = T_gate{i, {'arrive_type', 'departure_type'}}{:};
    if contains(at, 'D') && contains(dt, 'D')
        gmm(t, n_types(t)) = i;
        n_types(t) = n_types(t) + 1;
    end
    if contains(at, 'D') && contains(dt, 'I')
        gmm(t + 1, n_types(t + 1)) = i;
        n_types(t + 1) = n_types(t + 1) + 1;
    end
    if contains(at, 'I') && contains(dt, 'D')
        gmm(t + 2, n_types(t + 2)) = i;
        n_types(t + 2) = n_types(t + 2) + 1;
    end
    if contains(at, 'I') && contains(dt, 'I')
        gmm(t + 3, n_types(t + 3)) = i;
        n_types(t + 3) = n_types(t + 3) + 1;
    end
end

n_types = n_types - 1;
global gate_map
gate_map = [];
for i = 1:8
    gate_map = [gate_map gmm(i, 1:n_types(i))];
end

%% 登机口数约束
lb = zeros(n_puck, 1);
ub = zeros(n_puck, 1);
ranges = zeros(8, 2);
s = 1;
for i = 1:8
    ranges(i, 1) = s;
    s = s + n_types(i);
    ranges(i, 2) = s - 1;
end
wide_types = {'332', '333', '33E', '33H', '33L', '773'};
for i = 1:n_puck
    t = 1;
    if ~ismember(T_puck{i, 'plane_type'}{1}, wide_types)
        t = t + 4;
    end
    [at, dt] = T_puck{i, {'arrive_type', 'departure_type'}}{:};
    if at == 'I'
        t = t + 2;
    end
    if dt == 'I'
        t = t + 1;
    end
    lb(i) = ranges(t, 1);
    ub(i) = ranges(t, 2);
end

%% 时间修正
% 19日设为0，20日设为1
global time_unified
time_unified = zeros(n_puck, 2); % 两列分别为到达和出发时间
date = datetime('2018-01-20');
for i = 1:n_puck
    dates = T_puck{i, {'arrive_date', 'departure_date'}};
    times = T_puck{i, {'arrive_time', 'departure_time'}};
    for j = 1:2
        if dates(j) < date
            time_unified(i, j) = 0;
        elseif dates(j) == date
            time_unified(i, j) = times(j);
        else
            time_unified(i, j) = 1;
        end
    end
    % 原映射为：19日为[-1,0)，20日为[0,1)，21日为[1,2)，但没必要
%     time_unified(i, 1) = times(1) + datenum(dates(1) - date);
%     time_unified(i, 2) = times(2) + datenum(dates(2) - date);
end

%% 运行
% 不使用onehot编码，而是使用1-69表示分配的登机口，0表示不分配，直接满足唯一性约束，避免收敛时仍无法满足约束（旧）
% 将登机口分成各个类别，分布在数组各个区域，使用lb和ub限制每个转场的范围，避免收敛时仍无法满足约束
tic
% TODO: 可以用gamultiobj，但为了实现整数规划，必须自己实现初始化、交配、变异
% TODO: 使用UseParallel会出现无法预料的bug，如何避免？
options = optimoptions(@ga, 'Display', 'iter', 'UseParallel', false);
disp(options)
[x, fval, exitflag, output, population, scores] = ga(@fitness, n_puck, [], [], [], [], lb, ub, [], 1:n_puck, options);
toc

%% 编号映射
x = gate_map(x);
sum(~~x)
sum(~~exclude(x))
sum(~~exclude2(x))
