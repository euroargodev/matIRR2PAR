function [par_mean, e] = reconstruct_par(profile)
    % RECONSTRUCT_PAR Reconstructs PAR (Photosynthetically Active Radiation) and its uncertainty
    % Inputs:
    %   profile - 2D array (n_depth x 5) with columns [Ed380, Ed443, Ed490, Ed555, depth]
    % Outputs:
    %   par_mean - Mean PAR values across depth
    %   e        - Combined uncertainty
    %
    % Requires:
    %   b_spline_basis.m - Function to compute B-spline basis
    %   calc_uncertainty.m - Function to compute uncertainty
    %   coeff.txt - Coefficient file

    % Constants
    f0_par = 2411.2579039931697;
    f0_Ed = [117.1379, 195.4065, 202.604, 188.264];

    % Load coefficients
    coef = readmatrix('JTan_Ed_380_443_490_555/coeff.txt');
    coef = reshape(coef, [4, 100, 100]);

    % Compute B-spline basis for depth (last column of profile)
    b = b_spline_basis(profile(:, end));

    % Initialize PAR array
    par = nan(size(profile, 1), 100);

    % Compute PAR for each spline
    for j = 1:100
        par(:, j) = ((b * squeeze(coef(1, j, :))) .* profile(:, 1)/f0_Ed(1) + ...
                     (b * squeeze(coef(2, j, :))) .* profile(:, 2)/f0_Ed(2) + ...
                     (b * squeeze(coef(3, j, :))) .* profile(:, 3)/f0_Ed(3) + ...
                     (b * squeeze(coef(4, j, :))) .* profile(:, 4)/f0_Ed(4)) * f0_par;
    end

    % Compute uncertainties
    e1 = std(par, 0, 2); % Standard deviation along second dimension
    e2 = calc_uncertainty(profile(:, end), mean(par, 2));
    e = sqrt(e1.^2 + e2.^2);

    % Compute mean PAR
    par_mean = mean(par, 2);
end