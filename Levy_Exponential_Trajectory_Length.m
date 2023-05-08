%% XY DISP 
clear all;
clear all;
close all;
clc;
PVC_pipe_25mL = {36,37,38,39,40,41,43,44,45,47,48,49,50,51,52,54,55,56,57,58,59,60,...
    61,62,63,65,66,68,69,72,85,107,109,110,159, 90, 206, 208, 210,...
    216, 218, 222, 224,...
    228, 229, 231, 232, 237,239, 240, 242, 245,247,248,249, 250, 252, 258, 264, 265, 269};
PVC_pipe_25mL_CONT = {64, 67, 70, 71,73,74,75,76,77,78,79,80,81,82,83,84,103,105,111,...
    120, 207, 209, 211, 215, 217, 219, 221,223,225,226,227,233, 243};


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
    
    if heat_axis == 1  %1 is yp
        temp1(:,2) = temp1(:,2) * -1;
        disp(heat_axis)
    elseif heat_axis == 2 %2 is xp
        v = temp1(:, 1);
        temp1(:, 1) = temp1(:, 2);
        temp1(:, 2) = -v;
    elseif heat_axis == 3 %3 is xn
        v = temp1(:, 1);
        temp1(:, 1) = temp1(:, 2);
        temp1(:, 2) = v;    
    end
        
    
    %TURN HIGHER FRAME RATE TRIALS IN CONT AND HEAT TO 30S FRAME RATE
    
    if ismember(index, [103,105,107]) == 1
        temp1 = temp1(1:3:end,:);
    elseif ismember(index, [111,109]) == 1
        temp1 = temp1(1:6:end,:);
    elseif ismember(index, [110]) == 1
        temp1 = temp1(1:12:end,:);
    end

    
    if length(temp1(:,1)) > maxpts
        maxpts = length(temp1(:,1));
        maxpts_ind = i;
    end
    
    %Time is in minutes
    temp2(:,1) = linspace(0,0.5*(length(temp1(:,1))-1),length(temp1(:,1)));
    temp2(:,2) = temp1(:,1);
    temp2(:,3) = temp1(:,2);
    
    tracks{i} = temp2;
    
    index = index + 1;

end

%% Concatenate all the data and then draw a fit 



stepsize = 4;
clear abs_disp
array_counter = 0;
trial_counter = 1;
for i = 1:length(tracks)
    
    %figure;
    clear pd temp t x y MSD; 
    index = trials{i};
    temp = tracks{i};
    %numbins = round(length(temp(:,1))/20);
    numbins = 40;
    
    counter = 1;
    %overlapping windows
    for s = 1:1:length(temp(:,1))-stepsize
        s2 = s+stepsize;
        abs_disp(counter+array_counter,1) = temp(s,1);
        %column 2 is x absolute disp
        %column 3 is y absolute disp
        %column 4 is absolute displacement
        x_disp = temp(s2,2) - temp(s,2);
        y_disp = temp(s2,3) - temp(s,3);
        
        abs_disp(counter+array_counter,2) = abs(x_disp);
        abs_disp(counter+array_counter,3) = abs(y_disp);
        abs_disp(counter+array_counter,4) = (abs(x_disp)^2 + abs(y_disp)^2)^0.5;
        counter = counter + 1;
        
    end
    total_track_length_heat(trial_counter,1) = length(temp(:,1)) /120; %Lenght of track in hours
    trial_counter = trial_counter + 1;
    array_counter = length(abs_disp(:,1));
end

pdraw = histogram(abs_disp(:,4),numbins);

for j = 1:numbins-1
    pd1_temp = (pdraw.BinEdges(j) + pdraw.BinEdges(j+1))/2;
    pd2_temp = pdraw.Values(j) / sum(pdraw.Values(:));
    pd(j,1) = pd1_temp;
    pd(j,2) = pd2_temp;
%     if pd2_temp ~= 0
%         pd(j,1) = pd1_temp;
%         pd(j,2) = pd2_temp;
%     end


end
%pd(pd(:,2) == 0) = [];




