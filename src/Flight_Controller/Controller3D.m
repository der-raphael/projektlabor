classdef Controller3D < handle
    properties
        hardware
        axes
        buttons
    end
    
    methods
        function obj = Controller3D(hw)
            obj.hardware = hw;
        end
        
        function update(obj)
            [obj.axes, obj.buttons] = obj.hardware.read();
        end
        


        function a = axis_x(obj)
            a = obj.axes(2);
        end
        
        function a = axis_y(obj)
            a = obj.axes(1);
        end
        
        function a = axis_z(obj)
            %a = obj.axes(3);
            a = round((-obj.axes(3) + 1) / 2, 2);
        end

        function a = axis_rotation(obj)
            a = obj.axes(6);
        end

        function a = axis_other(obj)
            a = obj.axes(7);
        end
        
        function b = F1(obj)
            b = obj.buttons(1);
        end

        function b = F2(obj)
            b = obj.buttons(2);
        end

        function b = B1(obj)
            b = obj.buttons(3);
        end

        function b = B2(obj)
            b = obj.buttons(4);
        end

        function b = B3(obj)
            b = obj.buttons(9);
        end

        function b = B4(obj)
            b = obj.buttons(10);
        end

        function b = B5(obj)
            b = obj.buttons(15);
        end

        function b = X(obj)
            b = obj.buttons(5);
        end

        function b = Y(obj)
            b = obj.buttons(8);
        end

        function b = A(obj)
            b = obj.buttons(6);
        end
        
        function b = B(obj)
            b = obj.buttons(7);
        end

        function b = Windows(obj)
            b = obj.buttons(11);
        end

        function b = List(obj)
            b = obj.buttons(12);
        end

        function b = Prev(obj)
            b = obj.buttons(13);
        end

        function b = Next(obj)
            b = obj.buttons(14);
        end
    end
end