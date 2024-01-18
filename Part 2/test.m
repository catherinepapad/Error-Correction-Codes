
% Clear the workspace
clear all; close all; clc;


r_avg = 6.5;
r = floor(r_avg);
l_max = 8;
epsilon = 0.4;
interval = 0.05;

[rho, lambda] = optimizeLDPC(r, r_avg, l_max, epsilon, interval);


n = 10;
[Lambda,Rho] = findLdpcPolynomials(rho, lambda, n);
