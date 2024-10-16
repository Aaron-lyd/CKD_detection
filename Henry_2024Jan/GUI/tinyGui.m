function myGui()
    % Create the GUI figure
    fig = uifigure('Name', 'Document Counter', 'Position', [100 100 400 250]);

    % Create a button to select the document path
    pathButton = uibutton(fig, 'push', 'Text', 'Select Path', 'Position', [50 175 100 25], ...
        'ButtonPushedFcn', @(btn,event)selectPath());

    % Create a label to display the selected path
    pathLabel = uilabel(fig, 'Text', 'No path selected', 'Position', [50 150 300 20]);

    % Create a button to count the number of documents
    countButton = uibutton(fig, 'push', 'Text', 'Count Documents', 'Position', [50 100 100 25], ...
        'ButtonPushedFcn', @(btn,event)countDocuments());

    % Create a table to display the results
    resultTable = uitable(fig, 'Position', [175 50 200 150]);

    % Create a button to save the results as an excel file
    saveButton = uibutton(fig, 'push', 'Text', 'Save Results', 'Position', [50 50 100 25], ...
        'ButtonPushedFcn', @(btn,event)saveResults());

    % Function to select the document path
    function selectPath()
        path = uigetdir();
        if path ~= 0
            pathLabel.Text = path;
        end
    end

    % Function to count the number of documents
    function countDocuments()
        path = pathLabel.Text;
        files = dir(fullfile(path, '*.mat'));
        nDocuments = length(files);
        % Perform calculations on nDocuments
        square = nDocuments^2;
        squareRoot = sqrt(nDocuments);
        times4 = nDocuments*4;
        divide10 = nDocuments/10;
        % Display results in table
        resultTable.Data = {'Square', square; 'Square Root', squareRoot; ...
            'Times 4', times4; 'Divide 10', divide10};
    end

    % Function to save the results as an excel file
    function saveResults()
        [fileName, path] = uiputfile('*.xlsx', 'Save Results');
        if fileName ~= 0
            data = resultTable.Data;
            xlswrite(fullfile(path, fileName), data);
        end
    end
end
