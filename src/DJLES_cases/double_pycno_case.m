clear all;
%mfilename produces the current path in which this .m file is located
%fileparts gives the full path of the directory that the filepath lives in
%full file adds the the DJLES directory (../external/DJLES) to the path
%add path adds this folder to MATLAB's search path.
addpath(fullfile(fileparts(mfilename('fullpath')), '..','..', 'external', 'DJLES'));

%We are aiming for an amplitude of approx 0.5, To get here, we try different A a values (standing for APE)
A = 5e-5; %Will eventually have to change this value to get to the correct amplitude of ampl = 0.05 m. 

L = 6;
H = 0.2;
ref_density = 10^3;

relax = 0.15; %strong underrelaxation. TODO: make sure I know what this means

%Velocity profile
Ubg=@(z) 0*z; Ubgz=@(z) 0*z; Ubgzz=@(z) 0*z;

%N_x and N_z for numerical derivatives:
%N_x = 2048;
%N_z = 256;


%First and second pycnocline centers (m), thickeness(m), and change in dens (kg/m^3)
z_1 = -0.05; d_1 = 0.01; delta_rho_1 = 0.04;
z_2 = -0.19; d_2 = 0.003; delta_rho_2 = 0.008;

%Density:
rho = @(z) 1 - delta_rho_1/2 * tanh((z-z_1) / d_1) - delta_rho_2/2*tanh((z-z_2)/d_2);
rhoz = @(z) -delta_rho_1/(2*d_1) * sech((z-z_1) / d_1).^2 - delta_rho_2/(2*d_2) * sech((z-z_2) / d_2).^2;

start_time = clock;
%iterate for different resolutions: 

NXlist=[  64   128    256   256     512];
NZlist=[  32    64    128   128     256];
for Nindex=1:length(NXlist)
    % Resolution for this wave
    NX = NXlist(Nindex);
    NZ = NZlist(Nindex);
    
    % Iterate the DJL solution
    djles_refine_solution
    djles_diagnostics; djles_plot; % uncomment to view progress at each step
end
%Specify resolution
NX = 2048; NZ=1024;
epsilon = 1e-5;
djles_refine_solution


%Bottom topography -- Save for SPINS. The ISW is initialized with a flat
%bottom topography.

end_time=clock;
fprintf('Total wall clock time: %f seconds\n',etime(end_time, start_time));

djles_diagnostics
djles_plot

%{
h_dep = 0.05; %max depth of depression
w_dep = 4; %governs the width of the depression
c_dep = 1; %Center of the depression

depression = @(x) h_dep.*(sech((x-c_dep)/w_dep)).^2;
%bottom boundary Layer
BBL = @(x) -H - depression(x);
%}

