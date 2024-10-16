function feature_generation_T3_pro7()


fig = figure('Name','Data Loader','MenuBar','none','ToolBar','none','Position',[400 400 800 350]);

file_panel = uipanel('Parent', fig, 'Title', 'Data Files', 'Position', [0.05 0.6 0.9 0.35]);

hs_browse_btn = uicontrol('Parent', file_panel, 'Style','pushbutton','String','Browse Hyperspectral Data','Position',[10 80 160 25],'Callback',@hs_browse_callback);
hs_folder_txt = uicontrol('Parent', file_panel, 'Style','text','Position',[170 80 320 25],'HorizontalAlignment','left');

m_browse_btn = uicontrol('Parent', file_panel, 'Style','pushbutton','String','Browse Mask Data','Position',[10 30 120 25],'Callback',@m_browse_callback);
m_folder_txt = uicontrol('Parent', file_panel, 'Style','text','Position',[170 30 320 25],'HorizontalAlignment','left');

input_panel = uipanel('Parent', fig, 'Title', 'Input Fields', 'Position', [0.05 0.25 0.9 0.35]);

label_inst = uicontrol('Parent', input_panel, 'Style','text','Position',[10 80 120 25],'HorizontalAlignment','left','String','Enter label:');
label_txt = uicontrol('Parent', input_panel, 'Style','edit','Position',[140 80 60 25],'HorizontalAlignment','left','String','');

% Add radio buttons for choosing the table
table_radio = uibuttongroup('Parent', input_panel, 'Position', [0.6 0.3 0.3 0.6]);
table3_radio = uicontrol('Parent', table_radio, 'Style', 'radiobutton', 'String', 'Table 3', 'Position', [10 40 80 20]);
table4_radio = uicontrol('Parent', table_radio, 'Style', 'radiobutton', 'String', 'Table 4', 'Position', [10 20 80 20]);
table5_radio = uicontrol('Parent', table_radio, 'Style', 'radiobutton', 'String', 'Table 5', 'Position', [10 0 80 20]);
table6_radio = uicontrol('Parent', table_radio, 'Style', 'radiobutton', 'String', 'Table 6', 'Position', [90 40 80 20]);

output_panel = uipanel('Parent', fig, 'Title', 'Output Fields', 'Position', [0.05 0.1 0.9 0.15]);

cell_count_txt = uicontrol('Parent', output_panel, 'Style','text','Position',[10 5 200 25],'HorizontalAlignment','left','String','Total cell numbers: 0');

load_btn = uicontrol('Parent', fig, 'Style','pushbutton','String','Load Data','Position',[200 10 100 30],'Callback',@load_callback,'Enable','off');
% Callback function for hyperspectral image data browse button
    function hs_browse_callback(~,~)

        folder_path = uigetdir('','Select folder containing hyperspectral image data');
        if folder_path ~= 0
            set(hs_folder_txt,'String',folder_path);
            set(load_btn,'Enable','on');
        end
    end

% Callback function for mask data browse button
    function m_browse_callback(~,~)
        folder_path = uigetdir('','Select folder containing mask data');
        if folder_path ~= 0
            set(m_folder_txt,'String',folder_path);
            set(load_btn,'Enable','on');
        end
    end