%% Do the same for control
clear trials tracks
trials = PVC_pipe_25mL_CONT;
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
    
    if heat_axis == 1  %1 is yp
        temp1(:,2) = temp1(:,2) * -1;
        disp(heat_axis)
    elseif heat_axis == 2 %2 is xp
        v = temp1(:, 1);
        temp1(:, 1) = temp1(:, 2);
        temp1(:, 2) = -v;
    elseif heat_axis == 3 %3 is xn
        v = temp1(:, 1);
        temp1(:, 1) = temp1(:, 2);
        temp1(:, 2) = v;    
    end
        
    
    %TURN HIGHER FRAME RATE TRIALS IN CONT AND HEAT TO 30S FRAME RATE
    
    if ismember(index, [103,105,107]) == 1
        temp1 = temp1(1:3:end,:);
    elseif ismember(index, [111,109]) == 1
        temp1 = temp1(1:6:end,:);
    elseif ismember(index, [110]) == 1
        temp1 = temp1(1:12:end,:);
    end

    
    if length(temp1(:,1)) > maxpts
        maxpts = length(temp1(:,1));
        maxpts_ind = i;
    end
    
    %Time is in minutes
    temp2(:,1) = linspace(0,0.5*(length(temp1(:,1))-1),length(temp1(:,1)));
    temp2(:,2) = temp1(:,1);
    temp2(:,3) = temp1(:,2);
    
    tracks{i} = temp2;
    
    index = index + 1;

end

clear abs_disp
array_counter = 0;
trial_counter = 1;
for i = 1:length(tracks)
    
    %figure;
    clear pd_cont temp t x y MSD; 
    index = trials{i};
    temp = tracks{i};
    %numbins = round(length(temp(:,1))/20);
    numbins = 40;
    
    counter = 1;
    %overlapping windows
    for s = 1:1:length(temp(:,1))-stepsize
        s2 = s+stepsize;
        abs_disp(counter+array_counter,1) = temp(s,1);
        %column 2 is x absolute disp
        %column 3 is y absolute disp
        %column 4 is absolute displacement
        x_disp = temp(s2,2) - temp(s,2);
        y_disp = temp(s2,3) - temp(s,3);
        
        abs_disp(counter+array_counter,2) = abs(x_disp);
        abs_disp(counter+array_counter,3) = abs(y_disp);
        abs_disp(counter+array_counter,4) = (abs(x_disp)^2 + abs(y_disp)^2)^0.5;
        counter = counter + 1;
        
    end
    total_track_length_cont(trial_counter,1) = length(temp(:,1)) /120; %Lenght of track in hours
    trial_counter = trial_counter+1;
    array_counter = length(abs_disp(:,1));
end
clear pd_cont
pdraw = histogram(abs_disp(:,4),numbins);

for j = 1:numbins-1
    pd1_temp = (pdraw.BinEdges(j) + pdraw.BinEdges(j+1))/2;
    pd2_temp = pdraw.Values(j) / sum(pdraw.Values(:));
    pd_cont(j,1) = pd1_temp;
    pd_cont(j,2) = pd2_temp;
%     if pd2_temp ~= 0
%         disp(pd2_temp)
%         pd_cont(j,1) = pd1_temp;
%         pd_cont(j,2) = pd2_temp;
%     end


end

fig_levy = figure;
%% CURVE FIT AND PLOTTING

%% PLOT CONTROL
%pd(pd(:,2) == 0) = [];
x = pd_cont(:,1);
y = pd_cont(:,2);
plot(x,y,'b.','MarkerSize', 20, 'LineWidth', 6,'color',[155/256 183/256 209/256]);
filename = strcat('HistogramDataContALL_XYDISP','.txt');
currentFolder = pwd;
out = fullfile(currentFolder, '/PaperFigs/Plots_Levy_Exponential',filename);
csvwrite(out,pd_cont);


hold on;
x = pd_cont(:,1);
% Power law fit CONT
 
% [p,gof] = polyfit(log(x),log(pd_cont(:,2)),1) 
% 
% m = p(1);
% b = exp(p(2));
%h = ezplot(@(x) b*x.^m,[x(1) x(end)]);


