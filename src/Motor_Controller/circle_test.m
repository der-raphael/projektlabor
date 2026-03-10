% circle_test.m
%
% Author: Raphael Klumpp & Marvin Rüdele
%
% First tests using Dynamixel Motors on a delta robot. This program 
% currently draws a circle using all three motors of the Delta robot.

addpath(genpath('./dynamixel_library/'))
clc;
clear all;

lib_name = '';

if strcmp(computer, 'PCWIN')
  lib_name = 'dxl_x86_c';
elseif strcmp(computer, 'PCWIN64')
  lib_name = 'dxl_x64_c';
elseif strcmp(computer, 'GLNX86')
  lib_name = 'libdxl_x86_c';
elseif strcmp(computer, 'GLNXA64')
  lib_name = 'libdxl_x64_c';
elseif strcmp(computer, 'MACI64')
  lib_name = 'libdxl_mac_c';
end

% Load Libraries
if ~libisloaded(lib_name)
    [notfound, warnings] = loadlibrary( ...
        lib_name, 'dynamixel_sdk.h', ...
        'addheader', 'port_handler.h', ...
        'addheader', 'packet_handler.h', ...
        'addheader', 'group_sync_write.h', ...
        'addheader', 'group_sync_read.h' ...
    );
end

% Control table address
ADDR_PRO_TORQUE_ENABLE          = 64;                 % Control table address is different in Dynamixel model
ADDR_PRO_GOAL_POSITION          = 116;
ADDR_PRO_PRESENT_POSITION       = 132;

% Data Byte Length
LEN_PRO_GOAL_POSITION       = 4;
LEN_PRO_PRESENT_POSITION    = 4;

% Protocol version
PROTOCOL_VERSION            = 2.0;          % See which protocol version is used in the Dynamixel

% Default setting
DXL1_ID                     = 10;            % Dynamixel#1 ID: 10
DXL2_ID                     = 11;            % Dynamixel#2 ID: 11
DXL3_ID                     = 12;
BAUDRATE                    = 57600;
DEVICENAME                  = 'COM9';       % Check which port is being used on your controller
                                            % ex) Windows: "COM1"   Linux: "/dev/ttyUSB0"

TORQUE_ENABLE               = 1;            % Value for enabling the torque
TORQUE_DISABLE              = 0;            % Value for disabling the torque
DXL_MINIMUM_POSITION_VALUE  = 1100;         % Dynamixel will rotate between this value
DXL_MAXIMUM_POSITION_VALUE  = 2200;         % and this value (note that the Dynamixel would not move when the position value is out of movable range. Check e-manual about the range of the Dynamixel you use.)
DXL_MOVING_STATUS_THRESHOLD = 20;           % Dynamixel moving status threshold

ESC_CHARACTER               = 'e';          % Key for escaping loop

COMM_SUCCESS                = 0;            % Communication Success result value
COMM_TX_FAIL                = -1001;        % Communication Tx Failed

% Initialize PortHandler Structs
% Set the port path
% Get methods and members of PortHandlerLinux or PortHandlerWindows
port_num = portHandler(DEVICENAME);
closePort(port_num);

% Initialize PacketHandler Structs
packetHandler();

% Initialize Groupsyncwrite Structs
groupwrite_num = groupSyncWrite(port_num, PROTOCOL_VERSION, ADDR_PRO_GOAL_POSITION, LEN_PRO_GOAL_POSITION);

% Initialize Groupsyncread Structs for Present Position
groupread_num = groupSyncRead(port_num, PROTOCOL_VERSION, ADDR_PRO_PRESENT_POSITION, LEN_PRO_PRESENT_POSITION);

index = 1;
dxl_comm_result = COMM_TX_FAIL;           % Communication result
dxl_addparam_result = false;              % AddParam result
dxl_getdata_result = false;               % GetParam result

