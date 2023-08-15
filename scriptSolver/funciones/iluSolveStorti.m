%%% Try a preconditioner based on ILU factorization.
%%% Fill null diagonal elements with a given small value

function [x,flag,relres,niter,resvec,elaps] = iluSolveStorti(A,B)
    
tic;
%%% Load the functions
% frprecofuns;
%%% Define the struct of options
opts = struct;
%%% Type of ILU factorization
%%% opts.type = "crout";
%%% off diagonal elements grater than this threshold are discarded
opts.droptol = 0.1;
%%% This is specific for frpreco. Defines the scale
%%% for the diagonal elements to be added to the null
%%% diagonal elements
% opts.mdfac = 0.1;
%%% Compute the preco (ILU factorization of the matrix)
%%% Store the data in struct "data"
data = mkfrpreco(A,opts);

%%% Relative tolerance for convergence of iterative method 
rtol = 1e-6;
[x,flag,relres,niter,resvec] = bicgstab(A,B,rtol,1000,@frpreco,[],0*B,data);
elaps = toc;
end

%%% Print results
% fprintf('flag %d, niter %d, rel.res %g, N=%d, elaps %fs\n',...
%        flag,2*niter,resvec(end)/resvec(1),length(B),elaps);
% assert(~flag);
%%% Save the data in HDF5 file
%%% save -hdf5 tmp.h5 x resvec niter elaps
