
addpath('/home/lule1957/Internal-Wave-Simulations-Thesis/external/SPINSmatlab/IO')
cd('/scratch/alpine/angr1272/double_pycnocline_ISW/base_dens/')

rho = spins_reader('rho', 20);
u = spins_reader('u', 20);
w = spins_reader('w', 20);

cd('/home/lule1957/Internal-Wave-Simulations-Thesis/matlab_data/')

figure
title('rho')
imagesc(rho)
axis xy
colorbar

figure
imagesc(u)
axis xy
colorbar
title('u')

figure
imagesc(w)
axis xy
colorbar
title('w')