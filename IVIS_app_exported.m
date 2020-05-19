classdef IVIS_app_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        GridLayout                     matlab.ui.container.GridLayout
        LeftPanel                      matlab.ui.container.Panel
        IvisExperimentFolderEditFieldLabel  matlab.ui.control.Label
        IvisExperimentFolderEditField  matlab.ui.control.EditField
        BrowseButton                   matlab.ui.control.Button
        PlaceROIsButton                matlab.ui.control.Button
        ROIDetectionLabel              matlab.ui.control.Label
        DetectionMethodButtonGroup     matlab.ui.container.ButtonGroup
        ManualButton                   matlab.ui.control.RadioButton
        AutomaticButton                matlab.ui.control.RadioButton
        UITable                        matlab.ui.control.Table
        PhotonCountAnalysisLabel       matlab.ui.control.Label
        AnalyzeWellsButton             matlab.ui.control.Button
        SaveWellCountDataButton        matlab.ui.control.Button
        AddgroupButton                 matlab.ui.control.Button
        CleargroupsButton              matlab.ui.control.Button
        WellcountsvstimeplotButtonGroup  matlab.ui.container.ButtonGroup
        WellsbygroupButton             matlab.ui.control.RadioButton
        AverageofeachgroupButton       matlab.ui.control.RadioButton
        ROITypeDropDownLabel           matlab.ui.control.Label
        ROITypeDropDown                matlab.ui.control.DropDown
        DeletegroupButton              matlab.ui.control.Button
        RightPanel                     matlab.ui.container.Panel
        TabGroup                       matlab.ui.container.TabGroup
        PlateImageTab                  matlab.ui.container.Tab
        UIAxes2                        matlab.ui.control.UIAxes
        WellImageTab                   matlab.ui.container.Tab
        UIAxes                         matlab.ui.control.UIAxes
        GroupImageTab                  matlab.ui.container.Tab
        UIAxes3                        matlab.ui.control.UIAxes
        CountsvsTimeTab                matlab.ui.container.Tab
        UIAxes4                        matlab.ui.control.UIAxes
        StatusWindowTextAreaLabel      matlab.ui.control.Label
        StatusWindowTextArea           matlab.ui.control.TextArea
    end

    % Properties that correspond to apps with auto-reflow
    properties (Access = private)
        onePanelWidth = 576;
    end

    
    properties (Access = private)
        experiment_directory    char % Description
        sub_directories         struct
        approximate_well_radii_range = [ 10 20 ] % pixels of well circle radii
        default_radii = 7
        image_scale = 5         % how much to enlarge the image for displaying figure
        num_rows = 8            % how many rows of wells
        num_cols = 12           % how many columns of wells
        sensitivity = 0.86      % for detecting circles, higher is more circles
        well_counts             double % num_well x num_reads, total light in well
        normalized_well_counts  double % photon counts normalized to a given image as t0
        image_handle            matlab.graphics.primitive.Image
        num_readings            int32 % number of images taken in a given experiment
        photo_name_struct       struct % stores the names of the photos
        reporter_name_struct    struct % stores the names of the reporter photos
        photo_cell              cell % cell to store the photos once loaded
        reporter_cell           cell % cell to store the reporter photos
        photo_height            int32 % height of the photos
        photo_width             int32 % width of the photos
        display_photo = []      % photo to be displayed
        display_photo_rgb = []
        all_well_radii = []     % store the radii of all of the wells
        all_well_centers = []   % matrix to store the x, y positions of the well centers
        groups                  cell
        group_handle_cell       cell % store handles for markers {1}, and text {2}
        mean_flag               logical % whether or not to plot the mean of all group curves
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: BrowseButton
        function BrowseButtonPushed(app, event)
            app.experiment_directory = uigetdir('Select Main Experiment Folder');
            app.IvisExperimentFolderEditField.Value = app.experiment_directory;
            app.StatusWindowTextArea.Value = [ 'Selected folder: ' app.experiment_directory ];
            
            % refocus window
            drawnow;
            figure( app.UIFigure );
            
            % find all of the file names for photos
            app.photo_name_struct = dir( strcat( app.experiment_directory, '/**/photograph.TIF' ) );
            app.reporter_name_struct = dir( strcat( app.experiment_directory, '/**/luminescent.TIF' ) );
            app.num_readings = size( app.photo_name_struct, 1 );
            
            % actually load in the photos
            [ app.photo_cell, app.reporter_cell ] = ...
                loadExperimentTiffs( app.photo_name_struct, app.reporter_name_struct, app.num_readings );
            app.photo_height = size( app.photo_cell{ 1 }, 1 );
            app.photo_width = size( app.photo_cell{ 1 }, 2 );
            
            app.display_photo = createDisplayPhoto( app.photo_cell, app.image_scale );
            app.display_photo_rgb = imresize( repmat( app.display_photo, 1, 1, 3 ), ...
                app.image_scale * size( app.display_photo ) );
            image( app.UIAxes, app.display_photo_rgb );
            image( app.UIAxes2, app.display_photo_rgb );
            image( app.UIAxes3, app.display_photo_rgb );
            
            
            
        end

        % Button pushed function: PlaceROIsButton
        function PlaceROIsButtonPushed(app, event)
            
            app.all_well_radii = ones( app.num_rows * app.num_cols, 1 ) * app.default_radii;
            
            if app.ManualButton.Value
                app.StatusWindowTextArea.Value = 'Manual';
                
                corner_fig = figure('Name', 'Select the four corner wells');
                imshow( app.display_photo );
                app.all_well_centers = manualSelection( app.num_rows, app.num_cols );
                close( corner_fig );
                
            elseif app.AutomaticButton.Value
                app.StatusWindowTextArea.Value = 'Automatic';
                
                [ app.all_well_centers, ~ ] = ...
                    automaticDetection( app.photo_cell, app.approximate_well_radii_range, app.sensitivity );
            end
            
            displayWells( app.UIAxes, app.all_well_centers, app.all_well_radii, app.image_scale )
            app.TabGroup.SelectedTab = app.WellImageTab;

            %{
            saveResults( app.well_counts, app.experiment_directory, app.image_handle );
                        %}
            
        end

        % Button pushed function: AnalyzeWellsButton
        function AnalyzeWellsButtonPushed(app, event)
            app.StatusWindowTextArea.Value = [ app.StatusWindowTextArea.Value; newline 'Analyzing wells...' ];
            app.well_counts = wellCountAnalysis( app.reporter_cell, app.all_well_centers, app.all_well_radii );
            app.StatusWindowTextArea.Value = [ app.StatusWindowTextArea.Value; newline 'Done analyzing wells.' ];
            
            %ize( app.well_counts )
            %well_count_table = array2table( app.well_counts );
            %app.UITable2.Data = well_count_table;

            app.normalized_well_counts = app.well_counts ./ ...
                repmat( app.well_counts(:,1), 1, size( app.well_counts, 2 ));
            
            app.WellcountsvstimeplotButtonGroup.SelectedObject
            msg = plotCountsOverTime( app.UIAxes4, app.normalized_well_counts, app.groups );
            app.TabGroup.SelectedTab = app.CountsvsTimeTab;
            app.StatusWindowTextArea.Value = [ app.StatusWindowTextArea.Value; newline msg ];
            
        end

        % Cell edit callback: UITable
        function UITableCellEdit(app, event)
            indices = event.Indices;
            newData = event.NewData;
            [ app.groups, msg ] = parseGroupData( indices, newData, app.groups );
            app.StatusWindowTextArea.Value = [ app.StatusWindowTextArea.Value; newline msg ];
            
            [ app.group_handle_cell, msg ] = displayGroupPhoto( app.UIAxes3, app.all_well_centers, ...
                app.all_well_radii, app.groups, app.image_scale, app.group_handle_cell );
            app.StatusWindowTextArea.Value = [ app.StatusWindowTextArea.Value; newline msg ];
            
            app.TabGroup.SelectedTab = app.GroupImageTab;
        end

        % Button pushed function: SaveWellCountDataButton
        function SaveWellCountDataButtonPushed(app, event)
            msg = '';
            [ filename, path ] = uiputfile({'*.csv','CSV UTF-8 (Comma delimited) (*.csv)';...
                '*.mat','MAT-files (*.mat)';'*.xlsx','Excel Workbook (*.xlsx)';...
                '*.txt','Text (*.txt)'},'Save well count data',...
                'well_count_data.csv');
            if ~isequal( filename, 0 ) || ~isequal( path, 0 )
                csvwrite( strcat( path, filename ), app.well_counts );
                normalized_fname = [ 'normalized_' filename ];
                csvwrite( strcat( path, normalized_fname ), app.normalized_well_counts );
                msg = [ 'Well count data saved to ' fullfile(path,filename) newline ...
                    'Normalized well count data saved to ' fullfile(path,normalized_fname )];
            else
                msg = [ 'Canceled or invalid filename or path entered' ];
            end
            app.StatusWindowTextArea.Value = [ app.StatusWindowTextArea.Value; newline msg ];
        end

        % Button pushed function: AddgroupButton
        function AddgroupButtonPushed(app, event)
            new_group_str = inputdlg( 'Enter the new group name: ' );
            new_entry = { new_group_str{1}, '' };
            if isempty( app.UITable.Data )
                GroupNames = { new_group_str{1} };
                GroupWells = { '' };
                tdata = table( GroupNames, GroupWells );
                app.UITable.Data = tdata;
            else                
                app.UITable.Data = [ app.UITable.Data; new_entry ];
            end
            app.groups{ size( app.groups, 2 ) + 1 } = new_entry;
        end

        % Button pushed function: CleargroupsButton
        function CleargroupsButtonPushed(app, event)
            app.UITable.Data = table;
            app.groups = {};
            
            [ app.group_handle_cell, msg ] = displayGroupPhoto( app.UIAxes3, app.all_well_centers, ...
                app.all_well_radii, app.groups, app.image_scale, app.group_handle_cell );
        end

        % Selection changed function: 
        % WellcountsvstimeplotButtonGroup
        function WellcountsvstimeplotButtonGroupSelectionChanged(app, event)
            selectedButton = app.WellcountsvstimeplotButtonGroup.SelectedObject;

            size( app.normalized_well_counts )
            app.groups
            if app.WellsbygroupButton.Value
                app.mean_flag = false;
            elseif app.AverageofeachgroupButton.Value
                app.mean_flag = true;
            end
            msg = plotCountsOverTime( app.UIAxes4, app.normalized_well_counts, app.groups, app.mean_flag );
            app.TabGroup.SelectedTab = app.CountsvsTimeTab;
        end

        % Button pushed function: DeletegroupButton
        function DeletegroupButtonPushed(app, event)
            group_to_delete_cell = inputdlg( 'Enter the row number of the group to delete: ' );
            group_to_delete_num = str2num( group_to_delete_cell{1} );
            if isempty( group_to_delete_num )
                msg = [ 'Invalid entry, input must be a number. No groups deleted.'];
            elseif ( group_to_delete_num < 0 ) | ( group_to_delete_num > size( app.groups, 2 ))
                msg = [ 'Invalid entry, input is outside the range valid row numbers. No groups deleted.' ];
            elseif isnumeric( group_to_delete_num )
                app.UITable.Data = [ app.UITable.Data(1:(group_to_delete_num-1),:); ...
                    app.UITable.Data((group_to_delete_num + 1):end,:) ];
                app.groups{ group_to_delete_num } = [];
                app.groups = app.groups(~cellfun('isempty', app.groups));
                msg = [ 'Group ' num2str( group_to_delete_num) ' deleted.'];
            end
            app.StatusWindowTextArea.Value = [ app.StatusWindowTextArea.Value; newline msg ];
        end

        % Changes arrangement of the app based on UIFigure width
        function updateAppLayout(app, event)
            currentFigureWidth = app.UIFigure.Position(3);
            if(currentFigureWidth <= app.onePanelWidth)
                % Change to a 2x1 grid
                app.GridLayout.RowHeight = {598, 598};
                app.GridLayout.ColumnWidth = {'1x'};
                app.RightPanel.Layout.Row = 2;
                app.RightPanel.Layout.Column = 1;
            else
                % Change to a 1x2 grid
                app.GridLayout.RowHeight = {'1x'};
                app.GridLayout.ColumnWidth = {380, '1x'};
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
            app.UIFigure.Position = [100 100 843 598];
            app.UIFigure.Name = 'UI Figure';
            app.UIFigure.SizeChangedFcn = createCallbackFcn(app, @updateAppLayout, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {380, '1x'};
            app.GridLayout.RowHeight = {'1x'};
            app.GridLayout.ColumnSpacing = 0;
            app.GridLayout.RowSpacing = 0;
            app.GridLayout.Padding = [0 0 0 0];
            app.GridLayout.Scrollable = 'on';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.GridLayout);
            app.LeftPanel.Layout.Row = 1;
            app.LeftPanel.Layout.Column = 1;

            % Create IvisExperimentFolderEditFieldLabel
            app.IvisExperimentFolderEditFieldLabel = uilabel(app.LeftPanel);
            app.IvisExperimentFolderEditFieldLabel.HorizontalAlignment = 'right';
            app.IvisExperimentFolderEditFieldLabel.Position = [82 569 125 22];
            app.IvisExperimentFolderEditFieldLabel.Text = 'Ivis Experiment Folder';

            % Create IvisExperimentFolderEditField
            app.IvisExperimentFolderEditField = uieditfield(app.LeftPanel, 'text');
            app.IvisExperimentFolderEditField.HorizontalAlignment = 'right';
            app.IvisExperimentFolderEditField.Position = [9 548 299 22];

            % Create BrowseButton
            app.BrowseButton = uibutton(app.LeftPanel, 'push');
            app.BrowseButton.ButtonPushedFcn = createCallbackFcn(app, @BrowseButtonPushed, true);
            app.BrowseButton.Position = [316 548 55 23];
            app.BrowseButton.Text = 'Browse';

            % Create PlaceROIsButton
            app.PlaceROIsButton = uibutton(app.LeftPanel, 'push');
            app.PlaceROIsButton.ButtonPushedFcn = createCallbackFcn(app, @PlaceROIsButtonPushed, true);
            app.PlaceROIsButton.Position = [26 327 100 22];
            app.PlaceROIsButton.Text = 'Place ROIs';

            % Create ROIDetectionLabel
            app.ROIDetectionLabel = uilabel(app.LeftPanel);
            app.ROIDetectionLabel.Position = [30 429 118 32];
            app.ROIDetectionLabel.Text = 'ROI Detection';

            % Create DetectionMethodButtonGroup
            app.DetectionMethodButtonGroup = uibuttongroup(app.LeftPanel);
            app.DetectionMethodButtonGroup.Title = 'Detection Method';
            app.DetectionMethodButtonGroup.Position = [26 359 124 71];

            % Create ManualButton
            app.ManualButton = uiradiobutton(app.DetectionMethodButtonGroup);
            app.ManualButton.Text = 'Manual';
            app.ManualButton.Position = [11 25 61 22];
            app.ManualButton.Value = true;

            % Create AutomaticButton
            app.AutomaticButton = uiradiobutton(app.DetectionMethodButtonGroup);
            app.AutomaticButton.Text = 'Automatic';
            app.AutomaticButton.Position = [11 3 75 22];

            % Create UITable
            app.UITable = uitable(app.LeftPanel);
            app.UITable.ColumnName = {'Group Name'; 'Wells'};
            app.UITable.RowName = {'1'; '2'; '3'; '4'; '5'; '6'; '7'; '8'; '9'; '10'; '11'; '12'};
            app.UITable.ColumnEditable = true;
            app.UITable.CellEditCallback = createCallbackFcn(app, @UITableCellEdit, true);
            app.UITable.Position = [23 180 322 103];

            % Create PhotonCountAnalysisLabel
            app.PhotonCountAnalysisLabel = uilabel(app.LeftPanel);
            app.PhotonCountAnalysisLabel.Position = [23 112 127 22];
            app.PhotonCountAnalysisLabel.Text = 'Photon Count Analysis';

            % Create AnalyzeWellsButton
            app.AnalyzeWellsButton = uibutton(app.LeftPanel, 'push');
            app.AnalyzeWellsButton.ButtonPushedFcn = createCallbackFcn(app, @AnalyzeWellsButtonPushed, true);
            app.AnalyzeWellsButton.Position = [23 91 100 22];
            app.AnalyzeWellsButton.Text = 'Analyze Wells';

            % Create SaveWellCountDataButton
            app.SaveWellCountDataButton = uibutton(app.LeftPanel, 'push');
            app.SaveWellCountDataButton.ButtonPushedFcn = createCallbackFcn(app, @SaveWellCountDataButtonPushed, true);
            app.SaveWellCountDataButton.Position = [170 91 175 22];
            app.SaveWellCountDataButton.Text = 'Save Well Count Data';

            % Create AddgroupButton
            app.AddgroupButton = uibutton(app.LeftPanel, 'push');
            app.AddgroupButton.ButtonPushedFcn = createCallbackFcn(app, @AddgroupButtonPushed, true);
            app.AddgroupButton.Position = [26 146 100 22];
            app.AddgroupButton.Text = 'Add group';

            % Create CleargroupsButton
            app.CleargroupsButton = uibutton(app.LeftPanel, 'push');
            app.CleargroupsButton.ButtonPushedFcn = createCallbackFcn(app, @CleargroupsButtonPushed, true);
            app.CleargroupsButton.Position = [244 147 100 22];
            app.CleargroupsButton.Text = 'Clear groups';

            % Create WellcountsvstimeplotButtonGroup
            app.WellcountsvstimeplotButtonGroup = uibuttongroup(app.LeftPanel);
            app.WellcountsvstimeplotButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @WellcountsvstimeplotButtonGroupSelectionChanged, true);
            app.WellcountsvstimeplotButtonGroup.Title = 'Well counts vs time plot';
            app.WellcountsvstimeplotButtonGroup.Position = [26 6 158 73];

            % Create WellsbygroupButton
            app.WellsbygroupButton = uiradiobutton(app.WellcountsvstimeplotButtonGroup);
            app.WellsbygroupButton.Text = 'Wells by group';
            app.WellsbygroupButton.Position = [11 27 101 22];
            app.WellsbygroupButton.Value = true;

            % Create AverageofeachgroupButton
            app.AverageofeachgroupButton = uiradiobutton(app.WellcountsvstimeplotButtonGroup);
            app.AverageofeachgroupButton.Text = 'Average of each group';
            app.AverageofeachgroupButton.Position = [11 5 143 22];

            % Create ROITypeDropDownLabel
            app.ROITypeDropDownLabel = uilabel(app.LeftPanel);
            app.ROITypeDropDownLabel.HorizontalAlignment = 'right';
            app.ROITypeDropDownLabel.Position = [26 473 56 22];
            app.ROITypeDropDownLabel.Text = 'ROI Type';

            % Create ROITypeDropDown
            app.ROITypeDropDown = uidropdown(app.LeftPanel);
            app.ROITypeDropDown.Items = {'96 Well Plate', 'Single Circle'};
            app.ROITypeDropDown.Position = [97 473 148 22];
            app.ROITypeDropDown.Value = '96 Well Plate';

            % Create DeletegroupButton
            app.DeletegroupButton = uibutton(app.LeftPanel, 'push');
            app.DeletegroupButton.ButtonPushedFcn = createCallbackFcn(app, @DeletegroupButtonPushed, true);
            app.DeletegroupButton.Position = [135 147 100 22];
            app.DeletegroupButton.Text = 'Delete group';

            % Create RightPanel
            app.RightPanel = uipanel(app.GridLayout);
            app.RightPanel.Layout.Row = 1;
            app.RightPanel.Layout.Column = 2;

            % Create TabGroup
            app.TabGroup = uitabgroup(app.RightPanel);
            app.TabGroup.Position = [6 167 452 424];

            % Create PlateImageTab
            app.PlateImageTab = uitab(app.TabGroup);
            app.PlateImageTab.Title = 'Plate Image';

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.PlateImageTab);
            title(app.UIAxes2, '')
            xlabel(app.UIAxes2, '')
            ylabel(app.UIAxes2, '')
            app.UIAxes2.DataAspectRatio = [1 1 1];
            app.UIAxes2.PlotBoxAspectRatio = [1 1 1];
            app.UIAxes2.XTick = [];
            app.UIAxes2.YTick = [];
            app.UIAxes2.Position = [16 14 423 376];

            % Create WellImageTab
            app.WellImageTab = uitab(app.TabGroup);
            app.WellImageTab.Title = 'Well Image';

            % Create UIAxes
            app.UIAxes = uiaxes(app.WellImageTab);
            title(app.UIAxes, '')
            xlabel(app.UIAxes, '')
            ylabel(app.UIAxes, '')
            app.UIAxes.DataAspectRatio = [1 1 1];
            app.UIAxes.PlotBoxAspectRatio = [1 1 1];
            app.UIAxes.XTick = [];
            app.UIAxes.YTick = [];
            app.UIAxes.Position = [31 28 390 343];

            % Create GroupImageTab
            app.GroupImageTab = uitab(app.TabGroup);
            app.GroupImageTab.Title = 'Group Image';

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.GroupImageTab);
            title(app.UIAxes3, '')
            xlabel(app.UIAxes3, '')
            ylabel(app.UIAxes3, '')
            app.UIAxes3.DataAspectRatio = [1 1 1];
            app.UIAxes3.PlotBoxAspectRatio = [1 1 1];
            app.UIAxes3.XTick = [];
            app.UIAxes3.YTick = [];
            app.UIAxes3.Position = [23 20 415 362];

            % Create CountsvsTimeTab
            app.CountsvsTimeTab = uitab(app.TabGroup);
            app.CountsvsTimeTab.Title = 'Counts vs Time';

            % Create UIAxes4
            app.UIAxes4 = uiaxes(app.CountsvsTimeTab);
            title(app.UIAxes4, 'Title')
            xlabel(app.UIAxes4, 'X')
            ylabel(app.UIAxes4, 'Y')
            app.UIAxes4.PlotBoxAspectRatio = [1.1280724450194 1 1];
            app.UIAxes4.Position = [20 17 397 365];

            % Create StatusWindowTextAreaLabel
            app.StatusWindowTextAreaLabel = uilabel(app.RightPanel);
            app.StatusWindowTextAreaLabel.HorizontalAlignment = 'right';
            app.StatusWindowTextAreaLabel.Position = [7 126 85 22];
            app.StatusWindowTextAreaLabel.Text = 'Status Window';

            % Create StatusWindowTextArea
            app.StatusWindowTextArea = uitextarea(app.RightPanel);
            app.StatusWindowTextArea.Position = [7 14 416 115];

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