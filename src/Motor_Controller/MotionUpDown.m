function MotionUpDown(motorController)
    DXL_MINIMUM_POSITION_VALUE  = 800;
    DXL_MAXIMUM_POSITION_VALUE  = 2000;
    DXL_MOVING_STATUS_THRESHOLD = 50;
    
    goalPos1 = DXL_MAXIMUM_POSITION_VALUE;
    goalPos2 = DXL_MAXIMUM_POSITION_VALUE;
    goalPos3 = DXL_MAXIMUM_POSITION_VALUE;

    delta = 50;

    up = true;
    
    t = 0;

    while 1
        
        motorController.writePositions(goalPos1, goalPos2, goalPos3);
    
        while 1
            [presentPos1, presentPos2, presentPos3] = motorController.getCurrentPositions();
    
            if ~((abs(goalPos1 - typecast(uint32(presentPos1), 'int32')) > DXL_MOVING_STATUS_THRESHOLD) ...
                    || (abs(goalPos2 - typecast(uint32(presentPos2), 'int32')) > DXL_MOVING_STATUS_THRESHOLD) ...
                    || (abs(goalPos3 - typecast(uint32(presentPos3), 'int32')) > DXL_MOVING_STATUS_THRESHOLD))
                break;
            end
        end

        if (up)
            goalPos1 = goalPos1 - delta;
            goalPos2 = goalPos2 - delta;
            goalPos3 = goalPos3 - delta;
            
            if (goalPos1 <= DXL_MINIMUM_POSITION_VALUE)
                up = false;
            end
        else
            goalPos1 = goalPos1 + delta;
            goalPos2 = goalPos2 + delta;
            goalPos3 = goalPos3 + delta;

            if (goalPos1 >= DXL_MAXIMUM_POSITION_VALUE)
                up = true;
            end
        end

        pause(0.05);

        t = t + 1;
        if (t > 100)
            disp("Done!")
            break;
        end
    end
end