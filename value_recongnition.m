clc
clear all

jp = '.jpg';
suf = 'a';

nof = 1544; %Number of photos
values = zeros(8,nof);
invalid = zeros(0,1);

fail = false;

for index = 8:20 % Range of photos to analyze

% Constructeing file name 
fidx = num2str(index);
fname = strcat(fidx,jp); 

i = imread(fname);
ic = imcrop(i, [1270 25 1775 1770]); 

ig = rgb2gray(ic); 


%Dice processing
level1 = 0.70;
dice1 = im2bw(ig, level1);

se1 = strel('disk', 9);
dice2 = imopen(dice1, se1);

dice3 = imfill(dice2,'holes');


bw1 = im2uint8(dice3);
D = -bwdist(~bw1);
mask = imextendedmin(D,2);
D2 = imimposemin(D,mask);
Ld2 = watershed(D2);
iDice = bw1;
iDice(Ld2 == 0) = 0;


%Dots processing
level2 = 0.75;
dots1 = im2bw(ig, level2);

se2 = strel('disk',8);
dots2 = imopen(dots1, se2);


icomp = imcomplement(dots2);
iopenned1 = bwselect(icomp,1,1,4);
dots3 = imcomplement(dots2|iopenned1);


bw2 = im2uint8(dots3);
D = -bwdist(~bw2);
mask = imextendedmin(D,2);
D2 = imimposemin(D,mask);
Ld2 = watershed(D2);
iDots = bw2;
iDots(Ld2 == 0) = 0;

% Dots recognition
iregionDots = regionprops(iDots, 'centroid');
[labeledDots,numObjectsDots] = bwlabel(iDots, 4);
statsDots = regionprops(labeledDots,'Eccentricity','Area','BoundingBox');
areasDots = [statsDots.Area];
eccentricitiesDots = [statsDots.Eccentricity];
idxOfDots = find(eccentricitiesDots);
statsDefectsDots = statsDots(idxOfDots);

%Dice recognition
iregionDice = regionprops(iDice, 'centroid');
[labeledDice,numObjectsDice] = bwlabel(iDice, 4);
statsDice = regionprops(labeledDice,'Eccentricity','Area','BoundingBox');
areasDice = [statsDice.Area];
eccentricitiesC = [statsDice.Eccentricity];
idxOfDice = find(eccentricitiesC);
statsDefectsDice = statsDice(idxOfDice);

h = figure(1);
imshow(ic);
title(fname);
hold on;

% Postprocessing
dots2remove = zeros(1,0);
for idx = 1 : length(idxOfDots)
    if ((statsDefectsDots(idx).BoundingBox(3) > 17 && statsDefectsDots(idx).BoundingBox(3) < 46) && (statsDefectsDots(idx).BoundingBox(4) > 17 && statsDefectsDots(idx).BoundingBox(4) < 46))
        h = rectangle('Position',statsDefectsDots(idx).BoundingBox,'LineWidth',2);
        set(h,'EdgeColor',[.75 0 0]);
        hold on;
    else
        dots2remove(1,end+1) = idx;
    end
end
statsDefectsDots(dots2remove, :) = [];

dice2remove = zeros(1,0);
for idx = 1 : length(idxOfDice)
    if ((statsDefectsDice(idx).BoundingBox(3) > 170 && statsDefectsDice(idx).BoundingBox(3) < 250) && (statsDefectsDice(idx).BoundingBox(4) > 170 && statsDefectsDice(idx).BoundingBox(4) < 250))
        h = rectangle('Position', statsDefectsDice(idx).BoundingBox, 'LineWidth',2);
        set(h,'EdgeColor',[0 .75 0]);
        hold on;
    else        
        dice2remove(1, end+1) = idx;
    end    
end
statsDefectsDice(dice2remove,:) = [];
hold off;


pause(0.01);

if (length(statsDefectsDice) == 6 && length(statsDefectsDots) <=36)
    for i = 1:length(statsDefectsDice)
        k = 0;
        for j = 1: length(statsDefectsDots)
            centerX = statsDefectsDots(j).BoundingBox(1) + statsDefectsDots(j).BoundingBox(3) / 2;
            centerY = statsDefectsDots(j).BoundingBox(2) + statsDefectsDots(j).BoundingBox(4) / 2;
        
            if ((centerX > statsDefectsDice(i).BoundingBox(1)) && centerX < (statsDefectsDice(i).BoundingBox(1) + statsDefectsDice(i).BoundingBox(3))) && ((centerY > statsDefectsDice(i).BoundingBox(2)) && centerY < (statsDefectsDice(i).BoundingBox(2) + statsDefectsDice(i).BoundingBox(4)))
                k = k+1;
            end
        end
        if k <=6 && k>0
            values(i,index) = k;
        else
            fail = true;    
        end

    if fail ~= false
       
    end
    end
else
    fail = true;
end
if fail == true
    invalid(end+1,1) = index;
    fail = false;
end
figure(2);
hold off;
histdata = values(1:6,:);
histdata = histdata(:);
histdata(any(histdata == 0,2),:) = [];
hist(histdata,[1,2,3,4,5,6]);
disp(transpose(values((1:6),index)));
close(1);
end

% file = fopen('data.txt', 'wt');
% fprintf(file, '%d;%d;%d;%d;%d;%d;%d;%d\n', values);
% fclose(file);

