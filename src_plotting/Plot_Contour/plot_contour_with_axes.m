% Datei einlesen (CSV mit 3 Spalten: x, y, z)
data = readmatrix('deltarobot_curve3.csv');

data(data(:,1) > 2500 | data(:,2) > 2500 | data(:,3) > 2500, :) = [];
% data(2:2:end, :) = [];

v = [3000 3000 3000];
% Abstand zur Geraden
dist = vecnorm(cross(data, repmat(v,size(data,1),1), 2), 2, 2) / norm(v);
% Projektion auf die Geradenrichtung
t = dot(data, repmat(v,size(data,1),1), 2) / dot(v,v) * 3000;
% Punkte im Bereich der beiden Ebenen
betweenPlanes = (t >= 1000) & (t <= 2000);
% löschen nur wenn beide Bedingungen erfüllt sind
data(dist < 250 & betweenPlanes, :) = [];

% Spalten extrahieren
x = data(:,1);
y = data(:,2);
z = data(:,3);

%------- ALPHASHAPE ------
% AlphaShape mit Alpha = 10 erzeugen
shp = alphaShape(x,y,z);
alpha_crit = criticalAlpha(shp, 'one-region') * 1.5
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

plot3([0 2100], [0 2100], [0 2100], 'r-', 'LineWidth', 2)

view(3)


vektorRichtung = [3000 3000 3000];
vektorRichtung = vektorRichtung / norm(vektorRichtung);

vektorZiel = [0 0 1];

vektorKreuz = cross(vektorRichtung, vektorZiel);