% Levy distribution
x0 = [0 0]; 
fitfun = fittype( @(c, mu, x) (c/2/pi)^0.5 * (exp(-c./(2*(x-mu)))) ./ (x-mu).^1.5  );
[fitted_curve,gof] = fit(x,y,fitfun,'StartPoint',x0)

%Exponential Fit
[fitfun_exponential, gof_exponential] = fit(x,y,'exp1')

%{
%Plot the Levy fit line
c = fitted_curve.c;
mu = fitted_curve.mu;
h = ezplot(@(x) (c/2/pi)^0.5 * (exp(-c./(2*(x-mu)))) ./ (x-mu).^1.5,[x(1) x(end)]);
set(h,'LineWidth',3);
set(h, 'Color', [112/256 193/256 164/256]);
%}

%Plot the exponential fit line
a = fitfun_exponential.a;
b = fitfun_exponential.b;
h = ezplot (@(x) a*exp(b*x),[x(1) x(end)]);
set(h,'LineWidth',3);
set(h, 'Color', [155/256 183/256 209/256]);


%% PLOT HEAT
%Levy distribution Fit HEAT

x = pd(:,1);
y = pd(:,2);
plot(x,y,'k.','MarkerSize', 20, 'LineWidth', 6 , 'color', [153/256,212/256,191/256]);
filename = strcat('HistogramDataHeatALL_XYDISP','.txt');
currentFolder = pwd;
out = fullfile(currentFolder, '/PaperFigs/Plots_Levy_Exponential',filename);
csvwrite(out,pd);
x = pd(:,1)

% Power law fit
% [p,gof] = polyfit(log(x),log(pd(:,2)),1); 
% m2 = p(1);
% b2 = exp(p(2));
% h2 = ezplot(@(x) b2*x.^m2,[x(1) x(end)]);


%Levy fit
x0 = [0 0]; 
fitfun = fittype( @(c, mu, x) (c/2/pi)^0.5 * (exp(-c./(2*(x-mu)))) ./ (x-mu).^1.5  );
[fitted_curve,gof] = fit(x,y,fitfun,'StartPoint',x0)

%Exponential Fit
[fitfun_exponential, gof_exponential] = fit(x,y,'exp1')

%{
%Plot Levy Fit line
c = fitted_curve.c;
mu = fitted_curve.mu;
h2 = ezplot(@(x) (c/2/pi)^0.5 * (exp(-c./(2*(x-mu)))) ./ (x-mu).^1.5,[x(1) x(end)]);
set(h2,'LineWidth',3);
set(h2, 'Color', [248/256,139/256,96/256]);
%}


%Plot the exponential fit line
a = fitfun_exponential.a;
b = fitfun_exponential.b;
h = ezplot (@(x) a*exp(b*x),[x(1) x(end)]);
set(h,'LineWidth',3);
set(h, 'Color', [153/256,212/256,191/256]);



title('')
figname = strcat('ALL DATA POINTS XY DISP stepsize ' , num2str(stepsize) , '.png');
outfig1 = fullfile(currentFolder, '/PaperFigs/Plots_Levy_Exponential', figname);

ylabel ('Probability Distribution', 'FontSize', 25);
xlabel({'momentary displacement (mm)',' 2 minute window size'}, 'FontSize', 25);
set(gca,'FontSize',20);
ylim([0,0.2])

set(gca, 'YScale', 'log')
%set(gca, 'XScale', 'log')

saveas(fig_levy, outfig1);   
   

%% Plot the total trajectory length box plot
figure
data_concatenate = NaN(2,61);
data_concatenate(1,:) = total_track_length_heat;
data_concatenate(2,1:33) = total_track_length_cont;
data_concatenate = data_concatenate .';
boxplot(data_concatenate,'Labels',{'heat','control'})
display(mean(total_track_length_cont))
display(std(total_track_length_cont))
display(mean(total_track_length_heat))
display(std(total_track_length_heat))


ylabel ('Trajectory length(hours)', 'FontSize', 25);
set(gca,'FontSize',20);

