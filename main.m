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
global T_gates
T_gates = readtable('InputData.xlsx', 'Sheet', 3, 'ReadRowNames', true, 'PreserveVariableNames', true);
T_gates.Properties.VariableNames = {'hall', 'district', 'arrive_type', 'departure_type', 'plane_type'};

%% 定义登机口数和航班数
global n_gate
global n_flight
n_gate = 69;
n_flight = size(T, 1);

%% 约束与运行
% 不适用onehot编码，而是使用1-69表示分配的登机口，0表示不分配
% 这样做可以直接满足唯一性约束，避免收敛还无法满足约束的情况
% 登机口数约束
lb = zeros(n_flight, 1);
ub = ones(n_flight, 1) * n_gate;
% 整数约束
intcon = 1:n_flight;

tic
% TODO: 也许可以用gamultiobj？
% TODO: 使用UseParallel会出现无法预料的bug，如何避免？
options = optimoptions(@ga, 'Display', 'iter', 'UseParallel', false);
disp(options)
[x, fval, exitflag, output, population, scores] = ga(@fitness, n_flight, [], [], [], [], lb, ub, @nonlcon, intcon, options);
toc

%% 结果输出
x
