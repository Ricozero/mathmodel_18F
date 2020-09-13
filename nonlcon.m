function [c, ceq] = nonlcon(x)
% 遗传算法的非线性约束
% x：航班与登机口的对应矩阵的展开，依次存储各个登机口的向量
    global n_gate
    global n_flight
    global T
    global T_gates
    x = reshape(x, n_gate, n_flight);
    x = x';
    % 0表示合理，1表示不合理
    c = zeros(n_flight, n_gate);
    % 寻找非零位置，即已安排登机口的位置
    [rows, cols] = find(x);
    % 匹配约束
%     for i = 1:size(rows, 1)
%         flight_no = rows(i);
%         gate_no = cols(i);
%         fa = T{flight_no, 'arrive_type'};
%         fd = T{flight_no, 'departure_type'};
%         ga = T_gates{gate_no, 'arrive_type'};
%         gd = T_gates{gate_no, 'departure_type'};
%         if ~contains(ga, fa) || ~contains(gd, fd)
%             c(flight_no, gate_no) = 1;
%         end
%     end 
    c = c(:);
    ceq = [];
end