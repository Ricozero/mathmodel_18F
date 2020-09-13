tic
for i = 1:10000
    flight_no = randi(n_flight);
    gate_no = randi(n_gate);
    fa = T{flight_no, 'arrive_type'};
    fd = T{flight_no, 'departure_type'};
    ga = T_gates{gate_no, 'arrive_type'};
    gd = T_gates{gate_no, 'departure_type'};
end
toc