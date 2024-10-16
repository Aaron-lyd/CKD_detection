function [feature_table, nc_t] = feature_table_YL(n_feature, nchannel, n_pic, percentage, hs_data, mask_data)
% Generating a feature table based on the hyperspectrum data
%
%
% Author  : Yandong Lang
% Email   : yandong.lang@unsw.edu.au


if nargin ~= 6
    error(message('there should be 6 inputs'));
end

flat = @(F) F(:);

nc_t = 0;

if nchannel > 2
    nchannel = nchannel -1;
end

feature_table = zeros(1000, n_feature, nchannel); 

for i = 1:n_pic
    HS_i = load(hs_data(i).name).HAC_Image.imageStruct.data;
    nc = length(bwconncomp(imread(mask_data(i).name)).PixelIdxList); 
    ft_ch = zeros(nc, n_feature, nchannel); 
    for j = 1:nchannel 
        HS_i_j = HS_i(:,:,j); 
        HS_i_j_flat = flat(HS_i_j); 
        feature_table_cell = zeros(nc,n_feature); 
        for k = 1:nc
            data_pi_chj_ck = HS_i_j_flat(bwconncomp(imread(mask_data(i).name)).PixelIdxList{k});
            [mean_ijk,var_ijk,skew_ijk,kur_ijk, top_mean_ijk,top_var_ijk,top_skew_ijk,top_kur_ijk] ...
                                                                            = feature_moment(data_pi_chj_ck, percentage);
            feature_table_cell(k,:) =...
                [mean_ijk,var_ijk,skew_ijk,kur_ijk, top_mean_ijk,top_var_ijk,top_skew_ijk,top_kur_ijk];
        end
        ft_ch(:,:,j) = feature_table_cell;
    end
    nc_t = nc_t + nc; 
    feature_table(nc_t-nc+1 :nc_t,:,:) = ft_ch; 
end
feature_table = feature_table(1:nc_t,:,:); 


end