% Callback function for load button
    function load_callback(~,~)
        %Create a progress bar window
        progress_bar = waitbar(0, 'Loading Data...');
        % Get the paths to the selected folders
        hs_folder_path = get(hs_folder_txt,'String');
        m_folder_path = get(m_folder_txt,'String');
        % Get n_feature, percentage and label
        
        
        label_str = get(label_txt,'String');
        if ~isempty(label_str)
            label = str2double(label_str);
        else
            label = NaN;
        end
        
        % Check if the input values are valid
        if isnan(label)
            errordlg('Please enter valid values for label.');
            close(progress_bar);
            return;
        end
        % Get the selected feature table
        selected_table = get_selected_table();
        
        % Load and sort the hyperspectral image data
        waitbar(0.2, progress_bar, 'Loading Hyperspectral Data...');
        fprintf('hs_folder_path: %s\n', hs_folder_path);
        fprintf('m_folder_path: %s\n', m_folder_path);
        
        HAC_all = dir(fullfile(hs_folder_path,'*.mat'));
        if isempty(HAC_all)
            errordlg('No hyperspectral image data found in the specified folder.');
            close(progress_bar);
            return;
        end
        s_HAC_all = natsortfiles(HAC_all);
        
        n_pic = length(HAC_all);
        [~,~,nchannel] = size(load(fullfile(hs_folder_path, HAC_all(1).name)).HAC_Image.imageStruct.data);
        
        
        % Load and sort the mask data
        waitbar(0.4, progress_bar, 'Loading Mask Data...');
        mask_all = dir(fullfile(m_folder_path,'*.png'));
        if isempty(mask_all)
            errordlg('No mask data found in the specified folder.');
            close(progress_bar);
            return;
        end
        s_mask_all = natsortfiles(mask_all);
        fprintf('mask_data type: %s\n', class(s_mask_all));
        
        % Generate the feature table based on the selected table
        waitbar(0.6, progress_bar, 'Creating Feature Table...');
        
        % Function to get the selected feature table from the radio buttons
        function selected_table = get_selected_table()
            selected_radio = get(table_radio, 'SelectedObject');
            selected_table = get(selected_radio, 'String');
        end
        switch selected_table
            case 'Table 3'
                % Generate features for Table 3
                [generate_feature_table, n_cell_tot] = table3(label, nchannel, n_pic, s_HAC_all, s_mask_all);
            case 'Table 4'
                % Generate features for Table 4
                [generate_feature_table, n_cell_tot] = table4(label, nchannel, n_pic, s_HAC_all, s_mask_all);
            case 'Table 5'
                % Generate features for Table 5
                [generate_feature_table, n_cell_tot] = table5(label, nchannel, n_pic, s_HAC_all, s_mask_all);
            case 'Table 6'
                % Generate features for Table 6
                [generate_feature_table, n_cell_tot] = table6(label, nchannel, n_pic, s_HAC_all, s_mask_all);
        end
        
        % Prompt the user to specify where to save the table as an Excel file
        %         [filename, filepath] = uiputfile('*.xlsx','Save Table As');
        %         if filename ~= 0
        %             % Save the table to the specified location
        %             fullpath = fullfile(filepath, filename);
        %             writematrix(generate_feature_table, fullpath);
        %             msgbox(sprintf('Table saved successfully as %s', fullpath));
        %         end
        % Prompt the user to specify where to save the table as an Excel file
        [filename, filepath] = uiputfile('*.xlsx', 'Save Data As');
        if filename ~= 0
            fullpath = fullfile(filepath, filename);
            
            % Save the generated feature table to the specified location
            writematrix(generate_feature_table, fullpath, 'Sheet', 'Feature Table');
            
            % Check if s_HAC_all is available and not empty
            if exist('s_HAC_all', 'var') && ~isempty(s_HAC_all)
                % Extract file names and save them to another sheet
                file_names = {s_HAC_all.name}';
                writecell(file_names, fullpath, 'Sheet', 'File Names');
            else
                msgbox('No hyperspectral data loaded', 'Save Error');
            end
            
            msgbox(sprintf('Data saved successfully as %s', fullpath), 'Save Successful');
        else
            msgbox('Save cancelled', 'Save Cancelled');
        end
        % Update the total cell numbers text on the GUI
        set(cell_count_txt, 'String', sprintf('Total cell numbers: %d', n_cell_tot));
        
        % Close the progress bar window
        waitbar(1, progress_bar, 'Done');
        close(progress_bar);
    end

end

%% GUI functionality
function [feature_table, nc_t] = feature_table_YL(n_feature, nchannel, n_pic, percentage, hs_data, mask_data)
% Generating a feature table based on the hyperspectrum data
%
% Author  : Yandong Lang
% Email   : yandong.lang@unsw.edu.au
% Note that any modifications on the code should be notified to the author

