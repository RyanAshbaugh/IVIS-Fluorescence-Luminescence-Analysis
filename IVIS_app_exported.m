classdef IVIS_app_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        GridLayout                     matlab.ui.container.GridLayout
        LeftPanel                      matlab.ui.container.Panel
        MainExperimentFolderEditFieldLabel  matlab.ui.control.Label
        MainExperimentFolderEditField  matlab.ui.control.EditField
        BrowseButton                   matlab.ui.control.Button
        AnalyzeButton                  matlab.ui.control.Button
        RightPanel                     matlab.ui.container.Panel
        Image                          matlab.ui.control.Image
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    
    properties (Access = private)
        experiment_directory    char % Description
        sub_directories         struct
        approximate_well_radii_range = [ 10 20 ] % pixels of well circle radii
        image_scale = 4         % how much to enlarge the image for displaying figure
        sensitivity = 0.86      % for detecting circles, higher is more circles
        well_counts             double % num_well x num_reads, total light in well
        image_handle            matlab.graphics.primitive.Image
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: BrowseButton
        function BrowseButtonPushed(app, event)
            app.experiment_directory = uigetdir('Select Main Experiment Folder');
            app.MainExperimentFolderEditField.Value = app.experiment_directory;
        end

        % Button pushed function: AnalyzeButton
        function AnalyzeButtonPushed(app, event)
            
            [ app.well_counts, app.image_handle ] = performAnalysis( ...
                app.experiment_directory, app.approximate_well_radii_range, app.image_scale, ...
                app.sensitivity );
            
            saveResults( app.well_counts, app.experiment_directory, app.image_handle );
            
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {302, 302};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {389, '1x'};
                app.RightPanel.Layout.Row = 1;
                app.RightPanel.Layout.Column = 2;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.AutoResizeChildren = 'off';
            app.UIFigure.Position = [100 100 693 302];
            app.UIFigure.Name = 'UI Figure';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {389, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create MainExperimentFolderEditFieldLabel
            app.MainExperimentFolderEditFieldLabel = uilabel(app.LeftPanel);
            app.MainExperimentFolderEditFieldLabel.HorizontalAlignment = 'right';
            app.MainExperimentFolderEditFieldLabel.Position = [74 207 133 22];
            app.MainExperimentFolderEditFieldLabel.Text = 'Main Experiment Folder';

            % Create MainExperimentFolderEditField
            app.MainExperimentFolderEditField = uieditfield(app.LeftPanel, 'text');
            app.MainExperimentFolderEditField.Position = [9 186 299 22];

            % Create BrowseButton
            app.BrowseButton = uibutton(app.LeftPanel, 'push');
            app.BrowseButton.ButtonPushedFcn = createCallbackFcn(app, @BrowseButtonPushed, true);
            app.BrowseButton.Position = [305 186 55 23];
            app.BrowseButton.Text = 'Browse';

            % Create AnalyzeButton
            app.AnalyzeButton = uibutton(app.LeftPanel, 'push');
            app.AnalyzeButton.ButtonPushedFcn = createCallbackFcn(app, @AnalyzeButtonPushed, true);
            app.AnalyzeButton.Position = [90 100 100 22];
            app.AnalyzeButton.Text = 'Analyze';

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create Image
            app.Image = uiimage(app.RightPanel);
            app.Image.Position = [102 109 100 100];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = IVIS_app_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end