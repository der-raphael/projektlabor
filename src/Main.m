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
MAX_SPEED = 5;
SPEED_STEPS = [50, 100, 200, 400, 500];
ACCELERATION_STEPS = [5, 10, 20, 40, 50];
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

        speedButtonState = controller.axis_other();
        if (speedButtonState < -0.8)
            isSpeedButtonPressed = -1;
        elseif (speedButtonState > 0.8)
            isSpeedButtonPressed = 1;
        else
            isSpeedButtonPressed = 0;
        end

        if (isSpeedButtonPressed ~= prevIsSpeedButtonPressed)
            if (isSpeedButtonPressed == 1)
                currentSpeed = min(currentSpeed + 1, MAX_SPEED);
            elseif (isSpeedButtonPressed == -1)
                currentSpeed = max(currentSpeed - 1, MIN_SPEED);
            end
            motorController.setVelocity(SPEED_STEPS(currentSpeed));
            motorController.setAcceleration(ACCELERATION_STEPS(currentSpeed));
            prevIsSpeedButtonPressed = isSpeedButtonPressed;
            disp("Current speed: " + currentSpeed);
        end
        
        dx = controller.axis_x();
        dy = controller.axis_y();
        dz = (controller.axis_z());

        incXY = INC_XY;
        incZ = 20;

        theta1 = theta1 + dx*incXY + dz*incZ;
        theta2 = theta2 - dx*incXY/2 + dy*incXY + dz*incZ;
        theta3 = theta3 - dx*incXY/2 - dy*incXY + dz*incZ;

        if (controller.F2())
            theta1 = 1500;
            theta2 = 1500;
            theta3 = 1500;
        end

        if (~motorController.writePositions(theta1, theta2, theta3))
            theta1 = prevTheta1;
            theta2 = prevTheta2;
            theta3 = prevTheta3;
        else
            prevTheta1 = theta1;
            prevTheta2 = theta2;
            prevTheta3 = theta3;
        end

        if (controller.B5())
            break;
        end
        pause(0.02)
    end
    
    %{
    input('Press ENTER to continue...\n');
    
    motorController.writePositions(1650, 1650, 1650);
    input('Press ENTER to continue...\n');
    
    motorController.writePositions(-1, -1, 1250);
    input('Press ENTER to continue...\n');
    
    motorController.writePositions(-1, 1250, -1);
    input('Press ENTER to continue...\n');
    
    motorController.writePositions(1250, -1, -1);
    input('Press ENTER to continue...\n');

    MotionCircle(motorController);
    MotionUpDown(motorController);
    %}

catch ME
    fprintf('Error occurred!\n');
    disp(ME.message);
end

motorController.writePositions(1800, 1800, 1800);
pause(2);

motorController.disableTorque();
motorController.closeConnection();

close all;
clear all;