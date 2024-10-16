function [feature_table, nc_t] = feature_table_YL_v2(n_feature, nchannel, n_pic, percentage, hs_data, mask_data)
% Generating a feature table based on the hyperspectrum data
%
% Author  : Yandong Lang
% Email   : yandong.lang@unsw.edu.au

if nargin ~= 6
    error(message('there should be 6 inputs'));
end

nc_t = 0;

if nchannel > 2
    nchannel = nchannel - 1;
end

feature_table = zeros(1000, n_feature, nchannel);

mask_data_loaded = cell(n_pic, 1);
for i = 1:n_pic
    mask_data_loaded{i} = logical(imread(mask_data(i).name));
end

for i = 1:n_pic
    HS_i = load(hs_data(i).name).HAC_Image.imageStruct.data;
    mask_data_i = mask_data_loaded{i};
    nc = length(regionprops(mask_data_i, 'PixelIdxList'));
    ft_ch = cell(1, nchannel);
    max_n = 0;
    for j = 1:nchannel
        HS_i_j = HS_i(:, :, j);
        HS_i_j_flat = HS_i_j(mask_data_i);
        [mean_ijk, var_ijk, skew_ijk, kur_ijk, top_mean_ijk, top_var_ijk, top_skew_ijk, top_kur_ijk] = ...
            feature_moment(HS_i_j_flat, percentage);
        feature_table_cell = [mean_ijk, var_ijk, skew_ijk, kur_ijk, top_mean_ijk, top_var_ijk, top_skew_ijk, top_kur_ijk];
        pixel_idx_list = regionprops(mask_data_i, 'PixelIdxList');
        pixel_idx_list = cellfun(@(x) x(:), {pixel_idx_list.PixelIdxList}, 'UniformOutput', false);
        pixel_idx_list = cell2mat(pixel_idx_list);
        ft_ch{j} = feature_table_cell(pixel_idx_list, :);
        max_n = max(max_n, size(ft_ch{j}, 1));
    end
    for j = 1:nchannel
        if size(ft_ch{j}, 1) < max_n
            ft_ch{j} = [ft_ch{j}; zeros(max_n - size(ft_ch{j}, 1), n_feature)];
        end
    end
    nc_t = nc_t + nc;
    feature_table(nc_t-nc+1:nc_t, :, :) = cat(3, ft_ch{:});
end
feature_table = feature_table(1:nc_t, :, :);
end
