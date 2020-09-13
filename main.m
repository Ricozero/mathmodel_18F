%% 清理工作空间
clc
clear all

%% 读取航班信息
% 改1：表格删除所有时间前面的空格（比如“ 9:00”），避免被识别为NaN
% 改2：飞机型号设定为文本，但无法避免出现NaN，因此使用下文opts的方式
opts = detectImportOptions('InputData.xlsx');
opts.VariableNames = {' ', 'arrive_date', 'arrive_time', 'arrive_flight', 'arrive_type',  'plane_type', 'departure_date', 'departure_time', 'departure_flight', 'departure_type', 'prior_airport', 'next_airport'};
opts = setvartype(opts, 'plane_type', 'char');
opts.PreserveVariableNames = true;
%preview('InputData.xlsx', opts)
global T
T = readtable('InputData.xlsx', opts, 'ReadRowNames', true);

%% 日期筛选：仅20日到达/出发
date = datetime('2018-01-20');
indices = [];
for i = 1:size(T, 1)
    if T{i, 'arrive_date'} == date || T{i, 'departure_date'} == date
        indices = [indices i];
    end
end
T = T(indices, :);

%% 读取登机口信息
global T_gate
T_gate = readtable('InputData.xlsx', 'Sheet', 3, 'ReadRowNames', true, 'PreserveVariableNames', true);
T_gate.Properties.VariableNames = {'hall', 'district', 'arrive_type', 'departure_type', 'plane_type'};

%% 定义登机口数和航班数
global n_gate
global n_flight
n_gate = 69;
n_flight = size(T, 1);

%% 矢量化机型字符串
global flight_pt % flight plane type，0窄1宽
flight_pt = zeros(1, n_flight);
wide_types = {'332', '333', '33E', '33H', '33L', '773'};
T_flight_pt = T{:, 'plane_type'};
for i = 1:n_flight
    if ismember(T{i, 'plane_type'}{1}, wide_types)
        flight_pt(i) = 1;
    end
end
flight_pt = logical(flight_pt);

global gate_pt % gate plane type，0窄1宽
gate_pt = zeros(1, n_gate);
T_gate_pt = T_gate{:, 'plane_type'};
for i = 1:n_gate
    if T_gate{i, 'plane_type'}{1} == 'W'
        gate_pt(i) = 1;
    end
end
gate_pt = logical(gate_pt);

%% 矢量化到达/出发的国内/国际字符串
global flight_type
% 0国内1国际 -> 到达/出发：00，01，10，11 -> 1，2，3，4
flight_type = zeros(1, n_flight);
T_flight_type = T{:, {'arrive_type', 'departure_type'}};
for i = 1:n_flight
    [at, dt] = T_flight_type{i, :};
    t = 1;
    if at == 'I'
        t = t + 2;
    end
    if dt == 'I'
        t = t + 1;
    end
    flight_type(i) = t;
end

global gate_type
% 四列代表flight_di四种情况，值为1表示允许
gate_type = zeros(n_gate, 4);
T_gate_type = T_gate{:, {'arrive_type', 'departure_type'}};
for i = 1:n_gate
    [at, dt] = T_gate_type{i, :};
    if contains(at, 'D') && contains(dt, 'D')
        gate_type(i, 1) = 1;
    end
    if contains(at, 'D') && contains(dt, 'I')
        gate_type(i, 2) = 1;
    end
    if contains(at, 'I') && contains(dt, 'D')
        gate_type(i, 3) = 1;
    end
    if contains(at, 'I') && contains(dt, 'I')
        gate_type(i, 4) = 1;
    end
end
gate_type = logical(gate_type);

%% 约束与运行
% 不适用onehot编码，而是使用1-69表示分配的登机口，0表示不分配
% 这样做可以直接满足唯一性约束，避免收敛还无法满足约束的情况
% 登机口数约束
lb = zeros(n_flight, 1);
ub = ones(n_flight, 1) * n_gate;
% 整数约束
intcon = 1:n_flight;

tic
% TODO: 可以用gamultiobj，但为了实现整数规划，必须自己实现交配、变异、交叉
% TODO: 使用UseParallel会出现无法预料的bug，如何避免？
options = optimoptions(@ga, 'Display', 'iter', 'MaxStallGenerations', 100, 'UseParallel', false);
disp(options)
[x, fval, exitflag, output, population, scores] = ga(@fitness, n_flight, [], [], [], [], lb, ub, @nonlcon, intcon, options);
toc

%% 结果输出
x
