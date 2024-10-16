function feature_generation_T3_p()

fig = figure('Name','Data Loader','MenuBar','none','ToolBar','none','Position',[400 400 600 350]);

file_panel = uipanel('Parent', fig, 'Title', 'Data Files', 'Position', [0.05 0.6 0.9 0.35]);

hs_browse_btn = uicontrol('Parent', file_panel, 'Style','pushbutton','String','Browse Hyperspectral Data','Position',[10 80 120 25],'Callback',@hs_browse_callback);
hs_folder_txt = uicontrol('Parent', file_panel, 'Style','text','Position',[140 80 320 25],'HorizontalAlignment','left');

m_browse_btn = uicontrol('Parent', file_panel, 'Style','pushbutton','String','Browse Mask Data','Position',[10 30 120 25],'Callback',@m_browse_callback);
m_folder_txt = uicontrol('Parent', file_panel, 'Style','text','Position',[140 30 320 25],'HorizontalAlignment','left');

input_panel = uipanel('Parent', fig, 'Title', 'Input Fields', 'Position', [0.05 0.25 0.9 0.35]);

n_feature_inst = uicontrol('Parent', input_panel, 'Style','text','Position',[10 80 120 25],'HorizontalAlignment','left','String','Enter n_feature:');
n_feature_txt = uicontrol('Parent', input_panel, 'Style','edit','Position',[140 80 60 25],'HorizontalAlignment','left','String','');

perc_inst = uicontrol('Parent', input_panel, 'Style','text','Position',[10 30 120 25],'HorizontalAlignment','left','String','Enter percentage:');
perc_txt = uicontrol('Parent', input_panel, 'Style','edit','Position',[140 30 60 25],'HorizontalAlignment','left','String','');

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
        
        % Get n_feature and percentage
        n_feature_str = get(n_feature_txt,'String');
        if ~isempty(n_feature_str)
            n_feature = str2double(n_feature_str);
        else
            n_feature = NaN;
        end
        perc_str = get(perc_txt,'String');
        if ~isempty(perc_str)
            percentage = str2double(perc_str);
        else
            percentage = NaN;
        end
        
        % Check if the input values are valid
        if isnan(n_feature) || isnan(percentage)
            errordlg('Please enter valid values for n_feature and percentage.');
            close(progress_bar);
            return;
        end
        
        % Load and sort the hyperspectral image data
        waitbar(0.2, progress_bar, 'Loading Hyperspectral Data...');
        HAC_all = dir(fullfile(hs_folder_path,'*.mat'));
        if isempty(HAC_all)
            errordlg('No hyperspectral image data found in the specified folder.');
            close(progress_bar);
            return;
        end
        s_HAC_all = custom_natsortfiles(HAC_all);
        n_pic = length(HAC_all);
        [~,~,nchannel] = size(load(HAC_all(1).name).HAC_Image.imageStruct.data);
        
        % Load and sort the mask data
        waitbar(0.4, progress_bar, 'Loading Mask Data...');
        mask_all = dir(fullfile(m_folder_path,'*.png'));
        if isempty(mask_all)
            errordlg('No mask data found in the specified folder.');
            close(progress_bar);
            return;
        end
        s_mask_all = custom_natsortfiles(mask_all);
        
        % Create a feature table
        waitbar(0.6, progress_bar, 'Creating Feature Table...');
        [feature_table_all, n_cell_tot] = feature_table_YL(n_feature, nchannel, n_pic, percentage, s_HAC_all, s_mask_all);
        
        % 4. Creating the specific features based on the kidney cells paper (Table 3)
        feature_kid_T3 = zeros(n_cell_tot,6);
        feature_kid_T3(:,1) = feature_table_all(:,5,18)./ feature_table_all(:,5,17); % No.1
        feature_kid_T3(:,2) = feature_table_all(:,1,19)./ feature_table_all(:,1,17); % No.2
        feature_kid_T3(:,3) = feature_table_all(:,5,9)./ feature_table_all(:,5,28);  % No.3
        feature_kid_T3(:,4) = feature_table_all(:,5,19)./ feature_table_all(:,5,17); % No.4
        feature_kid_T3(:,5) = feature_table_all(:,1,1)./ feature_table_all(:,5,2);   % No.5
        feature_kid_T3(:,6) = feature_table_all(:,5,27)./ feature_table_all(:,5,1);  % No.6
        
        % Prompt the user to specify where to save the table as an Excel file
        [filename, filepath] = uiputfile('*.xlsx','Save Table As');
        if filename ~= 0
            % Save the table to the specified location
            fullpath = fullfile(filepath, filename);
            writematrix(feature_kid_T3, fullpath);
            msgbox(sprintf('Table saved successfully as %s', fullpath));
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

function sorted_files = custom_natsortfiles(files)
    % A custom function to replace natsortfiles for file sorting.
    % It takes a structure array of file names as input and returns a sorted
    % structure array of file names.

    file_names = {files.name};
    [~, sort_index] = sort_nat(file_names);
    sorted_files = files(sort_index);
end

function [X, index] = sort_nat(c)
    % Sort a cell array of strings, c, into natural order. Also returns the
    % index of the sorted cell array.
    [~, index] = sort(cellfun(@str2double, regexprep(c, '\D', '')));
    X = c(index);
end

