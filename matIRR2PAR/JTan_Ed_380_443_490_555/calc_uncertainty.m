function e = calc_uncertainty(d, par)
    % CALC_UNCERTAINTY Calculates uncertainty based on depth and PAR values
    % Inputs:
    %   d   - array of depth values
    %   par - array of PAR values
    % Outputs:
    %   e   - array of calculated uncertainties
    %
    % Reads from 'JTan_Ed_380_443_490_555/LUT_par_uncertainty.txt' expecting groups of 3 lines:
    % Line 1: depth (integer)
    % Line 2: bins (comma-separated floats)
    % Line 3: rms values (comma-separated floats)

    % Read the lookup table file
    fid = fopen('JTan_Ed_380_443_490_555/LUT_par_uncertainty.txt', 'r');
    lines = textscan(fid, '%s', 'Delimiter', '\n');
    lines = lines{1};
    fclose(fid);

    % Initialize arrays
    num = floor(length(lines)/3);
    depth = zeros(num, 1);
    bins = cell(num, 1);
    rms = cell(num, 1);

    % Parse the file
    for i = 1:num
        line1 = lines{(i-1)*3 + 1};
        line2 = lines{(i-1)*3 + 2};
        line3 = lines{(i-1)*3 + 3};
        depth(i) = str2double(line1);
        bins{i} = str2num(line2);
        rms{i} = str2num(line3); 
    end

    % Convert cell arrays to matrices
    bins = cell2mat(bins);
    rms = cell2mat(rms);

    % Initialize output array
    e = nan(size(d));

    % Process each depth value
    for k = 1:length(d)
        % Find depth indices
        idx1 = find(depth >= d(k), 1); 
 
        if isempty(idx1)
            idx1 = length(depth);
        end
        
        if idx1>1
            idx1=idx1-1;
        end

        idx2=idx1+1; 

        % Find bin indices for idx1
        i1 = find(bins(idx1,:) >= par(k), 1);
        if isempty(i1)
            i1 = length(bins(idx1,:));
        end
        
        toolow = (i1 == 1);
        
        if toolow
            i2=i1;
        else
            i2=i1-1;
        end

        e1 = rms(idx1, i2);

        % Find bin indices for idx2
        j1 = find(bins(idx2,:) >= par(k), 1);
        if isempty(j1)
            j1 = length(bins(idx2,:));
        end

        toolow = (j1 == 1);
        
        if toolow
            j2=j1;
        else
            j2=j1-1;
        end

        e2 = rms(idx2, j2);

        % Calculate slope and interpolate

        % slope = (e2-e1)/(depth(idx2)-depth(idx1)); 
        % e(k) = slope * (d(k) - depth(idx1)) + e1; % Error when depth > 200 dbars

        % Modified from J. Tan’s version, based on her recommendations. 
        if idx1 == idx2
            slope = 0;   % handles case when depth > LUT (200 db)
        else
            slope = (e2-e1)/(depth(idx2)-depth(idx1));
        end
        e(k) = slope * (d(k) - depth(idx1)) + e1;
    end
end