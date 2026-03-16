classdef PointTransformer
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here

    properties(Constant)
        zMax = 3.5241e+03 % Maximalwert aus vorher bestimmter Punktewolke
        zMaxTrans = 2.2395e+03
    end

    properties
        rotationMatrix1
        rotationMatrix2
    end

    methods
        function obj = PointTransformer()
            % Constructor for PointTransformer class
            obj.rotationMatrix1 = obj.getRotationMatrix1();
            obj.rotationMatrix2 = obj.getRotationMatrix2();
        end

        function pointTransformed = point2PointTrans(obj, point)
        % Point2PointTrans takes any given "point" in motor angle perspective as in
        % [xmotor ymotor zmotor] and returns "point_transformed" which is the motor
        % angle transformed into xyz coordinate sytem
            pointTransformed = (obj.rotationMatrix1 * point')';
            pointTransformed = [pointTransformed(1), pointTransformed(2), -pointTransformed(3)+ obj.zMax];
            pointTransformed = (obj.rotationMatrix2 * pointTransformed')';
        end
        
        function point = pointTrans2Point(obj, point_trans)
            % Reverse transformation
            pointBeforeRot2 = (obj.rotationMatrix2' * point_trans')';
            pointBeforeRot2(3) = -(pointBeforeRot2(3) - obj.zMax);
            pointBeforeRot1 = (obj.rotationMatrix1' * pointBeforeRot2')';
            point = pointBeforeRot1;
        end
    end

    methods (Access = private)
        function rotationMatrix1 = getRotationMatrix1(~)
            vectorDirection = [1 1 1];
            normed_vectorDirection = vectorDirection / norm(vectorDirection);
            vectorZAxis = [0 0 1];
            vectorRotation = cross(normed_vectorDirection, vectorZAxis);
            normed_vectorRotation = norm(vectorRotation);
        
            scalarDirectionGoal = dot(normed_vectorDirection, vectorZAxis);
            
            rotationMatrix1 = [0                   -vectorRotation(3) vectorRotation(2);
                             vectorRotation(3)    0                  -vectorRotation(1);
                             -vectorRotation(2)   vectorRotation(1)  0];
        
            rotationMatrix1 = eye(3) + rotationMatrix1 + rotationMatrix1*rotationMatrix1*((1 - scalarDirectionGoal)/(normed_vectorRotation^2));
        end
        
        function rotationMatrix2 = getRotationMatrix2(~)
            % vectorAngleAdjustment rotates the point around the z axis by its
            % direction and length
            vectorAngleAdjustment = [880 -210 0];
            normed_vectorAngleAdjustment = vectorAngleAdjustment / norm(vectorAngleAdjustment);
            vectorXAxis = [1 0 0];
            
            vectorRotation = cross(normed_vectorAngleAdjustment, vectorXAxis);
            normed_vectorRotation = norm(vectorRotation);
            
            scalarDirectionGoal = dot(normed_vectorAngleAdjustment, vectorXAxis);
            
            rotationMatrix2 = [ 0                  -vectorRotation(3) vectorRotation(2);
                               vectorRotation(3)  0                  -vectorRotation(1);
                               -vectorRotation(2) vectorRotation(1)  0];
            
            rotationMatrix2 = eye(3) + rotationMatrix2 + rotationMatrix2*rotationMatrix2*((1 - scalarDirectionGoal)/(normed_vectorRotation^2));
        end
    end
end