clear all;
close all;
clc;


PVC_pipe_25mL = {36,37,38,39,40,41,43,44,45,47,48,49,50,51,52,54,55,56,57,58,59,60,...
    61,62,63,65,66,68,69,72,85,107,109,110,159, 90, 206, 208, 210,...
    216, 218, 220, 222, 224,...
    228, 229, 230, 231, 232, 237,239, 240, 242, 245,247,248,249, 250, 252, 258, 264, 265, 269};
PVC_pipe_25mL_CONT = {64, 67, 70, 71,73,74,75,76,77,78,79,80,81,82,83,84,103,105,111,...
    120, 207, 209, 211, 215, 217, 219, 221,223,225,226,227,241,243};
Stir_Bottom_Heat = {197,198,199,200};


trials = PVC_pipe_25mL;

info_files = xlsread('Experiment_List.xlsx');
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
    camnum = info_files(index,4);
    temp1 = csvread(strcat(num2str(index), '.txt'));
    pxconv = info_files(index,5);
    heat_axis = info_files(index,10);
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



           

%% Y MSD ONLY
cutoff = 200;
buffer = 10;

for i = 1:length(tracks)
    figure;
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
    
    for d = 1:length(t)-1
        
        deltaCoords = y(1+d:end) - y(1:end-d);
        squaredDisplacement = sum(deltaCoords.^2,2); %# dx^2+dy^2+dz^2
        display(squaredDisplacement)
        MSD(d,2) = mean(squaredDisplacement); %# average
        MSD(d,3) = std(squaredDisplacement); %# std
        


    end
        
    MSD(:,1) = log(MSD(:,1));
    MSD(:,2) = log(MSD(:,2));
    
    
    plot(MSD(:,1),MSD(:,2),'x');
    [f{i}, gof{i}]=fit(MSD(:,1),MSD(:,2),'poly1');
    slopey(i,1) = trials{i};
    slopey(i,2) = f{i}.p1;
            
    hold on;
    plot(f{i})
    hold off;
    title(trials{i})
end
close all;    
display(slopey)



%% X MSD ONLY

for i = 1:length(tracks)
    figure;
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

        MSD(d,2) = mean(squaredDisplacement); %# average
        MSD(d,3) = std(squaredDisplacement); %# std
        


    end
        
    MSD(:,1) = log(MSD(:,1));
    MSD(:,2) = log(MSD(:,2));
    
    if length(MSD(:,1)) > cutoff
    
        MSD = MSD (1:cutoff,:);
    else
        MSD = MSD (1:end,:);
    end
    
    plot(MSD(:,1),MSD(:,2),'x');
    [f{i}, gof{i}]=fit(MSD(:,1),MSD(:,2),'poly1');
    slopex(i,1) = trials{i};
    slopex(i,2) = f{i}.p1;
            
    hold on;
    plot(f{i})
    hold off;
    
end
close all;    
display(slopex)

   
   






%% Path persistence length
%NOTE THAT SPACE UNITS IS MM HERE!!
dirpath = 'Path Persistence Length';
mkdir(dirpath);

for i = 1:length(tracks)
    Lpfigure = figure;
    index = trials{i};
    traj = tracks{i};
    t = traj(:,1);
    x = traj(:,2)/1000;
    y = traj(:,3)/1000;  
    
    %First find the total length of the trajectory. 
    total_L = 0;
    max_L = 0;
    
    for t = 1:length(traj)-1
        L_temp = ((y(t+1)-y(t))^2+(x(t+1)-x(t))^2)^.5;
        total_L = total_L + L_temp;
        if L_temp > max_L
            max_L = L_temp;
        end 
    end
    % I want target L to be between the max single step disp and half of
    % total L.
    L_all = linspace(max_L, total_L/2-max_L, 200);
    

    
    for L_ind = 1: length(L_all)
        L_target = L_all(L_ind);
            R2 = 0;
            N = 0;
            %Column 1 of Lp_Parameters is trial number
            Lp_Parameters{i}(L_ind, 1) = index;
            %Column 2 of Lp_Parameters is the length of contours
            Lp_Parameters{i}(L_ind, 2) = L_target;
            d = 1;
            while d < length(traj)
                L = 0;
                first_ind = 1;
                while (L < L_target) && (d < length(traj))
                    if first_ind == 1
                        start_ind = d;
                        first_ind = 0;
                    end
                    L = L+((y(d+1)-y(d))^2+...
                    (x(d+1)-x(d))^2)^.5;
                    d = d+1;
                end
                end_ind = d;
                R2 = R2 + ((y(end_ind)-y(start_ind))^2+...
                    (x(end_ind)-x(start_ind))^2);
                N = N +1;
            end
    
            R2 = R2/N;
            
            %Column3 is expected value of R2
            Lp_Parameters{i}(L_ind, 3) = R2;
            %Column4 is N
            Lp_Parameters{i}(L_ind, 4) = N;
            
            syms Lp
            eqn = R2 == 2 * Lp^2 * (L_target/Lp - 1 + exp(-L_target/Lp));
            sol_Lp = solve(eqn,Lp);
            
            %Column 5 is the computed Lp
            if sol_Lp > 0
                Lp_Parameters{i}(L_ind, 5) = sol_Lp;
            else
                Lp_Parameters{i}(L_ind, 5) = 0;
            end
            

    end
    plot(Lp_Parameters{i}(:,2), Lp_Parameters{i}(:,5),'x','MarkerSize',5);
    LpFigname = strcat(num2str(index),'_Persistence Length.png');
    xlabel('L (mm)');
    ylabel('Persitence Length, Lp (mm)');
    [maxLp_temp, I_maxLp] = max(Lp_Parameters{i}(:,5));
    maxLp{i}(:,1) = Lp_Parameters{i}(I_maxLp,2);
    maxLp{i}(:,2) = maxLp_temp;
    title(strcat(num2str(index),' Lp; Max = ',num2str(maxLp{i}(:,2)),'mm at L=  ',num2str(maxLp{i}(:,1)),'mm.png'));
    out = fullfile(dirpath,LpFigname);
    saveas(Lpfigure, out); 
end

display(maxLp)
