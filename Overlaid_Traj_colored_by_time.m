close all;
clear all;
clear all;
clc;

PVC_pipe_25mL = {36,37,38,39,40,41,43,44,45,47,48,49,50,51,52,54,55,56,57,58,59,60,...
    61,62,63,65,66,68,69,72,85,107,109,110,159, 90, 206, 208, 210,...
    216, 218, 222, 224,...
    228, 229, 231, 232, 237,239, 240, 242, 245,247,248,249, 250, 252, 258, 264, 265, 269};
PVC_pipe_25mL_CONT = {64, 67, 70, 71,73,74,75,76,77,78,79,80,81,82,83,84,103,105,111,...
    120, 207, 209, 211, 215, 217, 219, 221,223,225,226,227,233, 243};

Fig4c ={38, 63, 228, 56,210, 239, 222, 224, 218};
Fig4d = {249, 248, 229, 61, 59, 43, 40, 50, 44, 231, 47, 109, ...
    258, 264, 107, 265, 110, 39, 62, 216, 49, 60, 48, 58, 65, 206, 66, 208, 57, 237, ...
    68, 54, 55, 41, 69, 45, 51, 52, 242, 240, 37, 36, 269, 250, 252,...
    159, 85, 245, 247,232, 90};

trials = PVC_pipe_25mL;
info_file = xlsread('Experiment_List.xlsx');
maxpts = 0;
maxpts_ind = 0;
framerate = 30;

%% Convert trajectory to um and min
SPACE_UNITS = 'mm';
TIME_UNITS = 'min';
for i = 1:length(trials)  
    
    clear temp2;
    clear temp1;
    
    index = trials{i};
    camnum = info_file(index,4);
    temp1 = csvread(strcat(num2str(index), '.txt'));
    pxconv = info_file(index,5);
    heat_axis = info_file(index,10);
    if pxconv == 0 
        if camnum == 1
            %temp1 = temp1 * 40000/1496; %Trials before March 1 2019
            %temp1 = temp1 * 40000/1537;
            temp1 = temp1 * 50800/1864000;  %Si Wafer PVC pipe setup, mm
        elseif camnum ==2
            %temp1 = temp1 * 40000/734; %Trials before March 1 2019
            %temp1 = temp1 * 40000/758;
            temp1 = temp1 * 50800/966000; %Si Wafer PVC pipe setup, mm
            %temp1 = temp1 * 52.5018/1143; %cam 2 with hotplate
        elseif camnum ==3
            %temp1 = temp1 * 40000/748; %Trials before March 1 2019
            %temp1 = temp1 * 40000/776;
            temp1 = temp1 * 50800/834000; %Si Wafer PVC pipe setup, mm
        elseif camnum ==4
            %temp1 = temp1 * 40000/735; %Trials before March 1 2019
            temp1 = temp1 * 40000/776000; %mm
        else
            continue;
        end
    else
        temp1 = temp1 * pxconv;
    end
    
    
    %FOR ANY HEAT TRIAL, ALIGN THE HEAT SUCH THAT THE HEAT IS AT BOTTOM Y
    %AXIS
    disp(heat_axis)
    if heat_axis == 1  %1 is yp
        temp1(:,2) = temp1(:,2) * -1;
    elseif heat_axis == 2 %2 is xp
        v = temp1(:, 1);
        temp1(:, 1) = temp1(:, 2);
        temp1(:, 2) = -v;
    elseif heat_axis == 3 %3 is xn
        v = temp1(:, 1);
        temp1(:, 1) = temp1(:, 2);
        temp1(:, 2) = v;    
    else
        disp(heat_axis)
    end
        
    
    %TURN HIGHER FRAME RATE TRIALS IN CONT AND HEAT TO 30S FRAME RATE
    
    if ismember(index, [103,105,107]) == 1
        temp1 = temp1(1:3:end,:);
    elseif ismember(index, [111,109]) == 1
        temp1 = temp1(1:6:end,:);
    elseif ismember(index, [110]) == 1
        temp1 = temp1(1:12:end,:);
    end

    

    
    %Time is in minutes
    temp2(:,1) = linspace(0,0.5*(length(temp1(:,1))-1),length(temp1(:,1)));
    temp2(:,2) = temp1(:,1);
    temp2(:,3) = temp1(:,2);
    
    tracks{i} = temp2;
    
    index = index + 1;

end





%Trim trajectory to 2.5cm radius arena limits


for i = 1:length(trials)
    radii = [];
    radii = (tracks{i}(:,3).^2 + tracks{i}(:,2).^2).^0.5;
    indices = find(radii > 25);
    if isempty(indices) == 1
        indices(1) = length(tracks{i}(:,3));
    end
    endindex = indices(1);
    display(endindex)
    tracks{i} = tracks{i}(1:endindex,:);
    if endindex > maxpts
        maxpts = endindex;
        maxpts_ind = i;
        display(maxpts)
    end    
