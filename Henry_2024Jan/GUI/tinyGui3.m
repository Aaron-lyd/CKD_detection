function gui_example()

% Create the GUI figure and set its properties
fig = uifigure('Name', 'Example GUI', 'Position', [100 100 600 400]);

% Create the UI components
path_btn1 = uibutton(fig, 'push', 'Text', 'Browse HAC Folder', 'Position', [50 350 150 25], 'ButtonPushedFcn', @load_hac_folder);
path_btn2 = uibutton(fig, 'push', 'Text', 'Browse Mask Folder', 'Position', [250 350 150 25], 'ButtonPushedFcn', @load_mask_folder);
nfeature_edit = uieditfield(fig, 'text', 'Enter number of features', 'Position', [50 300 150 25]);
percentage_edit = uieditfield(fig, 'text', 'Enter percentage', 'Position', [250 300 150 25]);
result_text = uilabel(fig, 'Text', '', 'Position', [50 250 350 25]);
generate_btn = uibutton(fig, 'push', 'Text', 'Generate Results', 'Position', [50 200 150 25], 'ButtonPushedFcn', @generate_results);
save_btn = uibutton(fig, 'push', 'Text', 'Save Results', 'Position', [250 200 150 25], 'ButtonPushedFcn', @save_results);

% Initialize variables
s_HAC_all = [];
s_mask_all = [];
n_pic = 0;
nchannel = 0;
n_feature = 0;
percentage = 0;
feature_table_all = [];
n_cell_tot = 0;

% Function to load HAC folder
    function load_hac_folder(~, ~)
        % Open a file dialog box to select the HAC folder
        path = uigetdir();
        if path ~= 0
            % Load all files in the folder and sort them using natsortfiles
            s_HAC_all = natsortfiles(dir(fullfile(path, '*.mat')));
            % Check if the files were successfully loaded
            if ~isempty(s_HAC_all)
                result_text.Text = 'HAC folder loaded successfully';
                % Get the number of pictures
                n_pic = length(s_HAC_all);
                % Get the number of channels
                [~, ~, nchannel] = size(load(s_HAC_all(1).name).HAC_Image.imageStruct.data);
            else
                result_text.Text = 'Failed to load HAC folder';
            end
        end
    end

% Function to load mask folder
    function load_mask_folder(~, ~)
        % Open a file dialog box to select the mask folder
        path = uigetdir();
        if path ~= 0
            % Load all files in the folder and sort them using natsortfiles
            s_mask_all = natsortfiles(dir(fullfile(path, '*.mat')));
            % Check if the files were successfully loaded
            if ~isempty(s_mask_all)
                result_text.Text = 'Mask folder loaded successfully';
            else
                result_text.Text = 'Failed to load mask folder';
            end
        end
    end

% Function to generate results
    function generate_results(~, ~)
        % Get the values of n_feature and percentage from the edit fields
        n_feature_str = nfeature_edit.Value;
        percentage_str = percentage_edit.Value;
        % Check if the inputs are valid
        if isempty(n_feature_str) || isempty(percentage_str)
            result_text.Text = 'Please enter valid inputs';
            return;
        end
        n_feature = str2double(n_feature_str);
        percentage = str2double(percentage_str);
        if isnan(n_feature) || isnan(percentage) || n_feature <= 0 || percentage <= 0 || percentage > 100
            result_text.Text = 'Please enter valid inputs';
            return;
        end
        % Generate the results using the feature_table_YL function
        [feature_table_all, n_cell_tot] = feature_table_YL(n_feature, nchannel, n_pic, percentage, s_HAC_all, s_mask_all);
        % Update the result text
        result_text.Text = 'Results generated successfully';
        % Update the n_cell_tot text
        n_cell_tot_text = sprintf('Total number of cells: %d', n_cell_tot);
        n_cell_tot_text = strrep(n_cell_tot_text, ',', '');
        n_cell_tot_text = strrep(n_cell_tot_text, '.', '');
        n_cell_tot_text = strrep(n_cell_tot_text, ' ', '');
        n_cell_tot_text = strrep(n_cell_tot_text, ':', ': ');
        set(result_text, 'Text', n_cell_tot_text);
    end

% Function to save results
    function save_results(~, ~)
        % Open a file dialog box to select the output file path
        [filename, path] = uiputfile('*.xlsx', 'Save Results As');
        if filename ~= 0
            % Create a table from the feature_table_all
            result_table = struct2table(feature_table_all);
            % Save the table as an excel file
            writetable(result_table, fullfile(path, filename));
        end
    end

end