dxl1_goal_position = 1650;                % starting position motor 1
dxl2_goal_position = 1650;                % starting position motor 2
dxl3_goal_position = 1650;                % starting position motor 3
center = (DXL_MINIMUM_POSITION_VALUE + DXL_MAXIMUM_POSITION_VALUE) / 2;
amplitude = (DXL_MAXIMUM_POSITION_VALUE - DXL_MINIMUM_POSITION_VALUE) / 6;

omega = 0.05; % Schrittweite pro Loop
t = 0;

dxl_error = 0;                              % Dynamixel error
dxl1_present_position = 0;                  % Present position
dxl2_present_position = 0;
dxl3_present_position = 0;


% Open port
if (openPort(port_num))
    fprintf('Succeeded to open the port!\n');
else
    unloadlibrary(lib_name);
    fprintf('Failed to open the port!\n');
    input('Press any key to terminate...\n');
    return;
end


% Set port baudrate
if (setBaudRate(port_num, BAUDRATE))
    fprintf('Succeeded to change the baudrate!\n');
else
    unloadlibrary(lib_name);
    fprintf('Failed to change the baudrate!\n');
    input('Press any key to terminate...\n');
    return;
end


% Enable Dynamixel#1 Torque
write1ByteTxRx(port_num, PROTOCOL_VERSION, DXL1_ID, ADDR_PRO_TORQUE_ENABLE, TORQUE_ENABLE);
if getLastTxRxResult(port_num, PROTOCOL_VERSION) ~= COMM_SUCCESS
    %printTxRxResult(PROTOCOL_VERSION, getLastTxRxResult(port_num, PROTOCOL_VERSION));
elseif getLastRxPacketError(port_num, PROTOCOL_VERSION) ~= 0
    printRxPacketError(PROTOCOL_VERSION, getLastRxPacketError(port_num, PROTOCOL_VERSION));
else
    fprintf('Dynamixel #%d has been successfully connected \n', DXL1_ID);
end

% Enable Dynamixel#2 Torque
write1ByteTxRx(port_num, PROTOCOL_VERSION, DXL2_ID, ADDR_PRO_TORQUE_ENABLE, TORQUE_ENABLE);
if getLastTxRxResult(port_num, PROTOCOL_VERSION) ~= COMM_SUCCESS
    %printTxRxResult(PROTOCOL_VERSION, getLastTxRxResult(port_num, PROTOCOL_VERSION));
elseif getLastRxPacketError(port_num, PROTOCOL_VERSION) ~= 0
    printRxPacketError(PROTOCOL_VERSION, getLastRxPacketError(port_num, PROTOCOL_VERSION));
else
    fprintf('Dynamixel #%d has been successfully connected \n', DXL2_ID);
end

% Enable Dynamixel#3 Torque
write1ByteTxRx(port_num, PROTOCOL_VERSION, DXL3_ID, ADDR_PRO_TORQUE_ENABLE, TORQUE_ENABLE);
if getLastTxRxResult(port_num, PROTOCOL_VERSION) ~= COMM_SUCCESS
    %printTxRxResult(PROTOCOL_VERSION, getLastTxRxResult(port_num, PROTOCOL_VERSION));
elseif getLastRxPacketError(port_num, PROTOCOL_VERSION) ~= 0
    printRxPacketError(PROTOCOL_VERSION, getLastRxPacketError(port_num, PROTOCOL_VERSION));
else
    fprintf('Dynamixel #%d has been successfully connected \n', DXL3_ID);
end

% Add parameter storage for Dynamixel#1 present position value
dxl_addparam_result = groupSyncReadAddParam(groupread_num, DXL1_ID);
if dxl_addparam_result ~= true
  fprintf('[ID:%03d] groupSyncRead addparam failed', DXL1_ID);
  return;
end

% Add parameter storage for Dynamixel#2 present position value
dxl_addparam_result = groupSyncReadAddParam(groupread_num, DXL2_ID);
if dxl_addparam_result ~= true
  fprintf('[ID:%03d] groupSyncRead addparam failed', DXL2_ID);
  return;