if nargin ~= 6
    error(message('there should be 6 inputs'));
end

flat = @(F) F(:);

nc_t = 0;

if nchannel > 2
    nchannel = nchannel - 1;
end

% Expand the size of feature_table to include two additional columns
feature_table = zeros(1000, n_feature + 2, nchannel);

for i = 1:n_pic
    % Load Hyperspectral Data file
    HS_i = load(fullfile(hs_data(i).folder, hs_data(i).name)).HAC_Image.imageStruct.data;
    
    % Load and process mask file
    mask_image = imread(fullfile(mask_data(i).folder, mask_data(i).name));
    
    % Use morphological closing operation to fill incomplete areas
    se = strel('rectangle', [10, 10]); % Create a rectangular structuring element
    filled_mask = imclose(mask_image, se);
    
    nc = length(bwconncomp(filled_mask).PixelIdxList);
    
    ft_ch = zeros(nc, n_feature + 2, nchannel);
    for j = 1:nchannel
        HS_i_j = HS_i(:,:,j);
        HS_i_j_flat = flat(HS_i_j);
        feature_table_cell = zeros(nc, n_feature+2);
        for k = 1:nc
            data_pi_chj_ck = HS_i_j_flat(bwconncomp(filled_mask).PixelIdxList{k});
            
            [mean_ijk, var_ijk, skew_ijk, kur_ijk, top_mean_ijk, top_var_ijk, top_skew_ijk, top_kur_ijk] ...
                = feature_moment(data_pi_chj_ck, percentage);
            feature_table_cell(k,:) = ...
                [mean_ijk, var_ijk, skew_ijk, kur_ijk, top_mean_ijk, top_var_ijk, top_skew_ijk, top_kur_ijk, i, k];
            
            % Add image identifier and cell index
            ft_ch(k, :, j) = feature_table_cell(k, :);

        end
    end
    
    % Update the overall feature table
    feature_table(nc_t+1:nc_t+nc, :, :) = ft_ch;
    nc_t = nc_t + nc;
end

% Trim the unused rows
feature_table = feature_table(1:nc_t, :, :);
end

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

function [feature_table, n_cell_tot] = table3(label, nchannel, n_pic, s_HAC_all, s_mask_all)
n_feature = 8;
percentage = 0.1;
[feature_table_all, n_cell_tot] = feature_table_YL(n_feature, nchannel, n_pic, percentage, s_HAC_all, s_mask_all);
feature_table = zeros(n_cell_tot,15+2);

feature_table(:, 1:2) = feature_table_all(:, end-1:end, 1);

feature_table(:,3) = feature_table_all(:,5,2)./ feature_table_all(:,5,5); % No.1
feature_table(:,4) = feature_table_all(:,1,7)./ feature_table_all(:,1,8); % No.2
feature_table(:,5) = feature_table_all(:,5,12)./ feature_table_all(:,5,21);  % No.3
feature_table(:,6) = feature_table_all(:,5,21)./ feature_table_all(:,5,22); % No.4
feature_table(:,7) = feature_table_all(:,1,8)./ feature_table_all(:,5,2); % No.5
feature_table(:,8) = feature_table_all(:,5,31)./ feature_table_all(:,5,32); % No.6

percentage = 0.4;
[feature_table_all, n_cell_tot] = feature_table_YL(n_feature, nchannel, n_pic, percentage, s_HAC_all, s_mask_all);
feature_table(:,9) = feature_table_all(:,1,8)./ feature_table_all(:,5,21); % No.7
feature_table(:,10) = feature_table_all(:,1,5)./ feature_table_all(:,5,4); % No.8
feature_table(:,11) = feature_table_all(:,1,2)./ feature_table_all(:,5,29);  % No.9
feature_table(:,12) = feature_table_all(:,7,8); % No.10
feature_table(:,13) = feature_table_all(:,1,31)./ feature_table_all(:,1,28);   % No.11
feature_table(:,14) = feature_table_all(:,1,22)./ feature_table_all(:,5,12);  % No.12
feature_table(:,15) = feature_table_all(:,1,27).* feature_table_all(:,5,5); % No.13
feature_table(:,16) = feature_table_all(:,1,25)./ feature_table_all(:,1,31);   % No.14
% Add the label as the last column in the table
feature_table(:,end) = label;

