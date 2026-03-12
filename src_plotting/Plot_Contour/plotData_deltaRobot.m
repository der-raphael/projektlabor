clc;
clear;
close all;

% Datei laden (keine Überschriften)
data = readmatrix('deltarobot_curve2.csv');

% Spalten zuweisen
x = data(:,1);
y = data(:,2);
z = data(:,3);

% 3D Plot
scatter3(x, y, z);
grid on;

xlim([0 3000]);
ylim([0 3000]);
zlim([0 3000]);