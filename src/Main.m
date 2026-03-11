addpath(genpath('./Flight_Controller/'))
addpath(genpath('./Motor_Controller/'))

availablePorts = serialportlist();
DEVICENAME          = char(availablePorts(1)); %COM9';       % Check which port is being used on your controller
disp("Using Port " + DEVICENAME + "!");
BAUDRATE            = 57600;
MOTOR_ID1           = 10;
MOTOR_ID2           = 11;
MOTOR_ID3           = 12;


motorController = MotorController(DEVICENAME, BAUDRATE, MOTOR_ID1, MOTOR_ID2, MOTOR_ID3);

try    
    motorController.enableTorque();
    motorController.setVelocity(400);
    motorController.setAcceleration(40);
    
    [p1, p2, p3] = motorController.getCurrentPositions();
    disp([p1 p2 p3])

    controller = Controller3D(TFlightHotasOneHardware());

    while(true)
        controller.update()
        %fprintf('X: %4.3f Y: %4.3f Z: %4.3f\n', controller.axis_x(), controller.axis_y(), controller.axis_z())

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
pause(0.5);

motorController.disableTorque();
motorController.closeConnection();

close all;
clear all;