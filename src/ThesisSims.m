%We run simulations of ISWs of Depression and Elevation over Depressions of
%Varying Thicknesses

%Important variables, set to Stastna's values:
%Depth (m) and reference density (kg/m^3);\
H = 0.2;
ref_density = 10^3;
%N_x and N_z for numerical derivatives:
%N_x = 2048;
%N_z = 256;


%First and second pycnocline centers (m), thickeness(m), and change in dens (kg/m^3)
z_1 = -0.05; d_1 = 0.01; delta_rho_1 = 0.04;
z_2 = -0.19; d_2 = 0.003; delta_rho_2 = 0.008;

%Bottom topography
h_dep = 0.05; %max depth of depression
w_dep = 4; %governs the width of the depression
c_dep = 1; %Center of the depression

depression = @(x) h_dep.*(sech((x-c_dep)/w_dep)).^2;
%bottom boundary Layer
BBL = @(x) -H - depression(x);

%Plot of the bottom boundary
figure;
plot(x,BBL(x), 'LineWidth',1.5);
xlabel('x');
ylabel('z');
grid on;

%Density:
rho = @(z) 1 - delta_rho_1/2 * tanh((z-z_1) / d_1) - delta_rho_2/2*tanh((z-z_2)/d_2);

%Plot Density:
z = linspace(0, -H-h_dep, 500);
rho_z = rho(z);

figure;
plot(rho_z, z, 'LineWidth', 1.5);
xlabel('\rho');
ylabel('z');
ylim([-H-h_dep 0]);
grid on;

%Central Difference to find N^2(z):




