% Datei einlesen (CSV mit 3 Spalten: x, y, z)
data = readmatrix('deltarobot_curve3.csv');

data(data(:,1) > 2500 | data(:,2) > 2500 | data(:,3) > 2500, :) = [];

[coeff, score, latent] = pca(data);

axisVec = coeff(:,1);

% HIER FEHLT NOCH CODE AUS CHATGPT


%------- ALPHASHAPE ------
% AlphaShape mit dem besten Alpha erzeugen, das gefunden werden kann
shp = alphaShape(x,y,z);
alpha_crit = criticalAlpha(shp, 'one-region');
shp.Alpha = alpha_crit;

% Neue Figur
figure

% Punktwolke darstellen
scatter3(x,y,z,5,'filled')
hold on

% AlphaShape darstellen
plot(shp,'FaceAlpha',0.3)


% Achsenbeschriftung
xlabel('x')
ylabel('y')
zlabel('z')

% Darstellung verbessern
axis equal
grid on
title('Alpha Shape der Punktwolke')

view(3)