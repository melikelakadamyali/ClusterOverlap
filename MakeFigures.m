% -------------------------------------------------------------------------
% 
% Script to calculate p-values between the different distributions, and
% also show the boxplots of the distributions.
%
% The input is the data table that is obtained from the
% 'OverlapCalculation.m' file.
% 
% The output are the Matlab figures, which are also saved to the current
% directory as .png files.
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

% Extract the data for each of the two groups.
% Extract the weights from the table, which correspond to the number of
% clathrin clusters present in each ROI.
OnClathrin = table2array(TableResults(:,8));
NotOnClathrin = table2array(TableResults(:,10));
Weights = table2array(TableResults(:,4));

% Display the weighted mean (weighted by number of clusters in each ROI)
% for both groups (on/off Clathrin coated pit).
disp('Weighted mean Coloc %:')
disp(['On Clathrin coated pit: ' num2str(round(sum(OnClathrin.*Weights)./sum(Weights),2)) ' ± ' num2str(round(sqrt(var(OnClathrin,Weights)),2)) ' %'])
disp(['Not on Clathrin coated pit: ' num2str(round(sum(NotOnClathrin.*Weights)./sum(Weights),2)) ' ± ' num2str(round(sqrt(var(NotOnClathrin,Weights)),2)) ' %'])
disp(' ')

% Re-arrange the data to easily make boxplot figures.
T = array2table([OnClathrin;NotOnClathrin]);
Group = [ones(size(OnClathrin,1),1); ones(size(NotOnClathrin,1),1)*2];
T(:,2) = array2table(Group);
T.Properties.VariableNames = {'Data','Group'};
Order = ["Co-localized","Not co-localized"];
namedOrder = categorical(T.Group,1:2,Order);

% Make the actual boxplot figure and save it as a .png file.
% Please note that you can uncomment the 4 lines to show the weighted mean
% instead of the median (as in the paper).
figure;
b = boxchart(namedOrder,T.Data,'boxfacecolor','k','markerstyle','.','markercolor','k');set(gca,'FontSize',12,'FontWeight','bold');ylim([0 115])
b.BoxFaceAlpha = 0.3;b.MarkerColor=[1 1 1];
hold on;
line([1 1],[105 108],'color','k','linewidth',2)
line([2 2],[105 108],'color','k','linewidth',2)
line([1 2],[108 108],'color','k','linewidth',2)
% line([0.753 1.247],[median(OnClathrin) median(OnClathrin)],'color',[0.7 0.7 0.7],'linewidth',2)
% line([1.753 2.247],[median(NotOnClathrin) median(NotOnClathrin)],'color',[0.7 0.7 0.7],'linewidth',2)
% line([0.753 1.247],[sum(OnClathrin.*Weights)./sum(Weights) sum(OnClathrin.*Weights)./sum(Weights)],'color','k','linewidth',1)
% line([1.753 2.247],[sum(NotOnClathrin.*Weights)./sum(Weights) sum(NotOnClathrin.*Weights)./sum(Weights)],'color','k','linewidth',1)
text(1.4,110,'****','color','k','fontweight','bold','fontsize',12)
ylabel('(%)')
print('WeightedMean_1pixels_Colocalization_vs_noncolocalization.png','-dpng','-r400')


% Extract the data for each of the two groups, for the overlap normalized
% by the area.
% The weights do not need to be extracted anymore, as these are the same as
% above.
OnClathrin = table2array(TableResults(:,9));
NotOnClathrin = table2array(TableResults(:,11));

% Display the weighted mean (weighted by number of clusters in each ROI)
% for both groups (on/off Clathrin coated pit).
disp('Weighted mean normalized results:')
disp(['On Clathrin coated pit: ' num2str(round(sum(OnClathrin.*Weights)./sum(Weights),2)) ' ± ' num2str(round(sqrt(var(OnClathrin,Weights)),2)) ' localizations . pixel' char(8315) char(178)])
disp(['Not on Clathrin coated pit: ' num2str(round(sum(NotOnClathrin.*Weights)./sum(Weights),2)) ' ± ' num2str(round(sqrt(var(NotOnClathrin,Weights)),2)) ' localizations . pixel' char(8315) char(178)])
disp(' ')

% Perform a two-sample t-test for this data, and display the results.
[h,p] = ttest2(OnClathrin,NotOnClathrin);
disp(['h = ' num2str(h)])
disp(['p = ' num2str(p,4)])

% Re-arrange the data to easily make boxplot figures.
T = array2table([OnClathrin;NotOnClathrin]);
Group = [ones(size(OnClathrin,1),1); ones(size(NotOnClathrin,1),1)*2];
T(:,2) = array2table(Group);
T.Properties.VariableNames = {'Data','Group'};
Order = ["On clathrin","Not on clathrin"];
namedOrder = categorical(T.Group,1:2,Order);

% Make the actual boxplot figure and save it as a .png file.
% Please note that you can uncomment the 4 lines to show the weighted mean
% instead of the median (as in the paper).
figure;
b = boxchart(namedOrder,T.Data,'boxfacecolor','k','markerstyle','.','markercolor','k');set(gca,'FontSize',12,'FontWeight','bold');ylim([0 50])
b.BoxFaceAlpha = 0.3;b.MarkerColor=[1 1 1];
hold on;
line([1 1],[43 45],'color','k','linewidth',2)
line([2 2],[43 45],'color','k','linewidth',2)
line([1 2],[45 45],'color','k','linewidth',2)
% line([0.753 1.247],[median(OnClathrin) median(OnClathrin)],'color',[0.7 0.7 0.7],'linewidth',2)
% line([1.753 2.247],[median(NotOnClathrin) median(NotOnClathrin)],'color',[0.7 0.7 0.7],'linewidth',2)
% line([0.753 1.247],[sum(OnClathrin.*Weights)./sum(Weights) sum(OnClathrin.*Weights)./sum(Weights)],'color','k','linewidth',1)
% line([1.753 2.247],[sum(NotOnClathrin.*Weights)./sum(Weights) sum(NotOnClathrin.*Weights)./sum(Weights)],'color','k','linewidth',1)
text(1.15,47,['p = ' num2str(p,4)],'color','k','fontweight','bold','fontsize',12)
ylabel('Localizations . pixel^{-2}')
print('WeightedMean_1pixels_OnClathrin_vsNotOnClathrin.png','-dpng','-r400')