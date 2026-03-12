function MotionCircle(motorController)
    DXL_MINIMUM_POSITION_VALUE  = 800;
    DXL_MAXIMUM_POSITION_VALUE  = 2000;

    center = (DXL_MINIMUM_POSITION_VALUE + DXL_MAXIMUM_POSITION_VALUE) / 2;
    amplitude = (DXL_MAXIMUM_POSITION_VALUE - DXL_MINIMUM_POSITION_VALUE) / 6;
    
    omega = 0.05;
    t = 0;

    goalPos1 = 1650;
    goalPos2 = 1650;
    goalPos3 = 1650;


    while 1
        motorController.writePositions(goalPos1, goalPos2, goalPos3);

        angle = omega * t;
        goalPos1 = center + amplitude * sin(angle);
        goalPos2 = center + amplitude * sin(angle + 2*pi/3);
        goalPos3 = center + amplitude * sin(angle + 4*pi/3);

        pause(0.05);
        t = t + 1;
        if (t > 100)
            disp("Done!")
            break;
        end
    end
end