end

% Add parameter storage for Dynamixel#3 present position value
dxl_addparam_result = groupSyncReadAddParam(groupread_num, DXL3_ID);
if dxl_addparam_result ~= true
  fprintf('[ID:%03d] groupSyncRead addparam failed', DXL3_ID);
  return;
end


try
    while 1
        % if input('Press any key to continue! (or input e to quit!)\n', 's') == ESC_CHARACTER
        %     break;
        % end
    
        % Add Dynamixel#1 goal position value to the Syncwrite storage
        dxl_addparam_result = groupSyncWriteAddParam(groupwrite_num, DXL1_ID, typecast(int32(dxl1_goal_position), 'uint32'), LEN_PRO_GOAL_POSITION);
        if dxl_addparam_result ~= true
            fprintf('[ID:%03d] groupSyncWrite addparam failed', DXL1_ID);
            return;
        end
    
        % Add Dynamixel#2 goal position value to the Syncwrite parameter storage
        dxl_addparam_result = groupSyncWriteAddParam(groupwrite_num, DXL2_ID, typecast(int32(dxl2_goal_position), 'uint32'), LEN_PRO_GOAL_POSITION);
        if dxl_addparam_result ~= true
            fprintf('[ID:%03d] groupSyncWrite addparam failed', DXL2_ID);
            return;
        end
    
        % Add Dynamixel#3 goal position value to the Syncwrite parameter storage
        dxl_addparam_result = groupSyncWriteAddParam(groupwrite_num, DXL3_ID, typecast(int32(dxl3_goal_position), 'uint32'), LEN_PRO_GOAL_POSITION);
        if dxl_addparam_result ~= true
            fprintf('[ID:%03d] groupSyncWrite addparam failed', DXL3_ID);
            return;
        end
    
        % Syncwrite goal position
        groupSyncWriteTxPacket(groupwrite_num);
        % if getLastTxRxResult(port_num, PROTOCOL_VERSION) ~= COMM_SUCCESS
        %     printTxRxResult(PROTOCOL_VERSION, getLastTxRxResult(port_num, PROTOCOL_VERSION));
        % end
    
        % Clear syncwrite parameter storage
        groupSyncWriteClearParam(groupwrite_num);
    
        while 1
            % Syncread present position
            groupSyncReadTxRxPacket(groupread_num);
            if getLastTxRxResult(port_num, PROTOCOL_VERSION) ~= COMM_SUCCESS
                %printTxRxResult(PROTOCOL_VERSION, getLastTxRxResult(port_num, PROTOCOL_VERSION));
            end
    
            dxl_comm_result = getLastTxRxResult(port_num, PROTOCOL_VERSION);
    
            if dxl_comm_result ~= COMM_SUCCESS
                fprintf('%s\n', getTxRxResult(PROTOCOL_VERSION, dxl_comm_result));
            end
    
            % Check if groupsyncread data of Dynamixel#1 is available
            dxl_getdata_result = groupSyncReadIsAvailable(groupread_num, DXL1_ID, ADDR_PRO_PRESENT_POSITION, LEN_PRO_PRESENT_POSITION);
            if dxl_getdata_result ~= true
              fprintf('[ID:%03d] groupSyncRead getdata failed', DXL1_ID);
              return;
            end
    
            % Check if groupsyncread data of Dynamixel#2 is available
            dxl_getdata_result = groupSyncReadIsAvailable(groupread_num, DXL2_ID, ADDR_PRO_PRESENT_POSITION, LEN_PRO_PRESENT_POSITION);
            if dxl_getdata_result ~= true
              fprintf('[ID:%03d] groupSyncRead getdata failed', DXL2_ID);
              return;
            end
    
            % Check if groupsyncread data of Dynamixel#2 is available
            dxl_getdata_result = groupSyncReadIsAvailable(groupread_num, DXL3_ID, ADDR_PRO_PRESENT_POSITION, LEN_PRO_PRESENT_POSITION);
            if dxl_getdata_result ~= true
              fprintf('[ID:%03d] groupSyncRead getdata failed', DXL3_ID);
              return;
            end
    
            % Get Dynamixel#1 present position value
            dxl1_present_position = groupSyncReadGetData(groupread_num, DXL1_ID, ADDR_PRO_PRESENT_POSITION, LEN_PRO_PRESENT_POSITION);
    
            % Get Dynamixel#2 present position value
            dxl2_present_position = groupSyncReadGetData(groupread_num, DXL2_ID, ADDR_PRO_PRESENT_POSITION, LEN_PRO_PRESENT_POSITION);
    
            % Get Dynamixel#3 present position value
            dxl3_present_position = groupSyncReadGetData(groupread_num, DXL3_ID, ADDR_PRO_PRESENT_POSITION, LEN_PRO_PRESENT_POSITION);
    
    
            if ~((abs(dxl1_goal_position - typecast(uint32(dxl1_present_position), 'int32')) > DXL_MOVING_STATUS_THRESHOLD) ...
                    || (abs(dxl2_goal_position - typecast(uint32(dxl2_present_position), 'int32')) > DXL_MOVING_STATUS_THRESHOLD) ...
                    || (abs(dxl3_goal_position - typecast(uint32(dxl3_present_position), 'int32')) > DXL_MOVING_STATUS_THRESHOLD))
                break;
            end
        end
        angle = omega * t;
        dxl1_goal_position = center + amplitude * sin(angle);
        dxl2_goal_position = center + amplitude * sin(angle + 2*pi/3);
        dxl3_goal_position = center + amplitude * sin(angle + 4*pi/3);
        t = t + 1;
        if (t > 500)
            disp("Done!")
            break;
        end
    end

