function [c, ceq] = nonlcon(x)
% 遗传算法的非线性约束
    global n_flight
    global flight_pt
    global gate_pt
    global flight_type
    global gate_type
    % 0表示合理，1表示不合理
    c = zeros(n_flight);
    % 匹配约束
    for flight_no = 1:n_flight
        gate_no = x(flight_no);
        if gate_no ~= 0
            if flight_pt(flight_no) ~= gate_pt(gate_no)
                c(flight_no, gate_no) = 1;
                continue
            end
            if ~gate_type(gate_no, flight_type(flight_no))
                c(flight_no, gate_no) = 1;
                continue
            end
        end
    end
    % 约束结果
    c = c(:);
    ceq = [];
end