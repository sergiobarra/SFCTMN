clc

T_e = 9E-6;
T_SIFS = 16E-6;
T_DIFS = 34E-6;
T_RTS = 0.056E-3;
T_CTS = 0.048E-3;
T_DATA = 0.276E-3;
T_BACK = 0.1E-3;

% Successful slot
T_su = T_RTS + T_SIFS + T_CTS + T_SIFS + T_DATA + T_SIFS + T_BACK + T_DIFS + Te; % (Implicit BACK request)

% Collision slot
T_c = T_RTS + T_SIFS + T_CTS + T_DIFS + Te;

% fprintf('- T_su = %f ms\n', T_su * 1E3);
% fprintf('- T_c = %f ms\n', T_c * 1E3);

fprintf('- T_RTS = %f ms\n', T_RTS * 1E3);
fprintf('- T_RTS + T_SIFS + T_CTS = %f ms\n', (T_RTS + T_SIFS + T_CTS) * 1E3);
fprintf('- T_RTS + T_SIFS + T_CTS + T_DIFS  + Te = %f ms\n', (T_RTS + T_SIFS + T_CTS + T_DIFS + Te) * 1E3);

%% Komondor

T_RTS_k = 0.000090000000000 - 0.000034000000000;
T_TO_k = T_RTS_k + 0.000154000000000 - 0.000090000000000;
T_c_k = 0.000188000000000 + Te  - 0.000034000000000;

fprintf('----------------------------\n');
fprintf('- T_RTS_k = %f ms\n', T_RTS_k * 1E3);
fprintf('- T_TO_k = %f ms\n', T_TO_k * 1E3);
fprintf('- T_c = %f ms\n', T_c_k * 1E3);
