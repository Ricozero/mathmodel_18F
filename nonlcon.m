function [c, ceq] = nonlcon(x)
% 遗传算法的非线性约束
% x：航班与登机口的对应矩阵的展开，依次存储各个登机口的向量
    global n_flight
    global T
    global T_gates
    % 0表示合理，1表示不合理
    c = zeros(n_flight);
    % 匹配约束
    wide_list = ['332', '333', '33E', '33H', '33L', '773'];
    for flight_no = 1:n_flight
        gate_no = x(flight_no);
        if gate_no ~= 0
            pt = T{flight_no, 'plane_type'};
            if T_gates{gate_no, 'plane_type'}{1} == 'W'
                if ~ismember(pt, wide_list)
                    c(flight_no, gate_no) = 1;
                    continue
                end
            else
                if ismember(pt, wide_list)
                    c(flight_no, gate_no) = 1;
                    continue
                end
            end
            fa = T{flight_no, 'arrive_type'};
            fd = T{flight_no, 'departure_type'};
            ga = T_gates{gate_no, 'arrive_type'};
            gd = T_gates{gate_no, 'departure_type'};
            if ~contains(ga, fa) || ~contains(gd, fd)
                c(flight_no, gate_no) = 1;
            end
        end
    end 
    c = c(:);
    ceq = [];
end