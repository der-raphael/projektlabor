addpath(genpath('./Flight_Controller/'))
addpath(genpath('./Motor_Controller/'))
lib_folder = './Motor_Controller/dynamixel_library';
addpath(lib_folder);

DEVICENAME          = 'COM9';       % Check which port is being used on your controller
BAUDRATE            = 57600;
MOTOR_ID1           = 10;
MOTOR_ID2           = 11;
MOTOR_ID3           = 12;

motorController = MotorController(DEVICENAME, BAUDRATE, MOTOR_ID1, MOTOR_ID2, MOTOR_ID3);

motorController.enableTorque(MOTOR_ID1);

input('Press ENTER to continue...\n');

motorController.enableTorque(MOTOR_ID2);

input('Press ENTER to continue...\n');

motorController.enableTorque(MOTOR_ID3);

input('Press ENTER to continue...\n');

motorController.disableTorque(MOTOR_ID1);

input('Press ENTER to continue...\n');

motorController.disableTorque(MOTOR_ID2);

input('Press ENTER to continue...\n');

motorController.disableTorque(MOTOR_ID3);

motorController.closeConnection();

close all;
clear all;

%{
controller = Controller3D(TFlightHotasOneHardware());

while(true)
    controller.update()
    disp("F1: " + controller.F1())
    fprintf('X: %4.3f Y: %4.3f Z: %4.3f\n', controller.axis_x(), controller.axis_y(), controller.axis_z())
    pause(0.02)
end
%}