end


function [feature_table, n_cell_tot] = table4(label, nchannel, n_pic, s_HAC_all, s_mask_all)
n_feature = 8;

% For top 10% of channel features
percentage = 0.1;
[feature_table_all_10, n_cell_tot] = feature_table_YL(n_feature, nchannel, n_pic, percentage, s_HAC_all, s_mask_all);

feature_table_10_percent = zeros(n_cell_tot, 19+2);

feature_table_10_percent(:, 1:2) = feature_table_all_10(:, end-1:end, 1);
feature_table_10_percent(:,3) = feature_table_all_10(:,5,2)./ feature_table_all_10(:,5,5);
feature_table_10_percent(:,4) = feature_table_all_10(:,1,7)./ feature_table_all_10(:,1,8);
feature_table_10_percent(:,5) = feature_table_all_10(:,5,12)./ feature_table_all_10(:,5,21);
feature_table_10_percent(:,6) = feature_table_all_10(:,5,21)./ feature_table_all_10(:,5,22);
feature_table_10_percent(:,7) = feature_table_all_10(:,1,8)./ feature_table_all_10(:,5,2);
feature_table_10_percent(:,8) = feature_table_all_10(:,5,31)./ feature_table_all_10(:,5,32);
feature_table_10_percent(:,9) = feature_table_all_10(:,5,3)./ feature_table_all_10(:,5,15);
feature_table_10_percent(:,10) = feature_table_all_10(:,5,26)./ feature_table_all_10(:,5,27);
feature_table_10_percent(:,11) = feature_table_all_10(:,5,14)./ feature_table_all_10(:,5,22);
feature_table_10_percent(:,12) = feature_table_all_10(:,5,24)./ feature_table_all_10(:,5,28);
feature_table_10_percent(:,13) = feature_table_all_10(:,5,4)./ feature_table_all_10(:,5,18);
feature_table_10_percent(:,14) = feature_table_all_10(:,5,23)./ feature_table_all_10(:,5,30);
feature_table_10_percent(:,15) = feature_table_all_10(:,5,15)./ feature_table_all_10(:,5,34);
feature_table_10_percent(:,16) = feature_table_all_10(:,1,18)./ feature_table_all_10(:,5,3);
feature_table_10_percent(:,17) = feature_table_all_10(:,5,26)./ feature_table_all_10(:,5,23);
feature_table_10_percent(:,18) = feature_table_all_10(:,5,5)./ feature_table_all_10(:,5,23);
feature_table_10_percent(:,19) = feature_table_all_10(:,5,14)./ feature_table_all_10(:,5,23);
feature_table_10_percent(:,20) = feature_table_all_10(:,5,31)./ feature_table_all_10(:,5,18);
feature_table_10_percent(:,21) = feature_table_all_10(:,5,26)./ feature_table_all_10(:,5,21);

% For top 40% of channel features
percentage = 0.4;
[feature_table_all_40, n_cell_tot] = feature_table_YL(n_feature, nchannel, n_pic, percentage, s_HAC_all, s_mask_all);

feature_table_40_percent = zeros(n_cell_tot, 20);
feature_table_40_percent(:,1) = feature_table_all_40(:,1,8)./ feature_table_all_40(:,5,21);
feature_table_40_percent(:,2) = feature_table_all_40(:,1,5)./ feature_table_all_40(:,5,4);
feature_table_40_percent(:,3) = feature_table_all_40(:,1,2)./ feature_table_all_40(:,5,29);
feature_table_40_percent(:,4) = feature_table_all_40(:,7,8);
feature_table_40_percent(:,5) = feature_table_all_40(:,1,31)./ feature_table_all_40(:,1,28);
feature_table_40_percent(:,6) = feature_table_all_40(:,1,22)./ feature_table_all_40(:,5,12);
feature_table_40_percent(:,7) = feature_table_all_40(:,1,27)./ feature_table_all_40(:,5,5);
feature_table_40_percent(:,8) = feature_table_all_40(:,1,23)./ feature_table_all_40(:,5,5);
feature_table_40_percent(:,9) = feature_table_all_40(:,1,7)./ feature_table_all_40(:,5,3);
feature_table_40_percent(:,10) = feature_table_all_40(:,1,18)./ feature_table_all_40(:,5,21);
feature_table_40_percent(:,11) = feature_table_all_40(:,7,4);

