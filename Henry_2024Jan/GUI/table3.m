%%
function feature_table = table3(label, nchannel, n_pic, s_HAC_all, s_mask_all)
n_feature = 8;
percentage = 0.1;
[feature_table_all, n_cell_tot] = feature_table_YL(n_feature, nchannel, n_pic, percentage, s_HAC_all, s_mask_all);
feature_table = zeros(n_cell_tot,7);
feature_table(:,1) = feature_table_all(:,5,18)./ feature_table_all(:,5,17); % No.1
feature_table(:,2) = feature_table_all(:,1,19)./ feature_table_all(:,1,17); % No.2
feature_table(:,3) = feature_table_all(:,5,9)./ feature_table_all(:,5,28);  % No.3
feature_table(:,4) = feature_table_all(:,5,19)./ feature_table_all(:,5,17); % No.4
feature_table(:,5) = feature_table_all(:,1,1)./ feature_table_all(:,5,2); % No.5
feature_table(:,6) = feature_table_all(:,5,27)./ feature_table_all(:,5,1); % No.6
% Add the label as the last column in the table
feature_table(:,7) = label;
end