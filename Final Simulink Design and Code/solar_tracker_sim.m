% Solar Tracker Simulation
% Developed for CSE 271s - Single-Axis Solar Tracking System

clc;
clear;

% --- Load predefined light motion data (if available) ---
load('V.mat'); % This file contains light position data (assumed)

% --- Time vector ---
t = 0:0.01:10; % 10 seconds simulation

% --- Simulated light source motion (if V is not defined) ---
if ~exist('V', 'var')
    V = sin(2 * pi * 0.1 * t); % sinusoidal light movement
end

% --- Distance to resistance mapping (sigmoid approximation) ---
% Assuming resistance range: 1kΩ (close) to 10kΩ (far)
resistance = 1e3 + 9e3 ./ (1 + exp(-5 * V)); % Sigmoid behavior

% --- LDR Voltage Divider Simulation ---
% Vout = Vcc * R_LDR / (R_fixed + R_LDR)
Vcc = 5;
R_fixed = 10e3; % 10kΩ
V_LDR = Vcc .* resistance ./ (R_fixed + resistance);

% --- Differential amplifier stage ---
% Vdiff = V_LDR2 - V_LDR1 (simulate two opposite LDRs)
V_LDR1 = V_LDR;
V_LDR2 = flip(V_LDR); % simulate inverse behavior
V_diff = V_LDR2 - V_LDR1;

% --- Super diode (only allow positive values) ---
V_positive = max(V_diff, 0);

% --- PWM generation using duty cycle modulation ---
% Map V_positive (0 to ~5V) -> duty cycle (0% to 100%)
duty_cycle = min(max(V_positive / 5, 0), 1); % normalize

% --- PWM signal creation ---
fs = 144;  % 144 Hz PWM frequency
Ts = 1 / fs;
pwm_signal = zeros(size(t));
for i = 1:length(t)
    pwm_signal(i) = square(2 * pi * fs * t(i), duty_cycle(i) * 100);
end

% --- Motor speed approximation (simplified DC motor model) ---
% Motor speed is proportional to duty cycle
motor_speed = duty_cycle * 100; % speed in %

% --- Plotting Results ---
figure;
subplot(4,1,1);
plot(t, V_LDR1, t, V_LDR2);
title('LDR Voltages');
legend('LDR1', 'LDR2');
ylabel('Voltage (V)');

subplot(4,1,2);
plot(t, V_diff);
title('Differential Amplifier Output');
ylabel('V_{diff} (V)');

subplot(4,1,3);
plot(t, duty_cycle * 100);
title('PWM Duty Cycle');
ylabel('Duty Cycle (%)');

subplot(4,1,4);
plot(t, motor_speed);
title('Motor Speed');
xlabel('Time (s)');
ylabel('Speed (%)');