feature_table_40_percent(:,12) = feature_table_all_40(:,1,21)./ feature_table_all_40(:,5,3);
feature_table_40_percent(:,13) = feature_table_all_40(:,1,22)./ feature_table_all_40(:,5,15);
feature_table_40_percent(:,14) = feature_table_all_40(:,1,29)./ feature_table_all_40(:,5,2);
feature_table_40_percent(:,15) = feature_table_all_40(:,1,23)./ feature_table_all_40(:,5,14);
feature_table_40_percent(:,16) = feature_table_all_40(:,1,21)./ feature_table_all_40(:,5,25);
feature_table_40_percent(:,17) = feature_table_all_40(:,1,24)./ feature_table_all_40(:,5,7);
feature_table_40_percent(:,18) = feature_table_all_40(:,1,30)./ feature_table_all_40(:,5,4);
feature_table_40_percent(:,19) = feature_table_all_40(:,1,22)./ feature_table_all_40(:,5,30);
feature_table_40_percent(:,20) = label;
% Concatenating the two tables for final output
feature_table = [feature_table_10_percent, feature_table_40_percent];
end


function [feature_table, n_cell_tot] = table5(label, nchannel, n_pic, s_HAC_all, s_mask_all)
n_feature = 8;
percentage = 0.4;
[feature_table_all, n_cell_tot] = feature_table_YL(n_feature, nchannel, n_pic, percentage, s_HAC_all, s_mask_all);
feature_table = zeros(n_cell_tot,9);
%% create the specific features based on the kidney cells paper (Table 5)
feature_table(:,1) = feature_table_all(:,1,8)./ feature_table_all(:,5,21); % No.7
feature_table(:,2) = feature_table_all(:,1,5)./ feature_table_all(:,5,4); % No.8
feature_table(:,3) = feature_table_all(:,1,2)./ feature_table_all(:,5,29);  % No.9
feature_table(:,4) = feature_table_all(:,7,8); % No.10
feature_table(:,5) = feature_table_all(:,1,31)./ feature_table_all(:,1,28);   % No.11
feature_table(:,6) = feature_table_all(:,1,22)./ feature_table_all(:,5,12);  % No.12
feature_table(:,7) = feature_table_all(:,1,27).* feature_table_all(:,5,5); % No.13
feature_table(:,8) = feature_table_all(:,1,25)./ feature_table_all(:,1,31);   % No.14

% Add the label as the last column in the table
feature_table(:,9) = label;
end

function [feature_table, n_cell_tot] = table6(label, nchannel, n_pic, s_HAC_all, s_mask_all)
n_feature = 8;
percentage = 0.1;
[feature_table_all, n_cell_tot] = feature_table_YL(n_feature, nchannel, n_pic, percentage, s_HAC_all, s_mask_all);
feature_table = zeros(n_cell_tot,9);

feature_table(:,1) = feature_table_all(:,1,7)./ feature_table_all(:,1,8); % No.2
feature_table(:,2) = feature_table_all(:,5,12)./ feature_table_all(:,5,21);  % No.3
feature_table(:,3) = feature_table_all(:,5,21)./ feature_table_all(:,5,22); % No.4
feature_table(:,4) = feature_table_all(:,1,8)./ feature_table_all(:,5,2); % No.5
feature_table(:,5) = feature_table_all(:,5,31)./ feature_table_all(:,5,32); % No.6

