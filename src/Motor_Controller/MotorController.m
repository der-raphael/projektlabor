classdef MotorController < handle
    properties
        DEVICENAME
        BAUDRATE
        lib_name
        portNum
        groupWriteNum
        groupReadNum
        motor1
        motor2
        motor3
        motorsMap
    end

    methods
        function obj = MotorController(DEVICENAME, BAUDRATE, ID1, ID2, ID3)
            obj.DEVICENAME = DEVICENAME;
            obj.BAUDRATE = BAUDRATE;


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
            obj.groupWriteNum = groupSyncWrite( ...
                obj.portNum, ...
                MotorHardware.PROTOCOL_VERSION, ...
                MotorHardware.ADDR_PRO_GOAL_POSITION, ...
                MotorHardware.LEN_PRO_GOAL_POSITION ...
            );
            
            % Initialize Groupsyncread Structs for Present Position
            obj.groupReadNum = groupSyncRead( ...
                obj.portNum, ...
                MotorHardware.PROTOCOL_VERSION, ...
                MotorHardware.ADDR_PRO_PRESENT_POSITION, ...
                MotorHardware.LEN_PRO_PRESENT_POSITION ...
            );

            obj.openPort()
            obj.setBaudrate()

            obj.motor1 = MotorHardware(ID1, obj.portNum, obj.groupReadNum, obj.groupWriteNum);
            obj.motor2 = MotorHardware(ID2, obj.portNum, obj.groupReadNum, obj.groupWriteNum);
            obj.motor3 = MotorHardware(ID3, obj.portNum, obj.groupReadNum, obj.groupWriteNum);

            % Create the map: keys are motor IDs, values are motor objects
            keys = [obj.motor1.motorID, obj.motor2.motorID, obj.motor3.motorID];
            values = {obj.motor1, obj.motor2, obj.motor3};
            obj.motorsMap = containers.Map(keys, values);
        end

        function enableTorque(obj, motorID)
            if (nargin == 2)
                motor = obj.motorsMap(motorID);
                motor.enableTorque();
            else
                obj.motor1.enableTorque();
                obj.motor2.enableTorque();
                obj.motor3.enableTorque();
            end
        end

        function disableTorque(obj, motorID)
            if (nargin == 2)
                motor = obj.motorsMap(motorID);
                motor.disableTorque();
            else
                obj.motor1.disableTorque();
                obj.motor2.disableTorque();
                obj.motor3.disableTorque();
            end
        end

        function setVelocity(obj, velocity, motorID)
            if (nargin == 3)
                motor = obj.motorsMap(motorID);
                motor.setVelocity(velocity);
            else
                obj.motor1.setVelocity(velocity)
                obj.motor2.setVelocity(velocity)
                obj.motor3.setVelocity(velocity);
            end
        end

        function setAcceleration(obj, acceleration, motorID)
            if (nargin == 3)
                motor = obj.motorsMap(motorID);
                motor.setAcceleration(acceleration);
            else
                obj.motor1.setAcceleration(acceleration);
                obj.motor2.setAcceleration(acceleration);
                obj.motor3.setAcceleration(acceleration);
            end
        end

        function closeConnection(obj)
            closePort(obj.portNum);
            unloadlibrary(obj.lib_name);
        end

        function [pos1, pos2, pos3] = getCurrentPositions(obj)
            % Syncread present position
            groupSyncReadTxRxPacket(obj.groupReadNum);
            if getLastTxRxResult(obj.portNum, MotorHardware.PROTOCOL_VERSION) ~= MotorHardware.COMM_SUCCESS
                printTxRxResult(MotorHardware.PROTOCOL_VERSION, getLastTxRxResult(obj.portNum, MotorHardware.PROTOCOL_VERSION));
            end
    
            result = getLastTxRxResult(obj.portNum, MotorHardware.PROTOCOL_VERSION);
            if result ~= MotorHardware.COMM_SUCCESS
                fprintf('%s\n', getTxRxResult(MotorHardware.PROTOCOL_VERSION, result));
            end

            pos1 = obj.motor1.getCurrentPosition();
            pos2 = obj.motor2.getCurrentPosition();
            pos3 = obj.motor3.getCurrentPosition();
        end

        function writePositions(obj, pos1, pos2, pos3)
            if (pos1 > 0); obj.motor1.setGoalPosition(pos1); end
            if (pos2 > 0); obj.motor2.setGoalPosition(pos2); end
            if (pos3 > 0); obj.motor3.setGoalPosition(pos3); end

             % Syncwrite goal position
            groupSyncWriteTxPacket(obj.groupWriteNum);
            % if getLastTxRxResult(port_num, PROTOCOL_VERSION) ~= COMM_SUCCESS
            %     printTxRxResult(PROTOCOL_VERSION, getLastTxRxResult(port_num, PROTOCOL_VERSION));
            % end
        
            % Clear syncwrite parameter storage
            groupSyncWriteClearParam(obj.groupWriteNum);
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