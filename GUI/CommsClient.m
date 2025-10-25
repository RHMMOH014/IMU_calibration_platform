classdef CommsClient < handle
    
    properties
        Port string = ""
        Baud double = 115200
        SerialObj           
        LineBuffer string = ""  
        IsConnected logical = false

        
        OnTelemetry = []
        OnEvent = []
        OnReply = []

        
        TelemetryLog 
    end

    methods
        function obj = CommsClient()
            obj.TelemetryLog = table([],[],[],[],'VariableNames', {'t','ax','ay','az'});
        end

        function connect(obj, port, baud)
            if obj.IsConnected
                obj.disconnect();
            end

        
            obj.Port = port;
            obj.Baud = baud;
            obj.SerialObj = serialport(port, baud);
            configureTerminator(obj.SerialObj, "LF");
            flush(obj.SerialObj);
            obj.IsConnected = true;
            obj.LineBuffer = "";
        
            configureCallback(obj.SerialObj,"terminator", ...
                @(src,~)obj.onLineReceived(readline(src)));
        end

        function disconnect(obj)
          
            if obj.IsConnected
                try
                    configureCallback(obj.SerialObj,"off");
                    flush(obj.SerialObj);
                    delete(obj.SerialObj);
                    clear obj.SerialObj
                catch err
                    warning(err.identifier, "Error during disconnect: %s", err.message);
                    
                end
                obj.IsConnected = false;
                
            end
        end

        function send(obj, line)
    
            if obj.IsConnected
                writeline(obj.SerialObj, line);
            else
                warning("Not connected");
            end
        end

   
        function onLineReceived(obj, line)
            line = strtrim(line);
            if startsWith(line, "T,")
                obj.handleTelemetry(line);
            elseif startsWith(line, "EVT")
                obj.handleEvent(line);
            else
                obj.handleReply(line);
            end
        end

     
        function handleTelemetry(obj, line)
            parts = split(line, ",");
            if numel(parts) < 5
                warning("Invalid telemetry line: %s", line); 
                return;
            end

            
            t  = str2double(parts{2});
            ax = str2double(parts{3});
            ay = str2double(parts{4});
            az = str2double(parts{5});

           
            newRow = {t, ax, ay, az};
            obj.TelemetryLog(end+1,:) = newRow;

            
            if ~isempty(obj.OnTelemetry)
                data = struct('t',t,'ax',ax,'ay',ay,'az',az);
                obj.OnTelemetry(data);
            end
        end

       
        function handleEvent(obj, line)
     
            evt = strtrim(extractAfter(line, "EVT"));
            data = struct('type', strtrim(evt));
            if ~isempty(obj.OnEvent)
                obj.OnEvent(data);
            else
                fprintf("[EVENT] %s\n", data.type);
            end
        end

    
        function handleReply(obj, line)
           
            if strcmpi(line, "PONG")
                data = struct('type', 'PONG');
            elseif contains(line, "yaw=")
                val = sscanf(line, "yaw=%f");
                data = struct('type', 'yaw', 'value', val);
            elseif contains(line, "pitch=")
                val = sscanf(line, "pitch=%f");
                data = struct('type', 'pitch', 'value', val);
            elseif startsWith(line, "[")
                vals = sscanf(line, "[%f,%f]");
                data = struct('type', 'LGFF', 'pitch', vals(1), 'yaw', vals(2));
            elseif startsWith(line, "rate=")
                val = sscanf(line,"rate=%f");
                data = struct('type','rate','value',val);
            else
                data = struct('type', 'text', 'value', line);
            end

            if ~isempty(obj.OnReply)
                obj.OnReply(data);
            else
                disp("[REPLY] " + line);
            end

        end

        
        function ping(obj)
            obj.send("$PING");
        end

        function echo(obj, text)
            obj.send("$ECHO " + text);
        end

        function setRate(obj, hz)
            obj.send("$RATE " + num2str(hz));
        end

        function queryRate(obj)
            obj.send("$RATE ?");
        end

        function startStream(obj)
            obj.send("$START");
        end

        function stopStream(obj)
            obj.send("$STOP");
        end

        function pauseStream(obj)
            obj.send("$PAUSE");
        end

        function resumeStream(obj)
            obj.send("$RESUME");
        end

        function resetSystem(obj)
            obj.send("$RESET");
        end

        function setYaw(obj, angle)
            obj.send("$YAWPOS " + num2str(angle));
        end

        function setPitch(obj, angle)
            obj.send("$PITCHPOS " + num2str(angle));
        end

        function queryYaw(obj)
            obj.send("$YAWPOS ?");
        end

        function queryPitch(obj)
            obj.send("$PITCHPOS ?");
        end

        function queryLGFF(obj)
            obj.send("$LGFF ?");
        end

        function abort(obj)
            obj.send("$ABORT");
        end

 
        function clearLog(obj)
            obj.TelemetryLog = table([],[],[],[], ...
                'VariableNames', {'t','ax','ay','az'});
        end

        function saveToCSV(obj, filename)
            if nargin < 2
                filename = "imu_data_" + datestr(now,'yyyymmdd_HHMMSS') + ".csv";
            end
            writetable(obj.TelemetryLog, filename);
            fprintf("Saved telemetry to %s\n", filename);
        end
    end
end