percentage = 0.4;
[feature_table_all, n_cell_tot] = feature_table_YL(n_feature, nchannel, n_pic, percentage, s_HAC_all, s_mask_all);
feature_table(:,6) = feature_table_all(:,1,8)./ feature_table_all(:,5,21); % No.7
feature_table(:,7) = feature_table_all(:,1,5)./ feature_table_all(:,5,4); % No.8
feature_table(:,8) = feature_table_all(:,1,2)./ feature_table_all(:,5,29);  % No.9

% Add the label as the last column in the table
feature_table(:,9) = label;
end



function [B,ndx,dbg] = natsortfiles(A,rgx,varargin)
% Natural-order / alphanumeric sort of filenames or foldernames.
%
% (c) 2014-2022 Stephen Cobeldick
%
% Sorts text by character code and by number value. File/folder names, file
% extensions, and path directories (if supplied) are sorted separately to
% ensure that shorter names sort before longer names. For names without
% file extensions (i.e. foldernames, or filenames without extensions) use
% the 'noext' option. Use the 'xpath' option to ignore any filepath. Use
% the 'rmdot' option to remove the folder names "." and ".." from the array.
%
%%% Example:
% P = 'C:\SomeDir\SubDir';
% S = dir(fullfile(P,'*.txt'));
% S = natsortfiles(S);
% for k = 1:numel(S)
%     F = fullfile(P,S(k).name)
% end
%
%%% Syntax:
%  B = natsortfiles(A)
%  B = natsortfiles(A,rgx)
%  B = natsortfiles(A,rgx,<options>)
% [B,ndx,dbg] = natsortfiles(A,...)
%
% To sort the elements of a string/cell array use NATSORT (File Exchange 34464)
% To sort the rows of a string/cell/table use NATSORTROWS (File Exchange 47433)
%
%% File Dependency %%
%
% NATSORTFILES requires the function NATSORT (File Exchange 34464). Extra
% optional arguments are passed directly to NATSORT. See NATSORT for case-
% sensitivity, sort direction, number format matching, and other options.
%
%% Explanation %%
%
% Using SORT on filenames will sort any of char(0:45), including the
% printing characters ' !"#$%&''()*+,-', before the file extension
% separator character '.'. Therefore NATSORTFILES splits the file-name
% from the file-extension and sorts them separately. This ensures that
% shorter names come before longer names (just like a dictionary):
%
% >> F = {'test_new.m'; 'test-old.m'; 'test.m'};
% >> sort(F) % Note '-' sorts before '.':
% ans =
%     'test-old.m'
%     'test.m'
%     'test_new.m'
% >> natsortfiles(F) % Shorter names before longer:
% ans =
%     'test.m'
%     'test-old.m'
%     'test_new.m'
%
% Similarly the path separator character within filepaths can cause longer
% directory names to sort before shorter ones, as char(0:46)<'/' and
% char(0:91)<'\'. This example on a PC demonstrates why this matters:
%
% >> D = {'A1\B', 'A+/B', 'A/B1', 'A=/B', 'A\B0'};
% >> sort(D)
% ans =   'A+/B'  'A/B1'  'A1\B'  'A=/B'  'A\B0'
% >> natsortfiles(D)
% ans =   'A\B0'  'A/B1'  'A1\B'  'A+/B'  'A=/B'
%
% NATSORTFILES splits filepaths at each path separator character and sorts
% every level of the directory hierarchy separately, ensuring that shorter
% directory names sort before longer, regardless of the characters in the names.
% On a PC separators are '/' and '\' characters, on Mac and Linux '/' only.
%
%% Examples %%
%
% >> A = {'a2.txt', 'a10.txt', 'a1.txt'}
% >> sort(A)
% ans = 'a1.txt'  'a10.txt'  'a2.txt'
% >> natsortfiles(A)
% ans = 'a1.txt'  'a2.txt'  'a10.txt'
%
% >> B = {'test2.m'; 'test10-old.m'; 'test.m'; 'test10.m'; 'test1.m'};
% >> sort(B) % Wrong number order:
% ans =
%    'test.m'
%    'test1.m'
%    'test10-old.m'
%    'test10.m'
%    'test2.m'
% >> natsortfiles(B) % Shorter names before longer:
% ans =
%    'test.m'
%    'test1.m'
%    'test2.m'
%    'test10.m'
%    'test10-old.m'
%
%%% Directory Names:
% >> C = {'A2-old\test.m';'A10\test.m';'A2\test.m';'A1\test.m';'A1-archive.zip'};
% >> sort(C) % Wrong number order, and '-' sorts before '\':
% ans =
%    'A1-archive.zip'
%    'A10\test.m'
%    'A1\test.m'
%    'A2-old\test.m'
%    'A2\test.m'
% >> natsortfiles(C) % Shorter names before longer:
% ans =
%    'A1\test.m'
%    'A1-archive.zip'
%    'A2\test.m'
%    'A2-old\test.m'
%    'A10\test.m'
%
%% Input and Output Arguments %%
%
%%% Inputs (**=default):
% A   = Array of filenames or foldernames to be sorted. Can be the struct
%       returned by DIR, a string array, or a cell array of char row vectors.
% rgx = Optional regular expression to match number substrings.
%     = [] uses the default regular expression (see NATSORT).
% <options> can be supplied in any order:
%     = 'rmdot' removes the names "." and ".." from the output array.
%     = 'noext' for foldernames, or filenames without extensions.
%     = 'xpath' sorts by name only, excluding any preceding path.
% Any remaining <options> are passed directly to NATSORT.
%
%%% Outputs:
% B   = Array <A> sorted into alphanumeric order.
% ndx = NumericMatrix, indices such that B = A(ndx). The same size as <B>.
% dbg = CellArray, each cell contains the debug cell array of one level
%       of the path heirarchy, i.e. directory names, or filenames, or file
%       extensions. Helps debug the regular expression (see NATSORT).
%
% See also SORT NATSORT NATSORTROWS ARBSORT IREGEXP REGEXP
% DIR FILEPARTS FULLFILE NEXTNAME STRING CELLSTR SSCANF

