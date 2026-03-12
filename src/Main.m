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
        disp(speedButtonState);
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



        motorValue = (2000 - 800) * (1 - controller.axis_z()) + 800;
        motorController.writePositions(motorValue, motorValue, motorValue);

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