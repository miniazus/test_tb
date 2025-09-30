clear all, clc 

NumFrame        = 1000;
NumBitPerFrame  = 512;
NumBitPerSample = 32;
DownSampleRate  = [2,4];
NumChannel      = size(DownSampleRate,2);

data_from_Decombiner = cell(1, NumChannel);
data_from_LM         = CreateRan512b(NumFrame, NumBitPerFrame);
%
for i=1:NumChannel
    data_from_Decombiner{i} = CreateRan512b(NumFrame/DownSampleRate(i), NumBitPerFrame);
end

SamplingRate_LM = 375;    %Mz 
SamplingRate_CH = 187.5;  %MHz
SamplingRate_Xb = 350;    %MHz     %Xbar

Sid_LM           = 1;
Sid_CH_DeComb    = 2;
Sid_CH_Comb      = [3,4];

BW_Xbar = SamplingRate_Xb * NumBitPerFrame;



export_data = struct('time', {}, 'sid', {}, 'data', {});  % empty struct
currenttime = 0;

for k = 1:NumFrame
    %data from LM
    t_time  = currenttime*(1e6/SamplingRate_LM);
    t_sid   = Sid_CH_DeComb;
    t_data  = data_from_LM(k);
    new_row = struct('time', t_time, 'sid', t_sid, 'data', t_data);
    export_data(end+1) = new_row;
    
    for i = 1:NumChannel
        if mod(k,DownSampleRate(i)) == 0
            t_idx   = floor((k-1)/DownSampleRate(i)) + 1;
            t_sid   = Sid_CH_Comb(i);
            t_data  = data_from_Decombiner{i}{t_idx};
            new_row = struct('time', t_time, 'sid', t_sid, 'data', t_data);
            export_data(end+1) = new_row;
        end
    end

    currenttime = currenttime + NumBitPerFrame/NumBitPerSample;
end


for k = 2:size(export_data,2)
    if export_data(k).time - export_data(k-1).time < 1e6/SamplingRate_Xb
        export_data(k).time = export_data(k-1).time + 1e6/SamplingRate_Xb;
    end
end


time_vector = [export_data.time];   % 1×N numeric array
sid_vector  = [export_data.sid];    % 1×N numeric array

stem(time_vector, sid_vector, '.-'); % dot for clarity
xlabel('Time (\mus)');
ylabel('SID');
grid on;


% Open file for writing
fileID = fopen('export_data.txt', 'w');

% Loop through each struct element
for k = 1:length(export_data)
    fprintf(fileID, '%f;%d;%s\r\n', ...
        export_data(k).time, ...
        export_data(k).sid, ...
        export_data(k).data);
end

% Close the file
fclose(fileID);

disp('Export complete!');