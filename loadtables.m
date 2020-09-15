function [T_puck, T_gate] = loadtables
% 读取航班信息
% 改1：表格删除所有时间前面的空格（比如“ 9:00”），避免被识别为NaN
% 改2：飞机型号设定为文本，但无法避免出现NaN，因此使用下文opts的方式
opts = detectImportOptions('InputData.xlsx');
opts.VariableNames = {' ', 'arrive_date', 'arrive_time', 'arrive_flight', 'arrive_type',  'plane_type', 'departure_date', 'departure_time', 'departure_flight', 'departure_type', 'prior_airport', 'next_airport'};
opts = setvartype(opts, 'plane_type', 'char');
opts.PreserveVariableNames = true;
%preview('InputData.xlsx', opts)
T_puck = readtable('InputData.xlsx', opts, 'ReadRowNames', true);

% 日期筛选：仅20日到达/出发
date = datetime('2018-01-20');
indices = [];
for i = 1:size(T_puck, 1)
    if T_puck{i, 'arrive_date'} == date || T_puck{i, 'departure_date'} == date
        indices = [indices i];
    end
end
T_puck = T_puck(indices, :);

% 读取登机口信息
T_gate = readtable('InputData.xlsx', 'Sheet', 3, 'ReadRowNames', true, 'PreserveVariableNames', true);
T_gate.Properties.VariableNames = {'hall', 'district', 'arrive_type', 'departure_type', 'plane_type'};
end
