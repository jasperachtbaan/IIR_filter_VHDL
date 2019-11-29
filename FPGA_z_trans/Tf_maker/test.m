% -------------------------------------------------
% This file needs the Image Processing Toolbox!
% -------------------------------------------------



close all;
clear all;
clc;

figure();
hold on;
axis([0 7 0 5])

% I do not know how to do this without global variables?
global P0 P1 P2

% GCA = Get handle for Current Axis
P0 = drawpoint(gca,'Position',[1 1]);
P0.Label = 'P0';
P1 = drawpoint(gca,'Position',[2 4]);
P1.Label = 'P1';
P2 = drawpoint(gca,'Position',[6 2]);
P2.Label = 'P2';

% Call subfunction
DrawLagrange(P0,P1,P2)

% Add callback to each point
addlistener(P0,'MovingROI',@allevents);
addlistener(P1,'MovingROI',@allevents);
addlistener(P2,'MovingROI',@allevents);

function allevents(src,evt)
    global P0 P1 P2
    DrawLagrange(P0,P1,P2)
end

function DrawLagrange(P0,P1,P2)

    P = zeros(3,2);
    % Get X and Y coordinates for the 3 points.
    P(1,:) = P0.Position;
    P(2,:) = P1.Position;
    P(3,:) = P2.Position;

    global H1 H2
    if sum(ishandle(H1)) ~= 1
        H1 = plot(P(:,1), P(:,2), 'ko--', 'MarkerSize', 12, 'Color', 'blue');

        t = 0:.1:2;
        Lagrange = [.5*t.^2 - 1.5*t + 1; -t.^2 + 2*t; .5*t.^2 - .5*t];

        CurveX = P(1,1)*Lagrange(1,:) + P(2,1)*Lagrange(2,:) + P(3,1)*Lagrange(3,:);
        CurveY = P(1,2)*Lagrange(1,:) + P(2,2)*Lagrange(2,:) + P(3,2)*Lagrange(3,:);

        H2 = plot(CurveX, CurveY, 'Color', 'blue');
    else
        set(H1, 'XData', P(:,1), 'YData', P(:,2));
        
        t = 0:.1:2;
        Lagrange = [.5*t.^2 - 1.5*t + 1; -t.^2 + 2*t; .5*t.^2 - .5*t];
        
        CurveX = P(1,1)*Lagrange(1,:) + P(2,1)*Lagrange(2,:) + P(3,1)*Lagrange(3,:);
        CurveY = P(1,2)*Lagrange(1,:) + P(2,2)*Lagrange(2,:) + P(3,2)*Lagrange(3,:);
        set(H2, 'XData', CurveX, 'YData', CurveY);
    end
end