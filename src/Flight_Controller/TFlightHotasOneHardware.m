classdef TFlightHotasOneHardware < handle
    methods
        function obj = TFlightHotasOneHardware()
            folder = fullfile(fileparts(mfilename('fullpath')));  % parent folder containing joystick_hardware
            if count(py.sys.path, folder) == 0
                insert(py.sys.path,int32(0),folder);
            end
            py.importlib.import_module('joystick_hardware.joystick_reader');
        end
        
        function [axes, buttons] = read(obj)
            data = py.joystick_hardware.joystick_reader.read_joystick();
            axes = double(data{1});
            buttons = double(data{2});
        end
    end
end