%% Input Wrangling %%
%
fnh = @(c)cellfun('isclass',c,'char') & cellfun('size',c,1)<2 & cellfun('ndims',c)<3;
%
if isstruct(A)
    assert(isfield(A,'name'),...
        'SC:natsortfiles:A:StructMissingNameField',...
        'If first input <A> is a struct then it must have field <name>.')
    nmx = {A.name};
    assert(all(fnh(nmx)),...
        'SC:natsortfiles:A:NameFieldInvalidType',...
        'First input <A> field <name> must contain only character row vectors.')
    [fpt,fnm,fxt] = cellfun(@fileparts, nmx, 'UniformOutput',false);
    if isfield(A,'folder')
        fpt(:) = {A.folder};
        assert(all(fnh(fpt)),...
            'SC:natsortfiles:A:FolderFieldInvalidType',...
            'First input <A> field <folder> must contain only character row vectors.')
    end
elseif iscell(A)
    assert(all(fnh(A(:))),...
        'SC:natsortfiles:A:CellContentInvalidType',...
        'First input <A> cell array must contain only character row vectors.')
    [fpt,fnm,fxt] = cellfun(@fileparts, A(:), 'UniformOutput',false);
    nmx = strcat(fnm,fxt);
elseif ischar(A)
    [fpt,fnm,fxt] = cellfun(@fileparts, cellstr(A), 'UniformOutput',false);
    nmx = strcat(fnm,fxt);
else
    assert(isa(A,'string'),...
        'SC:natsortfiles:A:InvalidType',...
        'First input <A> must be a structure, a cell array, or a string array.');
    [fpt,fnm,fxt] = cellfun(@fileparts, cellstr(A(:)), 'UniformOutput',false);
    nmx = strcat(fnm,fxt);
