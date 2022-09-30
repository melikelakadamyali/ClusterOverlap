% -------------------------------------------------------------------------
% 
% Script to calculate the overlap between two different channels. It was
% originally written to calculate the overlap between Actin (channel 1),
% and Clathrin (channel 2), with the purpose of seeing how much Actin
% overlaps with Clathrin (and not the other way around).
%
% This script does the following:
%   1. Run the overlap calculation script
%       Takes about 1 minute on an i7-12700H 2.30 GHz (32 GB RAM) laptop
%   2. Plot the figures and calculate the p-values
%       Takes about 5 seconds on i7-12700H 2.30 GHz (32 GB RAM) laptop
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

% Change the folder to the one the script is run from. If this does not
% work, just comment out this code and do it manually.
tmp = matlab.desktop.editor.getActive;
cd(fileparts(tmp.Filename));

% Run the script that calculates the overlap between the clathrin and
% actin.
% This will save some variables in the work space that will then be used to
% show the figures.
OverlapCalculation

% Run the script that makes the figures.
Makefigures