classdef MotorHardware < handle

    properties
        motorID,            % the ID of the motor this object is tied to
        portNum,            % the Port Number the U2D2 controller is plugged into
        groupHandleRead,    % handle used for reading multiple motors at once
        groupHandleWrite    % handle used for writing to multiple motors at once
    end

    properties(Constant)
        PROTOCOL_VERSION            = 2.0;          % comm protocol version

        ADDR_GOAL_POSITION          = 116;          % address for the goal position
        ADDR_PRESENT_POSITION       = 132;          % address for the present position
        ADDR_TORQUE_ENABLE          = 64;           % address for the torque state
        ADDR_PROFILE_ACCELERATION   = 108;          % address for the velocity
        ADDR_PROFILE_VELOCITY       = 112;          % address for the acceleration

        LEN_GOAL_POSITION           = 4;            % length of the goal position data in byte
        LEN_PRESENT_POSITION        = 4;            % length of the present position data in byte

        TORQUE_ENABLE               = 1;            % Value for enabling the torque
        TORQUE_DISABLE              = 0;            % Value for disabling the torque

        COMM_SUCCESS                = 0;            % Communication Success result value
    end

    methods
        function obj = MotorHardware(motorID, portNum, groupHandleRead, groupHandleWrite)
            % Constructor
            obj.motorID = motorID;
            obj.portNum = portNum;
            obj.groupHandleRead = groupHandleRead;
            obj.groupHandleWrite = groupHandleWrite;

            % Add parameter storage for Dynamixel present position value
            if groupSyncReadAddParam(obj.groupHandleRead, obj.motorID) ~= true
              fprintf('[ID:%03d] groupSyncRead addparam failed', obj.motorID);
            end
        end

        function enableTorque(obj)
            % Enable torque for this motor
            if (obj.setTorqueState(obj.TORQUE_ENABLE))
                fprintf('Dynamixel ID%d has been successfully connected \n', obj.motorID);
            else
                fprintf('Error connecting Dynamixel ID%d\n', obj.motorID);
            end
        end

        function disableTorque(obj)
            % Disable torque for this motor
            if (obj.setTorqueState(obj.TORQUE_DISABLE))
                fprintf('Dynamixel ID%d has been successfully disconnected \n', obj.motorID);
            else
                fprintf('Error disconnecting Dynamixel ID%d\n', obj.motorID);
            end
        end

        function setVelocity(obj, velocity)
            % Set the velocity this motor
            write4ByteTxRx(obj.portNum, obj.PROTOCOL_VERSION, obj.motorID, obj.ADDR_PROFILE_VELOCITY, int32(velocity));
        end

        function setAcceleration(obj, acceleration)
            write4ByteTxRx(obj.portNum, obj.PROTOCOL_VERSION, obj.motorID, obj.ADDR_PROFILE_ACCELERATION, int32(acceleration));
        end

        function setGoalPosition(obj, pos)
            result = groupSyncWriteAddParam(obj.groupHandleWrite, obj.motorID, typecast(int32(pos), 'uint32'), obj.LEN_GOAL_POSITION);
            if result ~= true
                fprintf('[ID:%03d] groupSyncWrite addparam failed', obj.motorID);
                return;
            end
        end

        function pos = getCurrentPosition(obj)
            isAvailable = groupSyncReadIsAvailable( ...
                obj.groupHandleRead, ...
                obj.motorID, ...
                obj.ADDR_PRESENT_POSITION, ...
                obj.LEN_PRESENT_POSITION ...
            );
            if isAvailable ~= true
              fprintf('[ID:%03d] groupSyncRead getdata failed', obj.motorID);
              pos = -1;
              return;
            end

            pos = groupSyncReadGetData( ...
                obj.groupHandleRead, ...
                obj.motorID, ...
                obj.ADDR_PRESENT_POSITION, ...
                obj.LEN_PRESENT_POSITION ...
            );
        end
    end

    methods (Access = private)
        function connected = setTorqueState(obj, torqueState)
            write1ByteTxRx(obj.portNum, obj.PROTOCOL_VERSION, obj.motorID, obj.ADDR_TORQUE_ENABLE, torqueState);
            if getLastTxRxResult(obj.portNum, obj.PROTOCOL_VERSION) ~= obj.COMM_SUCCESS
                printTxRxResult(obj.PROTOCOL_VERSION, getLastTxRxResult(obj.portNum, obj.PROTOCOL_VERSION));
                connected = false;
            elseif getLastRxPacketError(obj.portNum, obj.PROTOCOL_VERSION) ~= 0
                printRxPacketError(obj.PROTOCOL_VERSION, getLastRxPacketError(obj.portNum, obj.PROTOCOL_VERSION));
                connected = false;
            else
                connected = true;
            end
        end
    end
end