end
%
varargin = cellfun(@ns1s2c, varargin, 'UniformOutput',false);
ixv = fnh(varargin); % char
txt = varargin(ixv); % char
xtx = varargin(~ixv); % not
%
trd = strcmpi(txt,'rmdot');
assert(nnz(trd)<2,...
    'SC:natsortfiles:rmdot:Overspecified',...
    'The "." and ".." folder handling "rmdot" is overspecified.')
%
tnx = strcmpi(txt,'noext');
assert(nnz(tnx)<2,...
    'SC:natsortfiles:noext:Overspecified',...
    'The file-extension handling "noext" is overspecified.')
%
txp = strcmpi(txt,'xpath');
assert(nnz(txp)<2,...
    'SC:natsortfiles:xpath:Overspecified',...
    'The file-path handling "xpath" is overspecified.')
%
chk = '(no|rm|x)(dot|ext|path)';
%
if nargin>1
    nsfChkRgx(rgx,chk)
    txt = [{rgx},txt(~(trd|tnx|txp))];
end
%
%% Path and Extension %%
%
% Path separator regular expression:
if ispc()
    psr = '[^/\\]+';
else % Mac & Linux
    psr = '[^/]+';
end
%
if any(trd) % Remove "." and ".." folder names
    ddx = strcmp(nmx,'.') | strcmp(nmx,'..');
    fxt(ddx) = [];
    fnm(ddx) = [];
    fpt(ddx) = [];
    nmx(ddx) = [];
end
%
if any(tnx) % No file-extension
    fnm = nmx;
    fxt = [];
end
%
if any(txp) % No file-path
    mat = reshape(fnm,1,[]);
else
    % Split path into {dir,subdir,subsubdir,...}:
    spl = regexp(fpt(:),psr,'match');
    nmn = 1+cellfun('length',spl(:));
    mxn = max(nmn);
    vec = 1:mxn;
    mat = cell(mxn,numel(nmn));
    mat(:) = {''};
    %mat(mxn,:) = fnm(:); % old behavior
    mat(logical(bsxfun(@eq,vec,nmn).')) =  fnm(:);  % TRANSPOSE bug loses type (R2013b)
    mat(logical(bsxfun(@lt,vec,nmn).')) = [spl{:}]; % TRANSPOSE bug loses type (R2013b)
end
%
if numel(fxt) % File-extension
    mat(end+1,:) = fxt(:);
end
%
%% Sort File Extensions, Names, and Paths %%
%
nmr = size(mat,1)*all(size(mat));
dbg = cell(1,nmr);
ndx = 1:numel(fnm);
%
for k = nmr:-1:1
    if nargout<3 % faster:
        [~,idx] = natsort(mat(k,ndx),txt{:},xtx{:});
    else % for debugging:
        [~,idx,gbd] = natsort(mat(k,ndx),txt{:},xtx{:});
        [~,idb] = sort(ndx);
        dbg{k} = gbd(idb,:);
    end
    ndx = ndx(idx);
end
%
% Return the sorted input array and corresponding indices:
%
if any(trd)
    tmp = find(~ddx);
    ndx = tmp(ndx);
end
%
ndx = ndx(:);
%
if ischar(A)
    B = A(ndx,:);
elseif any(trd)
    xsz = size(A);
    nsd = xsz~=1;
    if nnz(nsd)==1 % vector
        xsz(nsd) = numel(ndx);
        ndx = reshape(ndx,xsz);
    end
    B = A(ndx);
else
    ndx = reshape(ndx,size(A));
    B = A(ndx);
end
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%natsortfiles
function nsfChkRgx(rgx,chk)
chk = sprintf('^(%s)$',chk);
assert(~ischar(rgx)||isempty(regexpi(rgx,chk,'once')),...
    'SC:natsortfiles:rgx:OptionMixUp',...
    ['Second input <rgx> must be a regular expression that matches numbers.',...
    '\nThe provided expression "%s" looks like an optional argument (inputs 3+).'],rgx)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%nsfChkRgx
function arr = ns1s2c(arr)
% If scalar string then extract the character vector, otherwise data is unchanged.
if isa(arr,'string') && isscalar(arr)
    arr = arr{1};
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ns1s2c

