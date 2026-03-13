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




%------- ALPHASHAPE 3D Boundary ------
% k = boundary(x, y, z, 0.8);
% TR = triangulation(k, x, y, z);
% 
% p = [1200 1200 1200];
% 
% inside = ~isnan(pointLocation(TR,p));
% 
% if inside
%     disp("Punkt ist erlaubt")
% else
%     disp("Punkt liegt außerhalb")
% end

% trisurf(k, x,y,z)
% axis equal

%------- ALPHASHAPE BOUNDARY FACETS ------
% shp = alphaShape(x,y,z);
% [bf, P] = boundaryFacets(shp);
% 
% trisurf(bf, P(:,1), P(:,2), P(:,3))
% axis equal

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


% LIMIT_MIN = 800;
% LIMIT_MAX = 2000;
% xlim([LIMIT_MIN LIMIT_MAX])
% ylim([LIMIT_MIN LIMIT_MAX])
% zlim([LIMIT_MIN LIMIT_MAX])

view(3)


% ------ CONVEX HULL ----------
% [k1, av1] = convhull(x,y,z);
% trisurf(k1, x, y, z, 'FaceColor', 'red');