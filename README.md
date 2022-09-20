% -------------------------------------------------------------------------
% 
% Script to calculate the overlap between two different channels. It was
% originally written to calculate the overlap between Actin (channel 1),
% and Clathrin (channel 2), with the purpose of seeing how much Actin
% overlaps with Clathrin (and not the other way around).
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
