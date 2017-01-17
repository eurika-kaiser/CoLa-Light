clear all, close all,

% Include path to src
addpath('../src/');

% Parameters
Ngen  = 9;
Nlaws = 100;

% Load example data
load('D2.mat');
load('zCost.mat');
CDM = CDM(1:Ngen*Nlaws,1:Ngen*Nlaws);
J = J(1:Ngen*Nlaws);

options.path2save = 'output/';
mkdir(options.path2save)

% Example matrix consists of squared distances
% Algorithm requires distances
DistanceMatrix = sqrt(CDM);

% Check symmetry
issymmetric(DistanceMatrix)

%% Computations
% Classical multidimensional scaling method
X = cmds(DistanceMatrix,2);
save(fullfile(options.path2save,'X.mat'),'X');
%load(fullfile(options.path2save,'X.mat'));

%% PLOTS

% Distance matrix
fhandle = figure;
imagesc(DistanceMatrix)
set(gca,'XAxisLocation','top')
xlabel('control law index')
ylabel('control law index')
box on
axis tight
axis equal
set(gca,'FontSize',14,'LineWidth',1)
set(gcf,'Position',[0 0 300 300])
set(gcf,'PaperPositionMode','auto')
print('-depsc2', '-loose', fullfile(options.path2save,'DistanceMatrix.eps'));
close(fhandle);

% Do a nicer plot and save it
Data2plot.labels = ones(size(X,1),1);
Data2plot.X      = X;
options.xname    = '\gamma_1';
options.yname    = '\gamma_2';
options.title    = '2D plot';
options.filename = [options.path2save,'2Dplot'];
plot2D(Data2plot, options)


%% Plot
cmap    = jet(Ngen*10); cmap = cmap(1:10:end,:);
symbols = {'o'};
Centroids2plot = zeros(Nlaws,2,Ngen);
IDX = [1:Ngen*Nlaws]'; IDX = reshape(IDX,[Nlaws,Ngen]);
for i = 1:Ngen
    Centroids2plot(:,:,i) = X(IDX(:,i),:);
end

Data2Plot.centroids  = Centroids2plot;
Data2Plot.cmap       = cmap;
h = figure;hold on
for i = 1:Ngen
    phandle = scatter(squeeze(Centroids2plot(:,1,i)),squeeze(Centroids2plot(:,2,i)),[],Data2Plot.cmap(i,:),'filled','SizeData',30);
end
%alpha(0.4)
xlabel('\gamma_1')
ylabel('\gamma_2')
axis equal
axis tight
colormap(cmap)
chandle = colorbar();
chandle.Ticks = [1/Ngen-1/(2*Ngen):1/Ngen:1];
TickLabels = num2str([1:Ngen]');
chandle.TickLabels = TickLabels;%{'1', '2', '3', '4', '5', '6', '7', '8'};
chandle.FontSize=6;
box on
axis tight
set(gca,'FontSize',14,'LineWidth',1)
set(gcf,'Position',[0 0 300 300])
set(gcf,'PaperPositionMode','auto')
print('-depsc2', '-loose', fullfile(options.path2save,'2Dviz.eps'));
close(h);


%% 3D plot with J
[Jsort,IX] = sort(J,'descend');

dx = (max(max(max(Centroids2plot(:,2,:))))-min(min(min(Centroids2plot(:,2,:)))))./10;
dy = (max(max(max(Centroids2plot(:,1,:))))-min(min(min(Centroids2plot(:,1,:)))))./10;
dz = (max(max(max(J)))-min(min(min(J))))./10;

xval = min(min(min(Centroids2plot(:,2,:))))-4*dx;
yval = min(min(min(Centroids2plot(:,1,:))))-4*dy;
zval = 0;

cmap_dark = Data2Plot.cmap;
cmap_bright = Data2Plot.cmap;

h = figure;
hold on, grid on   

for i = 1:Ngen
    
    for j = 1:size(Centroids2plot(:,2,i),1)
        plot3(Centroids2plot(j,2,i).*ones(1,2),Centroids2plot(j,1,i).*ones(1,2),[zval J(IDX(j,i))],'-','Color',cmap_dark(i,:))
    end   
    
    shandle = scatter3(squeeze(Centroids2plot(:,2,i)),squeeze(Centroids2plot(:,1,i)),J(IDX(:,i)),...
        [],cmap_dark(i,:),'filled','SizeData',30);

    % x
    xvalues = xval.*ones(size(squeeze(Centroids2plot(:,2,i))));
    phandle = scatter3(xvalues,squeeze(Centroids2plot(:,1,i)),J(IDX(:,i)),...
        [],cmap_bright(i,:),'filled','SizeData',5);
    
    % y
    yvalues = yval.*ones(size(squeeze(Centroids2plot(:,1,i))));
    phandle = scatter3(squeeze(Centroids2plot(:,2,i)),yvalues,J(IDX(:,i)),...
        [],cmap_bright(i,:),'filled','SizeData',5);
    
    % z
    zvalues = zval.*ones( size( squeeze( J(IDX(:,i)) )));
    phandle = scatter3(squeeze(Centroids2plot(:,2,i)),squeeze(Centroids2plot(:,1,i)),zvalues,...
        [],cmap_bright(i,:),'filled','SizeData',5);
    
end

xlabel('\gamma_2')
ylabel('\gamma_1')
zlabel('J')
axis equal
axis tight
colormap(cmap)
chandle = colorbar();
chandle.Ticks = [1/Ngen-1/(2*Ngen):1/Ngen:1];
TickLabels = num2str([1:Ngen]');
chandle.TickLabels = TickLabels;%{'1', '2', '3', '4', '5', '6', '7', '8'};
chandle.FontSize=6;
box on
axis tight
view(120,20)
%daspect([3 3 1])
daspect([6 6 1])
set(gca,'FontSize',14,'LineWidth',1)
set(gcf,'Position',[0 0 600 400])
set(gcf,'PaperPositionMode','auto')
print('-depsc2', '-loose', fullfile(options.path2save,'2Dviz_J_proj.eps'));
%close(h);


