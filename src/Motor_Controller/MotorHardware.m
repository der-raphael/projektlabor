classdef MotorHardware < handle

    properties
        motorID,
        portNum,
        groupreadNum,
        groupwriteNum
    end

    properties(Constant)
        PROTOCOL_VERSION            = 2.0;          % comm protocol version
        ADDR_PRO_GOAL_POSITION      = 116;
        ADDR_PRO_PRESENT_POSITION   = 132;
        ADDR_PRO_TORQUE_ENABLE      = 64;           % control table address
        ADDR_PRO_PROFILE_ACCELERATION = 108;
        ADDR_PRO_PROFILE_VELOCITY     = 112;
        LEN_PRO_GOAL_POSITION       = 4;
        LEN_PRO_PRESENT_POSITION    = 4;
        TORQUE_ENABLE               = 1;            % Value for enabling the torque
        TORQUE_DISABLE              = 0;            % Value for disabling the torque
        COMM_SUCCESS                = 0;            % Communication Success result value
    end

    methods
        function obj = MotorHardware(motorID, portNum, groupreadNum, groupwriteNum)
            obj.motorID = motorID;
            obj.portNum = portNum;
            obj.groupreadNum = groupreadNum;
            obj.groupwriteNum = groupwriteNum;

            % Add parameter storage for Dynamixel present position value
            dxl_addparam_result = groupSyncReadAddParam(obj.groupreadNum, obj.motorID);
            if dxl_addparam_result ~= true
              fprintf('[ID:%03d] groupSyncRead addparam failed', obj.motorID);
            end
        end

        function enableTorque(obj)
            if (obj.setTorqueState(obj.TORQUE_ENABLE))
                fprintf('Dynamixel ID%d has been successfully connected \n', obj.motorID);
            else
                fprintf('Error connecting Dynamixel ID%d\n', obj.motorID);
            end
        end

        function disableTorque(obj)
            if (obj.setTorqueState(obj.TORQUE_DISABLE))
                fprintf('Dynamixel ID%d has been successfully disconnected \n', obj.motorID);
            else
                fprintf('Error disconnecting Dynamixel ID%d\n', obj.motorID);
            end
        end

        function setVelocity(obj, velocity)
            write4ByteTxRx(obj.portNum, obj.PROTOCOL_VERSION, obj.motorID, obj.ADDR_PRO_PROFILE_VELOCITY, int32(velocity));
        end

        function setAcceleration(obj, acceleration)
            write4ByteTxRx(obj.portNum, obj.PROTOCOL_VERSION, obj.motorID, obj.ADDR_PRO_PROFILE_ACCELERATION, int32(acceleration));
        end

        function setGoalPosition(obj, pos)
            result = groupSyncWriteAddParam(obj.groupwriteNum, obj.motorID, typecast(int32(pos), 'uint32'), obj.LEN_PRO_GOAL_POSITION);
            if result ~= true
                fprintf('[ID:%03d] groupSyncWrite addparam failed', obj.motorID);
                return;
            end
        end

        function pos = getCurrentPosition(obj)
            isAvailable = groupSyncReadIsAvailable( ...
                obj.groupreadNum, ...
                obj.motorID, ...
                obj.ADDR_PRO_PRESENT_POSITION, ...
                obj.LEN_PRO_PRESENT_POSITION ...
            );
            if isAvailable ~= true
              fprintf('[ID:%03d] groupSyncRead getdata failed', obj.motorID);
              pos = -1;
              return;
            end

            pos = groupSyncReadGetData( ...
                obj.groupreadNum, ...
                obj.motorID, ...
                obj.ADDR_PRO_PRESENT_POSITION, ...
                obj.LEN_PRO_PRESENT_POSITION ...
            );
        end
    end

    methods (Access = private)
        function connected = setTorqueState(obj, torqueState)
            % Enable Dynamixel Torque
            write1ByteTxRx(obj.portNum, obj.PROTOCOL_VERSION, obj.motorID, obj.ADDR_PRO_TORQUE_ENABLE, torqueState);
            if getLastTxRxResult(obj.portNum, obj.PROTOCOL_VERSION) ~= obj.COMM_SUCCESS
                %printTxRxResult(PROTOCOL_VERSION, getLastTxRxResult(port_num, PROTOCOL_VERSION));
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