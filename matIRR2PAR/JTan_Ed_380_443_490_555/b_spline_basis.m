function bases = b_spline_basis(x)
    % B_SPLINE_BASIS Generates B-spline basis using vectorized De Boor recursion
    % The basis functions extrapolate linearly past the end-knots.
    % Code is based on:
    % Servén D., Brummitt C. (2018). pyGAM: Generalized Additive Models in Python. Zenodo.
    % DOI: 10.5281/zenodo.1208723
    %
    % Parameters
    % ----------
    % x : array-like, with ndims == 1.
    %
    % Returns
    % -------
    % basis : array containing B-spline basis functions
    %         with shape (length(x), n_splines)

    % Initialize parameters
    edge_knots = [0, 200];
    n_splines = 100;
    spline_order = 3;

    % Rescale edge_knots to [0,1], and generate boundary knots
    edge_knots = sort(edge_knots);
    offset = edge_knots(1);
    scale = edge_knots(end) - edge_knots(1);
    boundary_knots = linspace(0, 1, n_splines - spline_order + 1);
    diff = boundary_knots(2) - boundary_knots(1);

    % Rescale x
    x = (x(:) - offset) / scale;

    % Append 0 and 1 for extrapolation
    x = [x; 0; 1];

    % Determine extrapolation indices
    x_extrapolate_l = x < 0;
    x_extrapolate_r = x > 1;
    x_interpolate = ~(x_extrapolate_r | x_extrapolate_l);

    % Formatting
    x = x(:);

    % Augment knots
    aug = (1:spline_order) * diff;
    aug_knots = [-fliplr(aug), boundary_knots, 1 + aug];
    aug_knots(end) = aug_knots(end) + 1e-9; % Make last knot inclusive

    % Prepare Haar Basis
    bases = double(x >= aug_knots(1:end-1)) .* double(x < aug_knots(2:end));
    bases(end, :) = fliplr(bases(end-1, :)); % Force symmetric bases at 0 and 1

    % Do recursion from Hastie et al. vectorized
    maxi = length(aug_knots) - 1;
    for m = 2:(spline_order + 1)
        maxi = maxi - 1;

        % Left sub-basis
        num = x - aug_knots(1:maxi);
        num = num .* bases(:, 1:maxi);
        denom = aug_knots(m:maxi+m-1) - aug_knots(1:maxi);
        left = num ./ denom;

        % Right sub-basis
        num = (aug_knots(m+1:maxi+m) - x) .* bases(:, 2:maxi+1);
        denom = aug_knots(m+1:maxi+m) - aug_knots(2:maxi+1);
        right = num ./ denom;

        % Track previous bases and update
        prev_bases = bases(end-1:end, :);
        bases = left + right;
    end

    % Extrapolate
    % Since we have repeated end-knots, only the last 2 basis functions are
    % non-zero at the end-knots, and they have equal and opposite gradient.
    if any(x_extrapolate_r) || any(x_extrapolate_l)
        bases(~x_interpolate, :) = 0;
        denom = aug_knots(spline_order+1:end-1) - aug_knots(1:end-spline_order-1);
        left = prev_bases(:, 1:end-1) ./ denom;
        denom = aug_knots(spline_order+2:end) - aug_knots(2:end-spline_order);
        right = prev_bases(:, 2:end) ./ denom;
        grads = spline_order * (left - right);

        if any(x_extrapolate_l)
            val = grads(1, :) .* x(x_extrapolate_l) + bases(end-1, :);
            bases(x_extrapolate_l, :) = val;
        end

        if any(x_extrapolate_r)
            val = grads(2, :) .* (x(x_extrapolate_r) - 1) + bases(end, :);
            bases(x_extrapolate_r, :) = val;
        end
    end

    % Remove the added values at 0 and 1
    bases = bases(1:end-2, :);
end