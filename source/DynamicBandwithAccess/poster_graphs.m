close all
clear

s_a = 10;
s_b = 8;
s_c = 11;

t = 0:74;
t = [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 25 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40.0...
    41 42 43 44 45 46 47 48 50 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74];

s_temporal_fast = [0.4 1.8 3 4.3 4.4 4.1 5.6 5.7 5.3 5.4 5.8 5.9 5.6 5.8 5.2 5.9 5.7 5.8 5.4 5.8 5.2 5.9 5.7 5.8 5.4...
    2.3 3.4 3.1 4.4 4.2 4.8 5.1 4.9 4.8 4.9 5.1 4.9 5.0 4.8 4.7 5.0 4.8 5.1 4.9 4.8 4.95 4.9 4.9 4.95 4.8...
    1.8 2.4 3.1 4.0 4.5 4.9 5.3 5.9 5.8 6.4 6.1 6.9 7.0 7.3 7.7 7.3 7.8 7.8 7.9 7.8 7.55 7.85 7.6 7.95 7.8];

s_temporal_optimal = [0.4 0.5 1 1.1 1.3 1.2 1.5 1.6 1.5 1.9 2.4 2.9 5.6 7.9 8.3 7.95 8.5 8.4 8.5 7.9 8.3 7.95 8.5 8.4 8.5...
    1.5 1.8 1.9 2.1 2.3 2.4 2.5 2.6 2.9 3.0 3.4 3.9 6.6 6.9 7.1 6.95 6.9 7.3 7.25 6.9 7.1 6.95 6.9 7.3 7.25...
    1.2 1.5 1.9 2.2 2.5 2.8 2.9 2.97 3.6 3.7 3.4 3.9 4.2 4.5 4.8 5.35 5.9 6.3 6.5 7.9 8.5 9.7 9.6 9.5 9.65];

s_ideal = [s_a s_a s_a s_a s_a s_a s_a s_a s_a s_a s_a s_a s_a s_a s_a s_a s_a s_a s_a s_a s_a s_a s_a s_a s_a...
    s_b s_b s_b s_b s_b s_b s_b s_b s_b s_b s_b s_b s_b s_b s_b s_b s_b s_b s_b s_b s_b s_b s_b s_b s_b...
    s_c s_c s_c s_c s_c s_c s_c s_c s_c s_c s_c s_c s_c s_c s_c s_c s_c s_c s_c s_c s_c s_c s_c s_c s_c];

size(t)
size(s_temporal_fast)
size(s_temporal_optimal)
size(s_ideal)

plot(t, s_temporal_fast);
hold on
plot(t, s_temporal_optimal)
plot(t, s_ideal,'-');


title('DCB effect on Throughput');
xlabel('time');
ylabel('Throughput');
legend('Fast-convergence', 'Optimal-convergence', 'Ideal throughput');
axis([0 75 0 14])
set(gca, 'XTick', []);
set(gca, 'YTick', []);
grid on