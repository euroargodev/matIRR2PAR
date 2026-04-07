function [JTan_PAR_results, JPitarch_PAR_results, mean_PAR, mean_uncertainty] = IRR2PAR(Ed, z)
% Combines the results of the PAR models from
%     -   JTan_2025:  Tan, J., Frouin, R., Leymarie, E., Mitchell, B.G., 2025. Modeling underwater photosynthetically available radiation
%     profiles from biogeochemical Argo floats using multi-spectral irradiance measurements. Opt. Express, OE 33, 44355–44377.
%     https://doi.org/10.1364/OE.566083
% 
%     -   JPitarch_2025 : Pitarch, J., Leymarie, E., Vellucci, V., Massi, L., Claustre, H., Poteau, A., Antoine, D., Organelli, E., 2025.
%     Accurate estimation of photosynthetic available radiation from multispectral downwelling irradiance profiles.
%     Limnology and Oceanography: Methods n/a. https://doi.org/10.1002/lom3.10673
%
%   Usage
%   -----
%   [JTan_PAR_results, JPitarch_PAR_results, mean_PAR, mean_uncertainty] = IRR2PAR(Ed, z)
%
%   Parameters
%   ----------
%   Ed : N x 4 array  [Ed380, Ed443, Ed490, Ed555] in W/m²/nm
%   z  : N x 1 array   depth (m)
%
%   Returns
%   -------
%   JTan_PAR_results    : cell {JTan_PAR, JTan_e}
%   JPitarch_PAR_results: cell {JPitarch_PAR, JPitarch_PAR_b, JPitarch_ep50, JPitarch_IQR_ep, JPitarch_e}
%   mean_PAR            : N x 1  mean of JTan_PAR and JPitarch_PAR (ignoring NaN)
%   mean_uncertainty    : N x 1  combined uncertainty
%
%   Dependencies
%   ------------
%   - reconstruct_par.m                 : JTan 2025 PAR model
%       - b_spline_basis.m              :   B-spline basis generator
%       - calc_uncertainty.m            :   Uncertainty LUT lookup
%   - PAR_from_Ed_380_443_490_555_v5.m  : JPitarch 2025 PAR model (self-contained)
%
%--------------------------------------------------------------------------

% Call reconstruct_par (JTan_2025) with input in uW/cm2
profile = [100 * Ed, z];
[JTan_PAR, JTan_e] = reconstruct_par(profile);
JTan_PAR_results = {JTan_PAR, JTan_e};

% remove negative values for JPitarch_2025
Ed(Ed < 0) = NaN;

% Modify negative depth values for JPitarch_2025, as it uses a logarithmic transformation of z.
z(z <= 0) = 1e-6;

% Call PAR_from_Ed_380_443_490_555_v5 (JPitarch_2025)
[JPitarch_PAR, JPitarch_PAR_b, JPitarch_ep50, JPitarch_IQR_ep] = PAR_from_Ed_380_443_490_555_v5(Ed, z);

% Stack JTan_PAR and JPitarch_PAR into a 2D array
values = [JTan_PAR, JPitarch_PAR];

% Calculate the mean, ignoring NaN values
mean_PAR = mean(values, 2, 'omitnan');

% Uncertainties
% Convert IQR_ep to absolute uncertainty
JPitarch_e = JPitarch_PAR .* (JPitarch_IQR_ep / 100);
JPitarch_PAR_results = {JPitarch_PAR, JPitarch_PAR_b, JPitarch_ep50, JPitarch_IQR_ep, JPitarch_e};

% Calculate mean_uncertainty based on NaN conditions
mean_uncertainty = NaN(size(JTan_PAR));
for k = 1:numel(JTan_PAR)
    if isnan(JPitarch_PAR(k))         % If JPitarch_PAR is NaN
        if isnan(JTan_PAR(k))         % If JTan_PAR is also NaN
            mean_uncertainty(k) = NaN;        % mean_uncertainty is NaN
        else
            mean_uncertainty(k) = JTan_e(k);  % mean_uncertainty is JTan_e
        end
    else
        if isnan(JTan_PAR(k))                 % If JTan_PAR is NaN
            mean_uncertainty(k) = JPitarch_e(k);                              % mean_uncertainty is JPitarch_e
        else
            %mean_uncertainty(k) = sqrt(JTan_e(k)^2 + JPitarch_e(k)^2) / 2;  % If neither is NaN, use RSS method
			mean_uncertainty(k) = (JTan_e(k) + JPitarch_e(k)) / 2;              % If neither is NaN, use LPU assuming full correlation
        end
    end
end




% % %Example
% % %usage:
% Ed = [3.1477e-07, 4.401e-05, 0.00031093, 2.6219e-05;
%       0.0097528,  0.061085,  0.10562,    0.087316;
%       0.20572,    0.52315,   0.54544,    0.16185];
% z = [84.8; 14.2; 28.1];
% 
% % Call IRR2PAR
% [JTan_PAR_results, JPitarch_PAR_results, mean_PAR, mean_uncertainty] = IRR2PAR(Ed, z);
% 
% % Display results
% disp('Résultats de JTan_PAR_results :');    disp{JTan_PAR_results};
% disp('Résultats de JPitarch_PAR_results :'); disp(JPitarch_PAR_results);
% disp('Vecteur moyen (mean_par + PAR) :');   disp(mean_PAR);