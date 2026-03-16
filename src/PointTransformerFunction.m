zMax = 3.5241e+03; % Maximalwert aus vorher bestimmter Punktewolke (siehe unten)
%zMax = max(shp_Points_rot(:,3));

rotationMatrix1 = getRotationMatrix1();
rotationMatrix2 = getRotationMatrix2();

pointTransformed = point2PointTrans([2000 2000 2000])


function pointTransformed = point2PointTrans(point)
% Point2PointTrans takes any given "point" in motor angle perspective as in
% [xmotor ymotor zmotor] and returns "point_transformed" which is the motor
% angle transformed into xyz coordinate sytem
    pointTransformed = (rotationMatrix1 * point')';
    pointTransformed = [pointTransformed(1), pointTransformed(2), -pointTransformed(3)+zMax];
    pointTransformed = (rotationMatrix2 * pointTransformed')';
end

function point = pointTrans2Point(point_trans)
    % Reverse transformation
    pointBeforeRot2 = (matrixRotation2' * point_trans')';
    pointBeforeRot2(3) = -(pointBeforeRot2(3) - zMax);
    pointBeforeRot1 = (matrixRotation1' * pointBeforeRot2')';
    point = pointBeforeRot1;
end

function matrixRotation1 = getRotationMatrix1()
    vectorDirection = [1 1 1];
    normed_vectorDirection = vectorDirection / norm(vectorDirection);
    vectorZAxis = [0 0 1];
    vectorRotation = cross(normed_vectorDirection, vectorZAxis);
    normed_vectorRotation = norm(vectorRotation);

    scalarDirectionGoal = dot(normed_vectorDirection, vectorZAxis);
    
    matrixRotation1 = [0                   -vectorRotation(3) vectorRotation(2);
                     vectorRotation(3)    0                  -vectorRotation(1);
                     -vectorRotation(2)   vectorRotation(1)  0];

    matrixRotation1 = eye(3) + matrixRotation1 + matrixRotation1*matrixRotation1*((1 - scalarDirectionGoal)/(normed_vectorRotation^2));
end

function matrixRotation2 = getRotationMatrix2()
    % vectorAngleAdjustment rotates the point around the z axis by its
    % direction and length
    vectorAngleAdjustment = [880 -210 0];
    normed_vectorAngleAdjustment = vectorAngleAdjustment / norm(vectorAngleAdjustment);
    vectorXAxis = [1 0 0];
    
    vectorRotation = cross(normed_vectorAngleAdjustment, vectorXAxis);
    normed_vectorRotation = norm(vectorRotation);
    
    scalarDirectionGoal = dot(normed_vectorAngleAdjustment, vectorXAxis);
    
    matrixRotation2 = [ 0                  -vectorRotation(3) vectorRotation(2);
                       vectorRotation(3)  0                  -vectorRotation(1);
                       -vectorRotation(2) vectorRotation(1)  0];
    
    matrixRotation2 = eye(3) + matrixRotation2 + matrixRotation2*matrixRotation2*((1 - scalarDirectionGoal)/(normed_vectorRotation^2));
end