catch ME
    fprintf('Error occurred!\n');
    disp(ME.message);
end


% Disable Dynamixel#1 Torque
write1ByteTxRx(port_num, PROTOCOL_VERSION, DXL1_ID, ADDR_PRO_TORQUE_ENABLE, TORQUE_DISABLE);
if getLastTxRxResult(port_num, PROTOCOL_VERSION) ~= COMM_SUCCESS
    printTxRxResult(PROTOCOL_VERSION, getLastTxRxResult(port_num, PROTOCOL_VERSION));
elseif getLastRxPacketError(port_num, PROTOCOL_VERSION) ~= 0
    printRxPacketError(PROTOCOL_VERSION, getLastRxPacketError(port_num, PROTOCOL_VERSION));
end

% Disable Dynamixel#2 Torque
write1ByteTxRx(port_num, PROTOCOL_VERSION, DXL2_ID, ADDR_PRO_TORQUE_ENABLE, TORQUE_DISABLE);
if getLastTxRxResult(port_num, PROTOCOL_VERSION) ~= COMM_SUCCESS
    printTxRxResult(PROTOCOL_VERSION, getLastTxRxResult(port_num, PROTOCOL_VERSION));
elseif getLastRxPacketError(port_num, PROTOCOL_VERSION) ~= 0
    printRxPacketError(PROTOCOL_VERSION, getLastRxPacketError(port_num, PROTOCOL_VERSION));
end

% Disable Dynamixel#3 Torque
write1ByteTxRx(port_num, PROTOCOL_VERSION, DXL3_ID, ADDR_PRO_TORQUE_ENABLE, TORQUE_DISABLE);
if getLastTxRxResult(port_num, PROTOCOL_VERSION) ~= COMM_SUCCESS
    printTxRxResult(PROTOCOL_VERSION, getLastTxRxResult(port_num, PROTOCOL_VERSION));
elseif getLastRxPacketError(port_num, PROTOCOL_VERSION) ~= 0
    printRxPacketError(PROTOCOL_VERSION, getLastRxPacketError(port_num, PROTOCOL_VERSION));
end

% Close port
closePort(port_num);

% Unload Library
unloadlibrary(lib_name);

close all;
clear all;