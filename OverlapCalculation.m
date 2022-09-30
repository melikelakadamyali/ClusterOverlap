% -------------------------------------------------------------------------
% 
% Script to calculate the overlap between two different channels. It is
% written to calculate the overlap between Actin (channel 1), and Clathrin 
% (channel 2), with the purpose of seeing how much Actin overlaps with 
% Clathrin (and not the other way around).
%
% The input should fulfill the following criteria:
%       1.  The data should be localized and segmented/clustered data of
%           which the order is ch1 - ch2 - ch1 - ch2 - etc. Remove any
%           unused data.
%       2.  ROIs can (but do not have to) be selected, as it will make
%           results more accurate.
% 
% The output is given in two different ways:
%       1.  In percentage
%           a) Number of Actin locs that overlap / total Actin locs
%           b) Number of Actin locs that do not overlap / total Actin locs
%       2.  Normalized by area
%           a) Actin locs that overlap / Clathrin area
%           b) Actin locs that do not overlap / clathrin-free area
%
% The output will be saved in an Excel file (1 row for each ROI).
%       Column 1: Name ROI (taken from ch1)
%       Column 2: number of total ch1 localizations (Actin) - # locs
%       Column 3: number of total ch2 localizations (Clathrin) - # locs
%       Column 4: Total area of localizations in ch2 (Clathrin) - pixels²
%       Column 5: Total area of non-ch2 (area rectangle - channel2
%                 area) - pixels²
%       Column 6: Overlap of ch1 localizations (Actin) with ch2 (Clathrin)
%                 - %
%       Column 7: Normalized overlap (see above: Output 2a) - # locs /
%                 pixels²
%       Column 8: Non-overlap of ch1 localizations (Actin) with c2 
%                 (Clathrin) - %
%       Column 9: Normalized non-overlap (see above: Output 2b) - # locs / 
%                 pixels²
%
% -------------------------------------------------------------------------
% Code written by:
%   Siewert Hugelier    Lakadamyali lab, University of Pennsylvania (USA)
% Contact:
%   siewert.hugelier@pennmedicine.upenn.edu
%   melike.lakadamyali@pennmedicine.upenn.edu
% If used, please cite:
%   Yang C, Colosi P, Hugelier S, Zabezhinsky D, Lakadamyali M & Svitkina
%   T. Actin polymerization promotes invagination of flat clathrin-coated
%   lattices in mammalian cells by pushing at the lattice edges. Nat. Comm.
%   2022.
% -------------------------------------------------------------------------

% Initiate a new MATLAB 'session' by clearing the entire workspace and
% closing everything.
clc;close all;clear
warning('off')

% Expansion factor (in pixels).
Expansion = 1; % This can be changed.

% Load the MATLAB session you want to investigate.
[file,path] = uigetfile('*.mat','Please load the MATLAB file you want.'); % Only show .mat files.

% Check if the user selects cancel or an actual file. Stop the script if
% nothing valid was selected.
if isequal(file,0)
    disp('User selected Cancel'); % Stop the script.
