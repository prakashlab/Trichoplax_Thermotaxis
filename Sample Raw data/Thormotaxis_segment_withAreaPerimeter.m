close all;
clc;
clear all;


firsttrial = 37;
lasttrial =37;
index = firsttrial;

while index <= lasttrial
    nomovement_index = 1;
    done_moving = 0;
    close all;
    
    
    folder = strcat('/Users/ilikecookiee/Documents/GitHub/Trichoplax_Thermotaxis/Sample Raw data/',num2str(index));
    filePattern = fullfile(folder, '*.tif');
    myFiles = dir(filePattern); % the folder inwhich ur images exists

    numhours = 24;
    numframes = 3600/30*numhours;

    numemptyfiles = 0;

    for k = 1 : length(myFiles)
    %for k = 1 : 50 %uncomment for debugging
        if  myFiles(k).name(1)=='.'
            numemptyfiles = numemptyfiles+1;
            continue;
        else
            break;
        end
    end 

    %initialize centroid array and beginning coordinate and update numframes to
    %account for empty files
    firstframe = numemptyfiles+1;
    lastframe = numframes + firstframe;
    %centroid_coord{index}(1:numframes, 1:2) = 0;
    beginning = [0,0];
    
    %first make sure the particle is identified in the first frame
    fullFileName = fullfile(myFiles(firstframe).folder, myFiles(firstframe).name);
    I = imread(fullFileName);
    %crop out the LEDs
    [I,cropsettings] = imcrop(I);
 
    cam4 = input('Cam4 (y/n)? ', 's');
    if cam4 ~= 'y'
        I = imcomplement(I);
    end
    for testsensitivity = 0.1:0.02:1
        bw1 = imbinarize(I,'adaptive','ForegroundPolarity','bright','Sensitivity',testsensitivity);
        bw = bwareaopen(bw1,100);
        bigBlobs = bwareaopen(bw, 5000);
        bw = bw - bigBlobs;  
        cc = bwconncomp(bw,8);
        if cc.NumObjects == 1
            break;
        end
    end
    
    figure,imshow(I)
    figure,imshow(bw)
    display(strcat('#objects = ', num2str(cc.NumObjects)));
    nextstep = input('Next step? y for continue, c for more contrast, d for dark, r for redo crop, a for adjust param, s for skip, e for plot and exit: ', 's');
    

    if nextstep == 'c'
        I = imadjust(I);
        for testsensitivity = 0.1:0.05:1
            bw1 = imbinarize(I,'adaptive','ForegroundPolarity','bright','Sensitivity',testsensitivity);
            bw = bwareaopen(bw1,100);
            bigBlobs = bwareaopen(bw, 5000);
            bw = bw - bigBlobs;  
            cc = bwconncomp(bw,8);
            if cc.NumObjects == 1
                break;
            end
        end
        figure,imshow(I)
        figure,imshow(bw)
        display(strcat('#objects = ', num2str(cc.NumObjects)));
        secondtime = input('y for continue, s for skip, r for redo crop: ', 's');
        if secondtime == 's'
            index  = index + 1;
            continue;
        elseif secondtime == 'r'
            continue;
        end
    
    elseif nextstep == 'd'
        for testsensitivity = 0.1:0.02:1
            bw1 = imbinarize(I,'adaptive','ForegroundPolarity','dark','Sensitivity',testsensitivity);
            bw = bwareaopen(bw1,100);
            bigBlobs = bwareaopen(bw, 5000);
            bw = bw - bigBlobs;  
            cc = bwconncomp(bw,8);
            if cc.NumObjects == 1
                break;
            end
        end
    
        figure,imshow(I)
        figure,imshow(bw)
        display(strcat('#objects = ', num2str(cc.NumObjects)));
        secondtime = input('y for continue, s for skip, r for redo crop: ', 's');
        if secondtime == 's'
            index  = index + 1;
            continue;
        elseif secondtime == 'r'
            continue;
        end
    elseif nextstep == 'r'
        close all;
        continue;
    elseif nextstep == 'e'
        close all;
        break;
    elseif nextstep == 'a'
        goodparam = 0;
        while goodparam == 0
            s = input('sensitivity: ');
            if (s<=0) || (s>1)
                continue;
            end
            low = input('size lower threshold: ');
            high = input('size higher threshold: ');
            bw = imbinarize(I, 'adaptive', 'ForegroundPolarity','bright','Sensitivity',s);
            bw = bwareaopen(bw,low);
            bigBlobs = bwareaopen(bw, high);
            bw = bw - bigBlobs;
            figure,imshow(bw)
            cc = bwconncomp(bw,8);
            display(strcat('#objects = ', num2str(cc.NumObjects)));
            adjust_again = input('r for redo crop, a for adust parameters, y for yes,s for skip, e for exit: ', 's');
            if adjust_again == 'a'
                continue;
            elseif adjust_again == 'r'
                break;
            elseif adjust_again == 'e'
                break;
            elseif adjust_again == 's'
                break;
            end
                
            goodparam = 1;
        end
        if adjust_again == 'r'
            continue;
        elseif adjust_again == 's'
            index = index + 1;
            continue;
        elseif adjust_again == 'e'
            break;
        end
    end
 %{   
    if k == firstframe && cc.NumObjects ~= 1
        I = imadjust(I);
        for testsensitivity = 0.1:0.05:1
            bw1 = imbinarize(I,'adaptive','ForegroundPolarity','bright','Sensitivity',testsensitivity);
            bw = bwareaopen(bw1,100);
            bigBlobs = bwareaopen(bw, 5000);
            bw = bw - bigBlobs;  
            cc = bwconncomp(bw,8);
            if cc.NumObjects == 1
                break;
            end
        end
    end 


    if k == firstframe && cc.NumObjects ~= 1
        se = strel('disk',30)
        background = imopen(I,se);
        I2 = I - background;
        figure,imshow(I2)
        I3 = imadjust(I2);
        bw = imbinarize(I2);
        cc = bwconncomp(bw,8);
        break;
    end
  %}  
    
    %initial settings
    low = 100;
    high = 5000;
    s = testsensitivity;
    k = firstframe; 
    adjust_again = 'z';
    new_origin_index = 0;
    change_origin = 0;
    
    
    while k <= lastframe
        
    %for k = 1 : 50 %uncomment for debugging

        %{
        if  myFiles(k).name(1)=='.'
            continue;
        end
        %}

        fullFileName = fullfile(myFiles(k).folder, myFiles(k).name);
        I = imread(fullFileName);
        I2 = imcrop(I,cropsettings);
        if cam4 ~= 'y'
            I2 = imcomplement(I2);
        end

        %{
        The other method of bcg subtraction
        se = strel('disk',30)
        background = imopen(I,se);
        I2 = I - background;
        figure,imshow(I2)
        I3 = imadjust(I2);
        bw = imbinarize(I2);
        %}
        
        
       
        
        bw1 = imbinarize(I2,'adaptive','ForegroundPolarity','bright','Sensitivity',s);
        bw = bwareaopen(bw1,low);
        bigBlobs = bwareaopen(bw, high);
        bw = bw - bigBlobs;  
        cc = bwconncomp(bw,8);

        
        if (cc.NumObjects ~= 1) && (done_moving ~= 1)
            close all;
            figure,imshow(I2)
            
            goodparam = 0;
            while goodparam == 0
                s = input('sensitivity: ');
                if (s<=0) || (s>1)
                    continue;
                end
                low = input('size lower threshold: ');
                high = input('size higher threshold: ');
                bw = imbinarize(I2, 'adaptive', 'ForegroundPolarity','bright','Sensitivity',s);
                bw = bwareaopen(bw,low);
                bigBlobs = bwareaopen(bw, high);
                bw = bw - bigBlobs;
                figure,imshow(bw)
                cc = bwconncomp(bw,8);
                display(strcat('#objects = ', num2str(cc.NumObjects)));
                adjust_again = input('p for pick object, d for done moving, r for redo crop, a for adust parameters, y for yes, s for skip frame: ', 's');
                if adjust_again == 'a'
                    continue;
                elseif adjust_again == 'p'
                    break;
                elseif adjust_again == 'r'
                    break;
                elseif adjust_again == 'd'
                    break;
                elseif adjust_again == 's'
                    break;
                end

                goodparam = 1;
            end
            if adjust_again == 'r'
                [I,cropsettings] = imcrop(I);
                new_origin_index = k - 1;
                change_origin = 1;
                continue;
            elseif adjust_again == 'd'
                done_moving = 1;
                centroid_coord{index}(k-numemptyfiles,:) = centroid_coord{index}(k-numemptyfiles-1,:);
                nomovement_times{index}(nomovement_index) = k*3/360;
                nomovement_index = nomovement_index + 1;
                change_origin = 0;
                k = k+1;
                break;
            elseif adjust_again == 's'
                centroid_coord{index}(k-numemptyfiles,:) = centroid_coord{index}(k-numemptyfiles-1,:);
                nomovement_times{index}(nomovement_index) = k*3/360;
                nomovement_index = nomovement_index + 1;
                change_origin = 0;
                k = k+1;
                continue;
            elseif adjust_again ~= 'y' && adjust_again ~= 'p'
                continue;
            end

        elseif (cc.NumObjects ~= 1) || (done_moving == 1)
            centroid_coord{index}(k-numemptyfiles,:) = centroid_coord{index}(k-numemptyfiles-1,:);
            nomovement_times{index}(nomovement_index) = k*3/360;
            nomovement_index = nomovement_index + 1;
            k = k+1;
            continue;
        end
        %find centroid 
        
        if adjust_again == 'e'
            break;
        end
        

        
        if adjust_again == 'p'
            objects = regionprops(cc,'Centroid');
            for n = 1:length(objects)
                display(objects(n))
            end
            whichobj = input('Object number: ');
            cent = objects(whichobj);
            cent = cell2mat(struct2cell(cent));
            centwritetemp = regionprops(cc,'Centroid','Area','Perimeter');
            centwrite = centwritetemp(whichobj);
            centwrite = cat(2, centwrite.Centroid, centwrite.Area, centwrite.Perimeter);
            adjust_again = 'y';
        else
            cent = regionprops(cc,'Centroid');
            cent = cell2mat(struct2cell(cent));
            centwrite = regionprops(cc,'Centroid','Area','Perimeter');
            centwrite = cat(2, centwrite.Centroid, centwrite.Area, centwrite.Perimeter);
        end

        sizecent = size(cent);
        
        
        if change_origin == 1
            fullFileName = fullfile(myFiles(new_origin_index).folder, myFiles(new_origin_index).name);
            I = imread(fullFileName);
            I2 = imcrop(I,cropsettings);
            if cam4 ~= 'y'
                I2 = imcomplement(I2);
            end    
            bw1 = imbinarize(I2,'adaptive','ForegroundPolarity','bright','Sensitivity',s);
            bw = bwareaopen(bw1,low);
            bigBlobs = bwareaopen(bw, high);
            bw = bw - bigBlobs;  
            cc = bwconncomp(bw,8);
            beginning_new = regionprops(cc,'Centroid');
            beginning_new = cell2mat(struct2cell(beginning_new));
            beginning(1:2) = beginning_new - centroid_coord{index}(new_origin_index-numemptyfiles,1:2);
            beginning(3:4) = centroid_coord{index}(new_origin_index-numemptyfiles,3:4);
            change_origin = 0;
            display(beginning)
        end

        %subtract beginning coord to make everything start at origin
        if k == firstframe
            beginning = centwrite;
            display(beginning)
            centwrite(1) = centwrite(1)-beginning(1);
            centwrite(2) = centwrite(2)-beginning(2);
        else
            centwrite(1) = centwrite(1)-beginning(1);
            centwrite(2) = centwrite(2)-beginning(2);
        end
        centroid_coord{index}(k-numemptyfiles,:) = centwrite;

        
        k = k + 1;
    end
    centroid_coord{index}(:,2) = -centroid_coord{index}(:,2);
    csvwrite(strcat('exp',num2str(index),'withsizeinfo.txt'),centroid_coord{index})
    
    f1 = figure;
    colors = linspace(0,length(centroid_coord{index})*3/360,length(centroid_coord{index}));
    sz = 30;
    scatter(centroid_coord{index}(:,1), centroid_coord{index}(:,2),sz,colors,'filled')
    title('Position; colorbar is time');
    xlim([-400,400]);
    ylim([-400,400]);
    colorbar
    f2 = figure;
    timescale = linspace(0,length(centroid_coord{index})*3/360,length(centroid_coord{index}));
    scatter(timescale, centroid_coord{index}(:,3),'filled');
    title('Area');
    f3 = figure;
    scatter(timescale, centroid_coord{index}(:,4),'filled');
    title('Perimeter');
    f4 = figure;
    scatter(timescale, centroid_coord{index}(:,3)./centroid_coord{index}(:,4),'filled');
    title('Area/Perimeter');
    f5 = figure;
    colors = centroid_coord{index}(:,3);
    scatter(centroid_coord{index}(:,1), centroid_coord{index}(:,2),sz,colors,'filled')
    colorbar;
    title('Position; colorbar is size');
    mkdir(strcat('exp',num2str(index),'Figs'))
    
    saveas(f1,[pwd strcat('/exp',num2str(index),'Figs/positioncoloredbytime.png')]);
    saveas(f2,[pwd strcat('/exp',num2str(index),'Figs/areaovertime.png')]);
    saveas(f3,[pwd strcat('/exp',num2str(index),'Figs/Perimeterovertime.png')]);
    saveas(f4,[pwd strcat('/exp',num2str(index),'Figs/AreaPerimeterRatioovertime.png')]);
    saveas(f5,[pwd strcat('/exp',num2str(index),'Figs/Position Colored by Area.png')]);
    
    
    index = index + 1;

end




