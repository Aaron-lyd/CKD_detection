function hyperspec_gui()

    % Create a figure with two browse buttons for hyperspectral image data and mask data
    fig = figure('Name','Data Loader','MenuBar','none','ToolBar','none','Position',[300 300 400 200]);

    hs_browse_btn = uicontrol('Style','pushbutton','String','Browse Hyperspectral Data','Position',[10 140 180 30],'Callback',@hs_browse_callback);
    hs_folder_txt = uicontrol('Style','text','Position',[200 145 180 20],'HorizontalAlignment','left');

    m_browse_btn = uicontrol('Style','pushbutton','String','Browse Mask Data','Position',[10 100 180 30],'Callback',@m_browse_callback);
    m_folder_txt = uicontrol('Style','text','Position',[200 105 180 20],'HorizontalAlignment','left');

    % Create a button to load the data
    load_btn = uicontrol('Style','pushbutton','String','Load Data','Position',[150 50 100 30],'Callback',@load_callback,'Enable','off');

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
    end

end
