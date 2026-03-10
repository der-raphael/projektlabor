classdef MotorHardware < handle
    %MOTORHARDWARE Summary of this class goes here
    %   Detailed explanation goes here

    properties
        motorID,
        portNum,
        groupreadNum,
        groupwriteNum
    end

    properties(Constant)
        ADDR_PRO_TORQUE_ENABLE      = 64;           % control table address
        PROTOCOL_VERSION            = 2.0;          % comm protocol version
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