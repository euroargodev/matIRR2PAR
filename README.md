# matIRR2PAR
Calculation of PAR from multispectral irradiance profiles according to Argo recommendations (MATLAB version)

**⚠️ Under Validation (Do Not Use Yet)**
This code is currently under review and validation. It is not yet ready for use. Please check back later for updates

the Python version is [here](https://github.com/euroargodev/pyIRR2PAR)

# Objectives and Background
The Photosynthetically Available Radiation (PAR) is a radiometric parameter that has been measured on floats since the beginning of the BGC mission. It is particularly important to estimate Primary Production or to help for Chla processing. This parameter was traditionally measured using the OCR504 radiometer and was typically associated with wavelengths:  380, 412, and 490 nm. In accordance with the recommendations approved during AST-24, this configuration was replaced by: 380, 443, 490, and 555 nm (without direct PAR measurement) due to new scientific applications and the potential ability to derive PAR measurements from the four measured wavelengths [Organelli_WG_Radiometry_AST24_20March2023.pdf](https://drive.google.com/file/d/1HhDM9NZMGbhgXSlx_RA4Nooc2g_KlGUH/view?usp=sharing). 

The purpose of this Python code is to provide a wrapper for the two models evaluated within the Argo framework. It uses as input a matrix of four irradiance values at **380, 443, 490, and 555 nm**, along with the associated depth vector, and calculates the outputs of both models as well as the average of the calculated PAR values, which is the PAR estimate to be considered as recommended during ADMT26 [ADMT26-Leymarie-PAR Model.pptx](https://docs.google.com/presentation/d/1edo8Na_IFxEJGKgBwDNWRhW9zqafZP9W/edit?usp=drive_link&ouid=112140535291181030156&rtpof=true&sd=true).

# How to use this package
[JTan_PAR_results, JPitarch_PAR_results, mean_PAR, mean_uncertainty] = IRR2PAR(Ed, z)

Parameters:
* Ed -- N x 4 array  [Ed380, Ed443, Ed490, Ed555] in W/m²/nm
* z  -- N x 1 array   depth (m)

Results: 
* JTan_PAR_results    -- cell {JTan_PAR, JTan_e}
* JPitarch_PAR_results-- cell {JPitarch_PAR, JPitarch_PAR_b, JPitarch_ep50, JPitarch_IQR_ep, JPitarch_e}
* mean_PAR            -- N x 1  mean of JTan_PAR and JPitarch_PAR (ignoring NaN)
* mean_uncertainty    -- N x 1  combined uncertainty

All PAR values are in microMoleQuanta/m^2/sec

# Bibliography
We would like to warmly thank Jaime Pitarch and Jing Tan for their work and for making their code available to the community.
* Pitarch, J., Leymarie, E., Vellucci, V., Massi, L., Claustre, H., Poteau, A., Antoine, D., Organelli, E., 2025. Accurate estimation of photosynthetic available radiation from multispectral downwelling irradiance profiles. Limnology and Oceanography: Methods. [https://doi.org/10.1002/lom3.10673](https://doi.org/10.1002/lom3.10673)
GitHub original repository : [PAR_BGC_Argo](https://github.com/euroargodev/PAR_BGC_Argo)
  
* Tan, J., Frouin, R., Leymarie, E., Mitchell, B.G., 2025. Modeling underwater photosynthetically available radiation profiles from biogeochemical Argo floats using multi-spectral irradiance measurements. Opt. Express, OE 33, 44355–44377. [https://doi.org/10.1364/OE.566083](https://doi.org/10.1364/OE.566083)
GitHub original repository : [BioArgo_PAR](https://github.com/jit079/BioArgo_PAR)

# How to cite this calculation
If you use this package, please cite the original work by J. Pitarch and J. Tan and note that the PAR estimate is the average of these two models.
