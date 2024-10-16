function [mean_all, var_all, skew_all, kur_all, mean_per, var_per, skew_per, kur_per] = feature_moment(data_c_i_ch_j, percentage)
% feaure generation based on the moment
%
% The code can genereate the first, second, third, and fourth order moment
% for each cell.
%
% Author  : Yandong Lang
% Email   : yandong.lang@unsw.edu.au



mean_all = nanmean(data_c_i_ch_j);
var_all  = var(data_c_i_ch_j);
skew_all = skewness(data_c_i_ch_j);
kur_all  = kurtosis(data_c_i_ch_j);

percent_n = round(percentage*numel(data_c_i_ch_j));
[~,idx]   = sort(data_c_i_ch_j,'descend');
top_data  = data_c_i_ch_j(idx(1:percent_n));

mean_per = mean(top_data);
var_per  = var(top_data);
skew_per = skewness(top_data);
kur_per  = kurtosis(top_data);


end