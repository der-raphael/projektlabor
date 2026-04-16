addpath(genpath('./Flight_Controller/'))
addpath(genpath('./Motor_Controller/'))

availablePorts = serialportlist();
DEVICENAME          = char(availablePorts(1)); %COM9';       % Check which port is being used on your controller
disp("Using Port " + DEVICENAME + "!");
BAUDRATE            = 57600;
MOTOR_ID1           = 10;
MOTOR_ID2           = 11;
MOTOR_ID3           = 12;

MIN_SPEED = 1;
MAX_SPEED = 6;
SPEED_STEPS = [50, 100, 200, 400, 500, 5000];
ACCELERATION_STEPS = [5, 10, 20, 40, 50, 500];
currentSpeed = 4;

isSpeedButtonPressed = 0;
prevIsSpeedButtonPressed = 2;

prevGoalX = 0;
prevGoalY = 0;
prevGoalZ = 1200;
goalX = 0;
goalY = 0;
goalZ = 1200;
INC_XY = 20;

theta1 = 1200;
theta2 = 1200;
theta3 = 1200;

motorController = MotorController(DEVICENAME, BAUDRATE, MOTOR_ID1, MOTOR_ID2, MOTOR_ID3);
pointTransformer = PointTransformer();

try    
    motorController.enableTorque();
    motorController.setVelocity(SPEED_STEPS(currentSpeed));
    motorController.setAcceleration(ACCELERATION_STEPS(currentSpeed));
    motorController.setGoalCurrent(200);

    controller = Controller3D(TFlightHotasOneHardware());

    while(true)
        controller.update()

        if (controller.B5())
            break;
        end

        % --------------- SPEED CONTROLS ---------------
        speedButtonState = controller.axis_other();
        isSpeedButtonPressed = (speedButtonState > 0.8) - (speedButtonState < -0.8);

        if (isSpeedButtonPressed ~= prevIsSpeedButtonPressed)
            if (isSpeedButtonPressed ~= 0)
                currentSpeed = min(max(currentSpeed + isSpeedButtonPressed, MIN_SPEED), MAX_SPEED);
                motorController.setVelocity(SPEED_STEPS(currentSpeed));
                motorController.setAcceleration(ACCELERATION_STEPS(currentSpeed));
                disp("Set speed to " + currentSpeed);
            end
            
            prevIsSpeedButtonPressed = isSpeedButtonPressed;
        end
        
        dx = -controller.axis_x();
        dy = -controller.axis_y();
        dz = controller.axis_z();

        goalX = goalX + dx * 50;
        goalY = goalY + dy * 50;
        goalZ = dz * PointTransformer.zMaxTrans;

        goalZAdjust = -sqrt(goalX^2 + goalY^2) * 0.5;

        if (controller.F2())
            goalX = 0;
            goalY = 0;
            goalZ = 1200;
        end

        theta = pointTransformer.pointTrans2Point([goalX, goalY, goalZ + goalZAdjust]);
        theta1 = theta(1);
        theta2 = theta(2);
        theta3 = theta(3);

        [p1, p2, p3] = motorController.getCurrentPositions();
        distanceToTarget = (theta1 - p1)^2 + (theta2 - p2)^2 + (theta3 - p3)^2;
        %disp([p1 p2 p3])
        %disp([theta1 theta2 theta3])
        %disp("---")
        %disp(distanceToTarget)

        %disp(theta)
        %[i1, i2, i3] = motorController.getPresentCurrents();
        %disp([i1 i2 i3])

        if (~motorController.writePositions(theta1, theta2, theta3))
            disp("Invalid move: " + theta1 + " " + theta2 + " " + theta3);

            goalX = prevGoalX;
            goalY = prevGoalY;
            goalZ = prevGoalZ;
        else
            prevGoalX = goalX;
            prevGoalY = goalY;
            prevGoalZ = goalZ;
        end
        pause(0.001)
    end

catch ME
    fprintf('Error occurred!\n');
    disp(ME.message);
end

motorController.writePositions(1500, 1500, 1500);
pause(2);

motorController.disableTorque();
motorController.closeConnection();

close all;
clear;