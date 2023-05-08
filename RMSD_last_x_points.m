clear all;
clear all;
close all;
clc;


PVC_pipe_25mL = {36,37,38,39,40,41,43,44,45,47,48,49,50,51,52,54,55,56,57,58,59,60,...
    61,62,63,65,66,68,69,72,85,107,109,110,159, 90, 201, 206, 208, 210,...
    216, 218, 220, 222, 224,...
    228, 229, 230, 231, 232, 237,239, 240, 242, 245,247,248,249, 250, 252, 258, 264, 265, 269};
PVC_pipe_25mL_CONT = {64, 67, 70, 71,73,74,75,76,77,78,79,80,81,82,83,84,103,105,111,...
    120, 207, 209, 211, 215, 217, 219, 221,223,225,226,227,233};
stir = {197,198,199,200,201};


info_file = xlsread('Experiment_List.xlsx');
maxpts = 0;
maxpts_ind = 0;
framerate = 30;



%%
trials = PVC_pipe_25mL;
%trials = PVC_pipe_25mL_CONT;

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



%% RMSD

cutoff = 200
buffer = 10

for i = 1:length(tracks)
    %figure;
    clear temp t x y MSD; 
    temp = tracks{i};
    
    %Take the last x points?
    
    if length(temp(:,1)) > cutoff+buffer
        t = temp(1:cutoff,1);
        x = temp(length(temp(:,1))-cutoff-buffer:end-buffer,2);
        y = temp(length(temp(:,1))-cutoff-buffer:end-buffer,3);
    else
        t = temp(:,1);
        x = temp(:,2);
        y = temp(:,3);
    end

    MSD(:,1) = t(2:end);
    MSD(:,2) = 0;
    MSD(:,3) = 0;
    
    for d = 1:length(t)-1
        clear deltaCoords
        deltaCoords(1,:) = x(1+d:end) - x(1:end-d);
        deltaCoords(2,:) = y(1+d:end) - y(1:end-d);
        squaredDisplacement = sum(deltaCoords.^2,1); %# dx^2+dy^2+dz^2

        MSD(d,2) = mean(squaredDisplacement)^ 0.5; %# sqrt of average (for RMSD)
        MSD(d,3) = std(squaredDisplacement)^ 0.5; %# std
        

    end

    
    x_fit = MSD(1:end,1);
    y_fit = MSD(1:end,2);          

%{
    
    
    plot(MSD(:,1),MSD(:,2));
    title('RMSD, heat')
    xlabel('Time (min)')
    ylabel('RMSD')
%}


    

    % Define Start points, fit-function and fit curve
    x0 = [0.01 100]; 
    fitfun = fittype( @(v, tau, x) (2*v^2*tau * (x - tau * (1 - exp(-x/tau))) ).^0.5);
    [fitted_curve, gof{i}] = fit(x_fit,y_fit,fitfun,'StartPoint',x0);
    f{i} = fitted_curve;
    % Save the coeffiecient values for a,b,c and d in a vector
    coeffvals{i} = coeffvalues(f{i});
    
    msdfit(i,1) = trials{i};
    msdfit(i,2) = coeffvals{i}(1);
    msdfit(i,3) = coeffvals{i}(2);
    msdfit(i,4) = gof{i}.sse;
    msdfit(i,5) = gof{i}.rsquare;
    msdfit(i,6) = gof{i}.dfe;
    msdfit(i,7) = gof{i}.adjrsquare;
    msdfit(i,8) = gof{i}.rmse;

    
    % Plot results
    scatter(x_fit, y_fit, 'r+')
    hold on
    plot(x_fit,fitted_curve(x_fit))
    hold off
    title('RMSD, cont')
    xlabel('Time (min)')    
    hold on;

    %plot(f{i})
    %hold off;
end
T = array2table(msdfit,...
'VariableNames',{'RMSD Trial','v','tau', 'sse', 'rsquare','dfe','adjrsquare', 'rmse'})


filename = 'Tayler RMSD heat.xlsx';

writetable(T,filename)
hold off;

