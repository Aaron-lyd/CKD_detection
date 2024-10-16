function hyperspec_gui()

    fig = figure('Name','Data Loader','MenuBar','none','ToolBar','none','Position',[300 300 500 300]);

    file_panel = uipanel('Parent', fig, 'Title', 'Data Files', 'Position', [0.05 0.5 0.9 0.4]);

    hs_browse_btn = uicontrol('Parent', file_panel, 'Style','pushbutton','String','Browse Hyperspectral Data','Position',[10 80 120 25],'Callback',@hs_browse_callback);
    hs_folder_txt = uicontrol('Parent', file_panel, 'Style','text','Position',[140 80 320 25],'HorizontalAlignment','left');

    m_browse_btn = uicontrol('Parent', file_panel, 'Style','pushbutton','String','Browse Mask Data','Position',[10 30 120 25],'Callback',@m_browse_callback);
    m_folder_txt = uicontrol('Parent', file_panel, 'Style','text','Position',[140 30 320 25],'HorizontalAlignment','left');

    input_panel = uipanel('Parent', fig, 'Title', 'Input Fields', 'Position', [0.05 0.05 0.9 0.4]);

    n_feature_inst = uicontrol('Parent', input_panel, 'Style','text','Position',[10 80 120 25],'HorizontalAlignment','left','String','Enter n_feature:');
    n_feature_txt = uicontrol('Parent', input_panel, 'Style','edit','Position',[140 80 60 25],'HorizontalAlignment','left','String','');

    perc_inst = uicontrol('Parent', input_panel, 'Style','text','Position',[10 30 120 25],'HorizontalAlignment','left','String','Enter percentage:');
    perc_txt = uicontrol('Parent', input_panel, 'Style','edit','Position',[140 30 60 25],'HorizontalAlignment','left','String','');

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
        
        % Load and sort the hyperspectral image data
        HAC_all = dir(fullfile(hs_folder_path,'*.mat'));
        s_HAC_all = natsortfiles(HAC_all);
        n_pic = length(HAC_all);
        [~,~,nchannel] = size(load(HAC_all(1).name).HAC_Image.imageStruct.data);
        
        % Load and sort the mask data
        mask_all = dir(fullfile(m_folder_path,'*.png'));
        s_mask_all = natsortfiles(mask_all);
        
        % Display a message box indicating successful loading of data
        msgbox('Data loaded successfully');

        % Create a feature table

        [feature_table_all, n_cell_tot] = feature_table_YL(n_feature, nchannel, n_pic, percentage, s_HAC_all, s_mask_all);

        % 4. Creating  the specific features based on the kidney cells paper (Table 3)
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
    end

end

