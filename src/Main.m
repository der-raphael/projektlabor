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
prevGoalZ = 0;
goalX = 1500;
goalY = 1500;
goalZ = 1500;
INC_XY = 20;

theta1 = 1200;
theta2 = 1200;
theta3 = 1200;
prevTheta1 = 1200;
prevTheta2 = 1200;
prevTheta3 = 1200;

motorController = MotorController(DEVICENAME, BAUDRATE, MOTOR_ID1, MOTOR_ID2, MOTOR_ID3);

try    
    motorController.enableTorque();
    motorController.setVelocity(SPEED_STEPS(currentSpeed));
    motorController.setAcceleration(ACCELERATION_STEPS(currentSpeed));
    
    [p1, p2, p3] = motorController.getCurrentPositions();
    disp([p1 p2 p3])

    controller = Controller3D(TFlightHotasOneHardware());

    while(true)
        controller.update()

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
        
        dy = controller.axis_x();
        dx = controller.axis_y();
        dz = controller.axis_z();

        incXY = INC_XY;
        incZ = 20;

        theta1 = theta1 - dx*incXY + dz*incZ;
        theta2 = theta2 + dx*incXY/2 + dy*incXY + dz*incZ;
        theta3 = theta3 + dx*incXY/2 - dy*incXY + dz*incZ;

        if (controller.F2())
            theta1 = 1500;
            theta2 = 1500;
            theta3 = 1500;
        end

        if (~motorController.writePositions(theta1, theta2, theta3))
            disp("Invalid move: " + theta1 + " " + theta2 + " " + theta3);

            theta1 = prevTheta1;
            theta2 = prevTheta2;
            theta3 = prevTheta3;
        else
            %disp("Valid move: " + theta1 + " " + theta2 + " " + theta3);

            prevTheta1 = theta1;
            prevTheta2 = theta2;
            prevTheta3 = theta3;
        end

        if (controller.B5())
            break;
        end
        pause(0.001)
    end

catch ME
    fprintf('Error occurred!\n');
    disp(ME.message);
end

motorController.writePositions(1800, 1800, 1800);
pause(2);

motorController.disableTorque();
motorController.closeConnection();

close all;
clear;