end


%% FOR OVERLAID TRAJ
%Plot trimmed trajectories
f1 = figure;
colors = linspace(0,length(tracks{maxpts_ind})*framerate/3600,length(tracks{maxpts_ind}));
sz = 10;
hold on;
length(colors)
for i = 1:length(trials)
    
    %line(tracks{i}(:,2), tracks{i}(:,3))
    scatter(tracks{i}(:,2), tracks{i}(:,3),sz,colors(1:length(tracks{i}(:,2))),'filled')
    
    %title('Overlaid Trajectories. Colorbar is time (hours)');
%     %Plot perturbations
    %plot(tracks{i}(149,2), tracks{i}(149,3), 'bp', 'MarkerSize',15, 'MarkerFaceColor', 'b')
    %plot(tracks{i}(167,2), tracks{i}(167,3), 'mp', 'MarkerSize',15, 'MarkerFaceColor', 'm')
    %plot(tracks{i}(377,2), tracks{i}(377,3), 'rx', 'MarkerSize',15, 'LineWidth',3)
    
end



r = 25;
theta = 0:0.05:3*pi;
plot(r*cos(theta),r*sin(theta),'k','LineWidth',4);




axis equal;



hold off;
xlim([-25,25]);
ylim([-25,25])
c=colorbar;
c.FontSize = 70
%xlabel('x (mm)')
%ylabel('y (mm)')
%title(num2str(cell2mat(trials)))
title(c, 'Time (h)')
set(gca,'fontsize',70)
xlabel('x (mm)', 'fontsize',70)
ylabel('y (mm)', 'fontsize',70)
%set(gca,'XTick',[], 'YTick', [])
%% FOR SINGLE TRIAL TRAJ

%Plot trimmed trajectories
f1 = figure;
colors = linspace(0,length(tracks{maxpts_ind})*framerate/3600,length(tracks{maxpts_ind}));
sz = 50;
hold on;
length(colors)
for i = 1:length(trials)
    
    line(tracks{i}(:,2), tracks{i}(:,3))
    scatter(tracks{i}(:,2), tracks{i}(:,3),sz,colors(1:length(tracks{i}(:,3))),'filled')
    
    %title('Overlaid Trajectories. Colorbar is time (hours)');
%     %Plot perturbations
    %plot(tracks{i}(583-230,2), tracks{i}(583-230,3), 'rx', 'MarkerSize',25, 'LineWidth',3)
    %plot(tracks{i}(583-230+40,2), tracks{i}(583-230+40,3), 'gx', 'MarkerSize',25, 'LineWidth',3)

    %plot(tracks{i}(316,2), tracks{i}(316,3), 'rx', 'MarkerSize',30, 'LineWidth',3)
%     plot(tracks{i}(1,2), tracks{i}(1,3), 'rx', 'MarkerSize',30, 'LineWidth',3)
%     plot(tracks{i}(30,2), tracks{i}(30,3), 'rx', 'MarkerSize',30, 'LineWidth',3)
%     plot(tracks{i}(41,2), tracks{i}(41,3), 'rx', 'MarkerSize',30, 'LineWidth',3)
%     plot(tracks{i}(60,2), tracks{i}(60,3), 'rx', 'MarkerSize',30, 'LineWidth',3)
%     plot(tracks{i}(71,2), tracks{i}(71,3), 'rx', 'MarkerSize',30, 'LineWidth',3)
%     plot(tracks{i}(90,2), tracks{i}(90,3), 'rx', 'MarkerSize',30, 'LineWidth',3)
%     plot(tracks{i}(120,2), tracks{i}(120,3), 'rx', 'MarkerSize',30, 'LineWidth',3)
%     plot(tracks{i}(132,2), tracks{i}(132,3), 'rx', 'MarkerSize',30, 'LineWidth',3)
%     plot(tracks{i}(93,2), tracks{i}(93,3), 'rx', 'MarkerSize',30, 'LineWidth',3)

end


%{
r = 25;
theta = 0:0.05:3*pi;
plot(r*cos(theta),r*sin(theta),'k','LineWidth',3);
%}



axis equal;



hold off;
ylim([-30,30]);
xlim([-30,30]);
c=colorbar;
c.FontSize = 75;
title(c, 'Time (h)')
%xlabel('x (mm)')
%ylabel('y (mm)')
%title(num2str(cell2mat(trials)))
%set(gca,'XTick',[], 'YTick', [])
set(gca,'fontsize',75)
xlabel('x (mm)', 'fontsize',75)
ylabel('y (mm)', 'fontsize',75)