else
    disp(['User selected ', fullfile(path,file)]); % Show which file was selected.
    load(fullfile(path,file)) % Load the file.

    % Select an Excel file to save the results.
    [savefile,path] = uiputfile('Results.xlsx','Please specify a name to save the output as'); % Extract the name of the file given.

    % Check if the user actually specifies an output file.
    if isequal(savefile,0)
        disp('User did not specify a valid save file'); % Stop the script.
    else
        name = fullfile(path,savefile); % Make it a full name to save it as later.
        clear savefile path

        % Delete the file if it exists. This avoids extra entries if the 
        % file already existed before.
        if exist(name,'file') == 2
            delete(name); % Delete the file.
        end

        data = reshape(data,2,size(data,2)/2); % Re-organize the data to get 2 rows: one for Actin, one for Clathrin.

        % Make alphaShapes for the clathrin data. We want to check how much
        % of the Actin overlaps with the Clathrin.
        nClusters = zeros(size(data,2),1); % Memory pre-allocation.
        nLocsClose = zeros(size(data,2),1); % Memory pre-allocation.
        Area = zeros(size(data,2),1); % Memory pre-allocation.
        NonArea = zeros(size(data,2),1); % Memory pre-allocation.
        Overlap = zeros(size(data,2),1); % Memory pre-allocation.
        NonOverlap = zeros(size(data,2),1); % Memory pre-allocation.
        OverlapNorm = zeros(size(data,2),1); % Memory pre-allocation.
        NonOverlapNorm = zeros(size(data,2),1); % Memory pre-allocation.
        Names = cell(size(data,2),1); % Memory pre-allocation.

        wb = waitbar(0,'Calculating overlap for all ROIs.'); % Show a waitbar.
        for i = 1:size(data,2)
            waitbar(i/size(data,2),wb,['Calculating overlap for all ROIs: ' num2str(i) '/' num2str(size(data,2))]); % Update the waitbar.

            % Extract the name from the files.
            a = strfind(lower(data{1,i}.name),'sample'); % Check which sample it is.
            b = strfind(lower(data{1,i}.name),'storm-'); % Check which cell it is.
            c = strfind(lower(data{1,i}.name),'crop_'); % Check which ROI it is.
            Names{i} = ['Sample' data{1,i}.name(a+6) '_Cell' data{1,i}.name(b+6) '_ROI' data{1,i}.name(c+5:end)]; % Combine the names.
    
            % Extract each individual cluster of Clathrin so an alphaShape 
            % can be made of it.
            DataClathrin = horzcat(data{2,i}.x_data,data{2,i}.y_data,data{2,i}.area); % Set up the reference data for Clathrin.
            Groups = findgroups(DataClathrin(:,3)); % Find unique groups and their number.
            ClustersClathrin = splitapply(@(x){(x)},DataClathrin(:,1:3),Groups); % Split them according to their group.
            ClustersClathrin(cellfun('size',ClustersClathrin,1)<5) = []; % Remove the clusters smaller than 5 localizations. This is the standard in the clustering algorithm (just do it again here to be sure).
            nClusters(i) = size(ClustersClathrin,1);

            % Make local areas around the Clathrin clusters, so the Actin 
            % data points that are in the vicinity can be extracted.
            Clathrin_Bound = cellfun(@(x) boundary(x(:,1:2),1),ClustersClathrin,'UniformOutput',false); % Extract the IDs of the boundary points of the Clathrin clusters.
            Clathrin_BoundCoords = cellfun(@(x,y) x(y,1:2),ClustersClathrin,Clathrin_Bound,'UniformOutput',false); % Extract the boundary coordinates of the Clathrin clusters.
            Polygon_Clath = cellfun(@(x) polyshape(x),Clathrin_BoundCoords,'UniformOutput',false); % Make polyShapes of the Clathrin clusters.
            PolyshapeClathrin = union(vertcat(Polygon_Clath{:})); % Make a single polyShape for all Clathrin clusters.
            Polygon_Clath_expanded = cellfun(@(x) polybuffer(x,Expansion),Polygon_Clath,'UniformOutput',false); % Expand the Clathrin clusters (circle around it; units in pixels).

            DataActin = horzcat(data{1,i}.x_data,data{1,i}.y_data,data{1,i}.area); % Set up the reference data for Actin.
            tf = cellfun(@(x) inpolygon(DataActin(:,1),DataActin(:,2),x.Vertices(:,1),x.Vertices(:,2)),Polygon_Clath_expanded,'UniformOutput',false); % Check for expanded Clathrin polyShape if the Actin points are inside or not.
            
            ClustersActin = cellfun(@(x) DataActin(x,:),tf,'UniformOutput',false); % Extract the points of Actin that are inside the zones.
            ClustersActin(cellfun('size',ClustersActin,1)<3) = []; % Remove the clusters smaller than 3 localizations (cannot make polyShapes from those).
            
            % Make Actin clusters.
            % We do not care at this point that some localizations were
            % selected double, because this will be taken care of by the
            % 'union' function for the polyShapes.
            Actin_Bound = cellfun(@(x) boundary(x(:,1:2),1),ClustersActin,'UniformOutput',false); % Extract the IDs of the boundary points of the Clathrin clusters.
            Actin_BoundCoords = cellfun(@(x,y) x(y,1:2),ClustersActin,Actin_Bound,'UniformOutput',false); % Extract the boundary coordinates of the Clathrin clusters.
            Polygon_Actin = cellfun(@(x) polyshape(x),Actin_BoundCoords,'UniformOutput',false); % Make polyShapes of the Clathrin clusters.
            PolyshapeActin = union(vertcat(Polygon_Actin{:})); % Make a single polyShape for all Clathrin clusters.

            % Set up the combined Clathrin-Actin area and then subtract the
            % Clathrin area to get the non-overlapping Actin area.
            All = union([PolyshapeActin;PolyshapeClathrin]); % Combine clathrin & Actin polyShapes.
            All_NoClathrin = subtract(All,PolyshapeClathrin); % Subtract Clathrin polyShape.
            
            Area(i) = area(PolyshapeClathrin); % Extract the area covered by the Clathrin (holes are not counted).
            NonArea(i) = area(All_NoClathrin); % Extract the area not covered by the Clathrin (holes are not counted).

            % Extract the Actin localizations that are locally close to the
            % Clathrin.
            tf = inpolygon(DataActin(:,1),DataActin(:,2),All.Vertices(:,1),All.Vertices(:,2)); % Check which points are inside.
            DataActin = DataActin(tf,:); % Extract only those points.
            nLocsClose(i) = size(DataActin,1);

            % Make the alphaShape of each cluster, and make it a one-region
            % shape.
            ClustersClathrinShp = cellfun(@(x) alphaShape(x(:,1:2)),ClustersClathrin,'UniformOutput',false); % Make an alphaShape of the Clathrin data.
            AlphaOneRegion = cellfun(@(x) criticalAlpha(x,'one-region'),ClustersClathrinShp,'UniformOutput',false); % Calculate the alpha corresponding to a 'one region' alphaShape, to make sure that all (x,y) coordinates are connected.
            for j = 1:size(ClustersClathrinShp,1)
                ClustersClathrinShp{j}.Alpha = AlphaOneRegion{j}; % Make the alphaShapes one region.
            end

            % Calculate which Actin localizations overlap and which ones do
            % not.
            tf = cellfun(@(x) inShape(x,DataActin(:,1),DataActin(:,2)),ClustersClathrinShp,'UniformOutput',false); % Check for each individual AlphaShape if the points are inside or not.
            InsideOrNot = sum(horzcat(tf{:}),2); % Combine the results of all individual clusters.
            Overlap(i) = sum(InsideOrNot~=0) / numel(InsideOrNot)*100; % Calculate the percentage of overlap.
            OverlapNorm(i) = sum(InsideOrNot~=0) / Area(i); % Normalize the non-overlapped Actin localizations by the area that Clathrin does not cover.
            
            NonOverlap(i) = (numel(InsideOrNot) - sum(InsideOrNot~=0)) / numel(InsideOrNot)*100; % Calculate the percentage that did not overlap.
            NonOverlapNorm(i) = (numel(InsideOrNot) - sum(InsideOrNot~=0)) / NonArea(i); % Normalize the non-overlapped Actin localizations by the area that Clathrin does not cover.

        end
        close(wb) % Close the waitbar.

        % Make a table with all the results and then write it to an Excel
        % file.
        TableResults = cell(size(data,2),11); % Memory pre-allocation.

        for i = 1:size(data,2)
            TableResults{i,1} = Names{i}; % Specify the name (taken from the Actin).
            TableResults{i,2} = size(data{1,i}.x_data,1); % Specify the number of Actin localizations.
            TableResults{i,3} = size(data{2,i}.x_data,1); % Specify the number of Clathrin localizations.
            TableResults{i,4} = nClusters(i); % Specify the number of Clathrin clusters.
            TableResults{i,5} = nLocsClose(i); % Specify the number of Actin localizations close to a Clathrin cluster.
            TableResults{i,6} = round(Area(i),2); % Specify the Clathrin area.
            TableResults{i,7} = round(NonArea(i),2); % Specify the area not covered by Clathrin.
            TableResults{i,8} = round(Overlap(i),2); % Specify the percentage of overlapped Actin localizations.
            TableResults{i,9} = round(OverlapNorm(i),2); % Normalize the overlapped Actin localizations by the area covered by clathrin.
            TableResults{i,10} = round(NonOverlap(i),2); % Specify the percentage of non-overlapped Actin localizations.
            TableResults{i,11} = round(NonOverlapNorm(i),2); % Normalize the non-overlapped Actin localizations by the area not covered by clathrin.
        end
        TableResults = cell2table(TableResults); % Transform the cell into a table.
        TableResults.Properties.VariableNames = {'Sample_Name','#_Locs_Actin','#_Locs_Clathrin','#_Clusters_Clathrin','#_Locs_Actin_Close_To_Clathrin','Area_Clathrin_(pix²)','Area_Not_Clathrin_(pix²)','Overlap_(%)','Overlap_Norm_By_Area_(Locs/pix²)','NonOverlap_(%)','NonOverlap_Norm_By_Not_Area_(Locs/pix²)'}; % Specify the variable names for the Excel table.
        writetable(TableResults,name,'sheet','Results'); % Write the results to the Excel file.

    end
end
clearvars -except data TableResults % Clear the workspace.
warning('on') % Turn the warnings back on.