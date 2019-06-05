% function [ISD, notConverged, means ] = driftsExtract(buildingName, code, noFloors, height, IML)
buildingName = 'regular';
code = 'EC2' ; 
noFloors = 5;
height = 2.8;
IML = [.05, .1, .3, .5, .75, 1, 1.25, 1.5, 1.75, 2];
%% IMPORT ALL DRIFTS | EACH FLOOR PER PAGE
for i = 1 : noFloors
    eval(['disp_x_' num2str(i) ' = importdata("input\disp_' buildingName '_' code '_x_' num2str(i) '.txt");']);
    eval(['disp_x (:,:,i) = disp_x_' num2str(i) '.data ;']);
    eval(['clear disp_x_' num2str(i)]);
    eval(['disp_y_' num2str(i) ' = importdata("input\disp_' buildingName '_' code '_y_' num2str(i) '.txt");']);
    eval(['disp_y (:,:,i) = disp_y_' num2str(i) '.data ;']);
    eval(['clear disp_y_' num2str(i)]);
end

timeNrecs = size(disp_x ,2);
clear buildingName code 
%% CALCULATE THE INTER-STORY DRIFT: ISD BEING [IML, RECORD, ISD]
ISD = [];
for i = 2 : 2 : timeNrecs
    recordLength = sum(~isnan(disp_x(:,i,1)));
    interStoryDrift = [disp_x([1:recordLength], i-1), zeros(recordLength, noFloors)];
    for k = 1 : recordLength
        interStoryDrift(k,2) = sqrt(disp_x(k, i, 1) ^ 2 + disp_y(k, i, 1) ^ 2);
        for j = 2 : noFloors
            dif_x = disp_x(k, i, j - 1) - disp_x(k, i, j);
            dif_y = disp_y(k, i, j - 1) - disp_y(k, i, j);
            interStoryDrift(k, j+1) = sqrt(dif_x ^2 + dif_y ^2);
        end
    end
    
    maxISDrift = max(max(interStoryDrift(:, [2: noFloors+1]),[],1));
    ISD(end+1,[2 3]) = [i/2 , maxISDrift / height]; %until this point ISD is just space-displacement, avoiding a costly calculus
end

noIML = length(IML); noRecs = timeNrecs / 2;
recsPerIntensity = noRecs/ noIML;
for i = 1 : noIML
    for j = 1 : recsPerIntensity
        ISD(recsPerIntensity*(i-1)+j, 1) = IML(i);
    end
end

clear dif_x dif_y disp_y height interStoryDrift j k maxISDrift noFloors noIML ...
    recsPerIntensity timeNrecs
%% DELETE THE ONES THAT DIDN'T CONVERGED
for i = 1 : noRecs
    nSeismicRec = importdata(sprintf('records_info\\rec_%d_dir1.txt',i));
    seismoRecSize = size(nSeismicRec,1);
    recordLength = sum(~isnan(disp_x(:, 2*i,1)));
    if (seismoRecSize - 2) > recordLength
        ISD(ISD(:,2) == i, :) = [];
    end
end

notConverged = setxor([1:noRecs]', ISD(:,2));
ISD = sortrows(ISD, [1 3]);
clear disp_x noRecs nSeismicRec recordLength seismoRecSize
%% PLOT
means = IML'
for i = 1 : length(IML)
    means(i, 2) = mean(ISD(ISD(:,1) == IML(i),3));
end

hold on
scatter(ISD(:,1), ISD(:,3), 'b');
scatter(means(:,1), means(:,2), 'filled','o r')
xticks (IML);
hold off