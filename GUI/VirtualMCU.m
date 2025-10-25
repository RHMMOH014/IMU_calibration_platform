function VirtualMCU(csvFile, comPort, baud, sampleRateHz)

    data = readtable(csvFile);
    s = serialport(comPort, baud);
    configureTerminator(s, "LF");
    flush(s);

    fprintf("VIRTUAL MCU ready on %s. Awaiting commands...\n", comPort);

   
    paused = false;
    streaming = false;
    i = 1;
    n = height(data);
    dt = 1 / sampleRateHz;
    tNext = tic;

  
    yaw = 0;
    pitch = 0;
    telemetry_Rate = sampleRateHz;

   
    configureCallback(s, "terminator", @(src, ~) handleCmd(src));

    function handleCmd(src)
        cmd = strtrim(readline(src));
        fprintf("[VIRTUAL MCU] Received: %s\n", cmd);

      
        tokens = split(cmd);
        keyword = upper(tokens{1});
        arguments = tokens(2:end);

        switch keyword
            case "$START"
                streaming = true; 
                paused = false; 
                i = 1;
                tNext = tic;
                reply("EVT Streaming");

            case "$STOP"
                streaming = false;
                reply("EVT Stopped");

            case "$PAUSE"
                paused = true;
                reply("EVT Paused");

            case "$RESUME"
                paused = false;
                reply("EVT Resumed");

            case "$PING"
                reply("PONG");

            case "$ECHO"
                reply(strjoin(arguments, " "));

            case "$RATE"
                if numel(arguments) == 1 && arguments{1} == "?"
                    reply("rate=" + telemetry_Rate);
                elseif numel(arguments) == 1
                    telemetry_Rate = str2double(arguments{1});
                    dt = 1 / telemetry_Rate;
                    reply("EVT Rate");
                end

            case "$RESET"
                streaming = false; 
                paused = false; 
                i = 1;
                yaw = 0; pitch = 0;
                reply("EVT Reset");

            case "$ABORT"
                reply("EVT Fault");

            case "$YAWPOS"
                if numel(arguments) == 1 && arguments{1} == "?"
                    reply("yaw=" + yaw);
                elseif numel(arguments) == 1
                    yaw = str2double(arguments{1});
                    reply("EVT Yaw");
                end

            case "$PITCHPOS"
                if numel(arguments) == 1 && arguments{1} == "?"
                    reply("pitch=" + pitch);
                elseif numel(arguments) == 1
                    pitch = str2double(arguments{1});
                    reply("EVT Pitch");
                end

            case "$LGFF"
                if numel(arguments) == 1 && arguments{1} == "?"
                    reply("[" + pitch + "," + yaw + "]");
                end

            otherwise
                fprintf("[VIRTUAL MCU] Unknown command: %s\n", cmd);
        end
    end

    
    while true
        if streaming && ~paused && toc(tNext) >= dt && i <= n
            row = data(i,:);
            line = sprintf("T,%.3f,%.5f,%.5f,%.5f",row.t, row.ax, row.ay, row.az);
            writeline(s, line);
            i = i + 1;
            tNext = tic;
        elseif ~streaming
            pause(0.01);
        else
            pause(0.001);
        end
    end

    function reply(msg)
        writeline(s, msg);
    end
end
