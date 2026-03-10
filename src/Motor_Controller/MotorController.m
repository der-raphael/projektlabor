classdef MotorController < handle
    properties
        DEVICENAME
        BAUDRATE
        lib_name = ''
        portNum
        motor1
        motor2
        motor3
        motorsMap
    end

    methods
        function obj = MotorController(DEVICENAME, BAUDRATE, ID1, ID2, ID3)
            obj.DEVICENAME = DEVICENAME;
            obj.BAUDRATE = BAUDRATE;

            addpath('./dynamixel_library');

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
                [~, ~] = loadlibrary( ...
                    lib_name, 'dynamixel_sdk.h',...
                    'addheader', './dynamixel_library/port_handler.h', ...
                    'addheader', './dynamixel_library/packet_handler.h', ...
                    'addheader', './dynamixel_library/group_sync_write.h', ...
                    'addheader', './dynamixel_library/group_sync_read.h' ...
                );
                disp("Loaded libs!")
            end

            obj.lib_name = lib_name;

            obj.portNum = portHandler(DEVICENAME);

            % Initialize PacketHandler Structs
            packetHandler();
            
            % Initialize Groupsyncwrite Structs
            groupwrite_num = groupSyncWrite(obj.portNum, 2.0, 116, 4);
            
            % Initialize Groupsyncread Structs for Present Position
            groupread_num = groupSyncRead(obj.portNum, 2.0, 132, 4);

            obj.openPort()
            obj.setBaudrate()

            obj.motor1 = MotorHardware(ID1, obj.portNum, groupread_num, groupwrite_num);
            obj.motor2 = MotorHardware(ID2, obj.portNum, groupread_num, groupwrite_num);
            obj.motor3 = MotorHardware(ID3, obj.portNum, groupread_num, groupwrite_num);

            % Create the map: keys are motor IDs, values are motor objects
            keys = [obj.motor1.motorID, obj.motor2.motorID, obj.motor3.motorID];
            values = {obj.motor1, obj.motor2, obj.motor3};
            obj.motorsMap = containers.Map(keys, values);
        end

        function enableTorque(obj, motorID)
            motor = obj.motorsMap(motorID);
            motor.enableTorque();
        end

        function disableTorque(obj, motorID)
            motor = obj.motorsMap(motorID);
            motor.disableTorque();
        end

        function closeConnection(obj)
            closePort(obj.portNum);
            unloadlibrary(obj.lib_name);
        end
    end

    methods (Access = private)
        function openPort(obj)
            if (openPort(obj.portNum))
                fprintf('Succeeded to open the port!\n');
            else
                unloadlibrary(obj.lib_name);
                fprintf('Failed to open the port!\n');
                input('Press any key to terminate...\n');
                return;
            end
        end

        function setBaudrate(obj)
            if (setBaudRate(obj.portNum, obj.BAUDRATE))
                fprintf('Succeeded to change the baudrate!\n');
            else
                unloadlibrary(obj.lib_name);
                fprintf('Failed to change the baudrate!\n');
                input('Press any key to terminate...\n');
                return;
            end
        end
    end
end