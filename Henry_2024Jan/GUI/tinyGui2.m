function gui_example()

    % create the main figure window
    fig = figure('Name', 'GUI Example', 'MenuBar', 'none', 'ToolBar', 'none',...
        'Position', [500, 300, 400, 200]);

    % create two buttons for loading files
    uicontrol('Parent', fig, 'Style', 'pushbutton', 'String', 'Load HAC Files',...
        'Position', [30 140 150 30], 'Callback', @load_hac_files);
    uicontrol('Parent', fig, 'Style', 'pushbutton', 'String', 'Load Mask Files',...
        'Position', [220 140 150 30], 'Callback', @load_mask_files);

    % initialize variables for holding the loaded files
    s_HAC_all = {};
    s_mask_all = {};

    % define the functions for loading the files
    function load_hac_files(~,~)
        % prompt the user to select a folder
        path_hs = uigetdir('','Select the folder containing HAC files');
        if ~path_hs, return; end % user canceled or closed dialog

        % load all the .mat files in the folder and sort them
        HAC_all = natsortfiles(dir(fullfile(path_hs, '*.mat'))); 
        s_HAC_all = cell(length(HAC_all), 1);
        for i = 1:length(HAC_all)
            s_HAC_all{i} = load(fullfile(path_hs, HAC_all(i).name));
        end
    end

    function load_mask_files(~,~)
        % prompt the user to select a folder
        path_mask = uigetdir('','Select the folder containing mask files');
        if ~path_mask, return; end % user canceled or closed dialog

        % load all the .mat files in the folder and sort them
        mask_all = natsortfiles(dir(fullfile(path_mask, '*.mat')));
        s_mask_all = cell(length(mask_all), 1);
        for i = 1:length(mask_all)
            s_mask_all{i} = load(fullfile(path_mask, mask_all(i).name));
        end
    end

end
