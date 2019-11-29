% -------------------------------------------------
% This file needs the Image Processing Toolbox!
% -------------------------------------------------



close all;
clear all;
clc;
global noOfPoints
global points
global axesInfo
global sampleFreq

axesInfo.Xmin = 0.1;
axesInfo.Xmax = 20000;
axesInfo.Ymin = -20;
axesInfo.Ymax = 6;
axesInfo.infPoint = -18;
noOfPoints = 3;
points = images.roi.Point;
sampleFreq = 48000;

figure();
hold on;
hold(gca,'on');
axis([axesInfo.Xmin axesInfo.Xmax axesInfo.Ymin axesInfo.Ymax])
set(gca, 'XScale', 'log');
plot([axesInfo.Xmin axesInfo.Xmax], [axesInfo.infPoint axesInfo.infPoint], 'black--');
grid on;


% GCA = Get handle for Current Axis
positions = logspace(log10(axesInfo.Xmin), log10(axesInfo.Xmax), noOfPoints + 1);
for p = 1:noOfPoints
    points(p) = drawpoint(gca,'Position',[1 1]);
    set(points(p), 'Position', [positions(p) 0]);
end
set(points(1), 'DrawingArea', [axesInfo.Xmin axesInfo.Ymin 0 (axesInfo.Ymax - axesInfo.Ymin)]);

% Add callback to each point
for p = 1:noOfPoints
    addlistener(points(p),'MovingROI',@allevents);
end

drawSquare(points, noOfPoints, axesInfo);

function allevents(src,evt)
    global points noOfPoints axesInfo sampleFreq
    axis([axesInfo.Xmin axesInfo.Xmax axesInfo.Ymin axesInfo.Ymax])
    drawSquare(points, noOfPoints, axesInfo);
    tfs = getTransferFunc(points, noOfPoints, axesInfo, sampleFreq);
    drawTransferFunc(tfs, axesInfo);
end

function tfs = getTransferFunc(points, noOfPoints, axesInfo, sampleFreq)
    P = zeros(noOfPoints,2);
    % Get X and Y coordinates for the points
    for p = 1:noOfPoints
        P0 = points(p);
        P(p,:) = P0.Position;
    end
    P = sortrows(P); %Sort the list by the x values
    PSq = zeros(noOfPoints * 2,2);
    
    for p = 1:(noOfPoints - 1)
        PSq(2*(p - 1) + 1,:) = P(p,:);
        PSq(2*p,:) = [P(p + 1,1) P(p,2)];
    end
    PSq(end - 1, :) = P(end,:);
    PSq(end, :) = [axesInfo.Xmax P(end,2)];
    
    tfs = tf;
    tfCnt = 1;

    for p = 1:(noOfPoints * 2 - 1)
        p0 = PSq(p, :);
        p1 = PSq(p + 1, :);
        
        if and(p0(2) <= axesInfo.infPoint, p1(2) > axesInfo.infPoint)
            %Highpass
            [b,a] = butter(2,2*(p1(1) / sampleFreq), 'high');
            b = b * 10^(p1(2)/20);
            tfs(tfCnt) = tf(b, a, 1/sampleFreq);
            tfCnt = tfCnt + 1;
          
        elseif and(p0(2) > axesInfo.infPoint, p1(2) <= axesInfo.infPoint)
            %Lowpass
            [b,a] = butter(2,2*(p0(1) / sampleFreq), 'low');
            if tfCnt == 1
                b = b * 10^(p0(2)/20);
            end
            tfs(tfCnt) = tf(b, a, 1/sampleFreq);
            tfCnt = tfCnt + 1;
            
        elseif p0(2) ~= p1(2)
            %Shelving
            [b,a] = designShelvingEQ(p1(2) - p0(2),2,2*(p1(1) / sampleFreq),'hi' ,'Orientation', 'row');
            if tfCnt == 1
                b = b * 10^(p0(2)/20);
            end
            
            tfs(tfCnt) = tf(b, a, 1/sampleFreq);
            tfCnt = tfCnt + 1;
        else
            %Nothing
        end
    end
    
end

function drawTransferFunc(tfs, axesInfo)
    drawPts = 100;
    xAxis = logspace(log10(axesInfo.Xmin), log10(axesInfo.Xmax), drawPts);
    
    global totalTfGL
    if length(tfs) > 0
        totalTf = tfs(1);
        for p = 2:length(tfs)
            totalTf = totalTf * tfs(p);
        end
    else
        totalTf = tfs;
    end
    totalTfGL = totalTf;
    [mag,phase,wout] = bode(totalTf, xAxis*2*pi);
    magdb = 20*log10(mag(:));
    
    if length(magdb) ~= length(xAxis)
        return;
    end
        
    global H2
    if sum(ishandle(H2)) ~= 1
        H2 = semilogx(xAxis, magdb);
    else
        set(H2, 'XData', xAxis, 'YData', magdb);
    end
    
    
end

function drawSquare(points, noOfPoints, axesInfo)
    P = zeros(noOfPoints,2);
    % Get X and Y coordinates for the points
    for p = 1:noOfPoints
        P0 = points(p);
        P(p,:) = P0.Position;
    end
    P = sortrows(P); %Sort the list by the x values
    PSq = zeros(noOfPoints * 2,2);
    
    for p = 1:(noOfPoints - 1)
        PSq(2*(p - 1) + 1,:) = P(p,:);
        PSq(2*p,:) = [P(p + 1,1) P(p,2)];
    end
    PSq(end - 1, :) = P(end,:);
    PSq(end, :) = [axesInfo.Xmax P(end,2)];
    global H1
    if sum(ishandle(H1)) ~= 1
        H1 = plot(PSq(:,1), PSq(:,2), 'blue-.');
    else
        set(H1, 'XData', PSq(:,1), 'YData', PSq(:,2));
    end
end