%% Y RMSD
figure;
for i = 1:length(tracks)
    %figure;
    clear deltaCoords temp t x y MSD x0; 
    clear temp t x y MSD; 
    temp = tracks{i};
    %Take the last x points?
    
    if length(temp(:,1)) > cutoff+buffer
        t = temp(1:cutoff,1);
        x = temp(length(temp(:,1))-cutoff-buffer:end-buffer,2);
        y = temp(length(temp(:,1))-cutoff-buffer:end-buffer,3);
    else
        t = temp(:,1);
        x = temp(:,2);
        y = temp(:,3);
    end
    MSD(:,1) = t(2:end);
    MSD(:,2) = 0;
    MSD(:,3) = 0;
    
    for d = 1:length(t)-1
        clear deltaCoords
        deltaCoords = y(1+d:end) - y(1:end-d);
        squaredDisplacement = sum(deltaCoords.^2,2); %# dx^2+dy^2+dz^2

        MSD(d,2) = mean(squaredDisplacement)^ 0.5; %# sqrt of average (for RMSD)
        MSD(d,3) = std(squaredDisplacement)^ 0.5; %# std
        
    end
    %disp(size(deltaCoords))    
    x_fit = MSD(1:end,1);
    y_fit = MSD(1:end,2);
    
    % Define Start points, fit-function and fit curve
    x0 = [0.01 ]; 
    %fitfun = fittype( @(v, tau, x) (2*v^2*tau * (x - tau * (1 - exp(-x/tau))) ).^0.5);
    fitfun = fittype( @(v, x) (v*x));
    [fitted_curve, gof_y{i}] = fit(x_fit,y_fit,fitfun,'StartPoint',x0);
    f_y{i} = fitted_curve;
    % Save the coeffiecient values for a,b,c and d in a vector
    coeffvals_y{i} = coeffvalues(f_y{i});
    
    ymsdfit(i,1) = trials{i};
    ymsdfit(i,2) = coeffvals_y{i}(1);
    %ymsdfit(i,3) = coeffvals_y{i}(2);
    ymsdfit(i,4) = gof_y{i}.sse;
    ymsdfit(i,5) = gof_y{i}.rsquare;
    ymsdfit(i,6) = gof_y{i}.dfe;
    ymsdfit(i,7) = gof_y{i}.adjrsquare;
    ymsdfit(i,8) = gof_y{i}.rmse;
    

    
    % Plot results
    scatter(x_fit, y_fit, 'r+')
    hold on
    plot(x_fit,fitted_curve(x_fit))
    hold off
    title('RMSD (y displacement), cont')
    xlabel('Time (min)')    
    hold on;
    %plot(f{i})
    %hold off;
end
%disp (mean(ymsdfit(:,3)))
%disp (std(ymsdfit(:,3)))


T = array2table(ymsdfit,...
'VariableNames',{'Y RMSD Trial','v','tau', 'sse', 'rsquare','dfe','adjrsquare', 'rmse'})


filename = 'Tayler Y RMSD heat.xlsx';

writetable(T,filename)

%% X RMSD
figure;
clear deltaCoords
for i = 1:length(tracks)
    %figure;
    clear temp t x y MSD x0; 
    clear temp t x y MSD; 
    temp = tracks{i};
    %Take the last x points?
    
    if length(temp(:,1)) > cutoff+buffer
        t = temp(1:cutoff,1);
        x = temp(length(temp(:,1))-cutoff-buffer:end-buffer,2);
        y = temp(length(temp(:,1))-cutoff-buffer:end-buffer,3);
    else
        t = temp(:,1);
        x = temp(:,2);
        y = temp(:,3);
    end

    MSD(:,1) = t(2:end);
    MSD(:,2) = 0;
    MSD(:,3) = 0;
    
    for d = 1:length(t)-1
        
        deltaCoords = x(1+d:end) - x(1:end-d);
        squaredDisplacement = sum(deltaCoords.^2,2); %# dx^2+dy^2+dz^2

        MSD(d,2) = mean(squaredDisplacement)^ 0.5; %# sqrt of average (for RMSD)
        MSD(d,3) = std(squaredDisplacement)^ 0.5; %# std
        

    end
        


    x_fit = MSD(1:end,1);
    y_fit = MSD(1:end,2);

    
    

    % Define Start points, fit-function and fit curve
    x0 = [0.001 30]; 
    fitfun = fittype( @(v, tau, x) (2*v^2*tau * (x - tau * (1 - exp(-x/tau))) ).^0.5);
    [fitted_curve, gof_x{i}] = fit(x_fit,y_fit,fitfun,'StartPoint',x0);
    f_x{i} = fitted_curve;
    % Save the coeffiecient values for a,b,c and d in a vector
    coeffvals_x{i} = coeffvalues(f_x{i});
    
    
    xmsdfit(i,1) = trials{i};
    xmsdfit(i,2) = coeffvals_x{i}(1);
    xmsdfit(i,3) = coeffvals_x{i}(2);
    xmsdfit(i,4) = gof_x{i}.sse;
    xmsdfit(i,5) = gof_x{i}.rsquare;
    xmsdfit(i,6) = gof_x{i}.dfe;
    xmsdfit(i,7) = gof_x{i}.adjrsquare;
    xmsdfit(i,8) = gof_x{i}.rmse;
    

    
    
    % Plot results
    scatter(x_fit, y_fit, 'r+')
    hold on
    plot(x_fit,fitted_curve(x_fit))
    hold off
    title('RMSD (x displacement), cont')
    xlabel('Time (min)')
            
    hold on;
    %plot(f{i})
    %hold off;
end
%disp (mean(xmsdfit(:,3)))
%disp (std(xmsdfit(:,3)))


T = array2table(xmsdfit,...
'VariableNames',{'X_RMSD Trial','v','tau', 'sse', 'rsquare','dfe','adjrsquare', 'rmse'})


filename = 'Tayler X RMSD heat.xlsx';

writetable(T,filename) 




