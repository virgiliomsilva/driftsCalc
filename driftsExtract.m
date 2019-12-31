function [ISD, notConverged, means, PoE] = driftsExtract(dir, buildingName, code, noFloors, floorHeight, IML, ISDthreshold, print, stoGlo)
%% IMPORT ALL DRIFTS | EACH FLOOR PER PAGE
switch stoGlo
    case 'local'
        storeis = [1 : noFloors];
    case 'global'
        storeis = noFloors;
end

for i = storeis
    disp_x_in = importdata([dir '\disp_' buildingName '_' code '_x_' num2str(i) '.txt']);
    disp_x (:,:,i) = disp_x_in.data ;
    clear disp_x_in
    disp_y_in = importdata([dir '\disp_' buildingName '_' code '_y_' num2str(i) '.txt']);
    disp_y (:,:,i) = disp_y_in.data ;
    clear disp_y_in
end

% gravar 2019/12/05
% save([buildingName '_' code '_XX'],'disp_x')
% save([buildingName '_' code '_YY'],'disp_y')

% disp_x = importdata([buildingName '_' code '_XX' '.mat']);
% disp_y = importdata([buildingName '_' code '_YY' '.mat']);

timeNrecs = size(disp_x ,2);
%% CALCULATE THE INTER-STORY DRIFT: ISDall BEING [IML, RECORD, ISD]
ISDall = [];
for i = 2 : 2 : timeNrecs%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    recordLength = sum(~isnan(disp_x(:,i, noFloors)));
    interStoryDrift = [disp_x([1:recordLength], i-1), zeros(recordLength, noFloors)];
    for k = 1 : recordLength
        switch stoGlo
            case 'local'
                %ground floor
                interStoryDrift(k,2) = sqrt(disp_x(k, i, 1) ^ 2 + disp_y(k, i, 1) ^ 2);
                %other floors
                for j = 2 : noFloors 
                    dif_x = disp_x(k, i, j - 1) - disp_x(k, i, j);
                    dif_y = disp_y(k, i, j - 1) - disp_y(k, i, j);
                    interStoryDrift(k, j+1) = sqrt(dif_x ^2 + dif_y ^2) / floorHeight;
                end
                
            case 'global'
                j = noFloors;
                dif_x = disp_x(k, i, j);
                dif_y = disp_y(k, i, j);
                interStoryDrift(k, j+1) = sqrt(dif_x ^2 + dif_y ^2) / (floorHeight*noFloors);
        end
    end
    
    maxISDrift = max(max(interStoryDrift(:, [2: noFloors+1])));
    ISDall(end+1,[2 3]) = [i/2 , maxISDrift];
end

noIML = length(IML); noRecs = timeNrecs / 2;
recsPerIntensity = noRecs/ noIML;
for i = 1 : noIML
    for j = 1 : recsPerIntensity
        ISDall(recsPerIntensity*(i-1)+j, 1) = IML(i);
    end
end

clear dif_x dif_y disp_y height interStoryDrift j k maxISDrift noIML ...
    recsPerIntensity timeNrecs

%% THE ONES THAT DIDN'T CONVERGED aka also dead give it a value to make it exceed!
notConverged = [];
for i = 1 : noRecs
    nSeismicRec = importdata(sprintf('records_info\\rec_%d_dir1.txt',i));
    seismoRecSize = size(nSeismicRec,1);
    recordLength = sum(~isnan(disp_x(:, 2*i, noFloors)));
    if (seismoRecSize - 10) > recordLength  || (strcmp(buildingName,'tenerPT') && strcmp(code, 'DC2') && i == 125)
        ISDall(ISDall(:,2) == i, 3) = 100; 
        notConverged = [notConverged, i];
    end
end

ISDall = sortrows(ISDall, [1 3]);
clear disp_x noRecs nSeismicRec recordLength seismoRecSize noFloors ...
    buildingName code

%% CALCULATE THE PROBABILITY OF EXCEDENCE accounting for non converged ones
for i = 1 : length(IML)
    aux = ISDall(ISDall(:,1) == IML(i), [1 3]);
    exceed = sum(aux(:,2) > ISDthreshold);
    PoE(i,:) = [IML(i),  exceed/size(aux,1)];
end

%% ELIMINATE THE NON CONVERGED IN ORDER TO CALCULATE THE MEANS 
converged = setxor(notConverged, ISDall(:,2));
ISD = [];
for i = converged'
    ISD = [ISD; ISDall(ISDall(:,2) == i,:)];
end

%% MEANS
means = unique(ISD(:,1)); 
for i = 1 : length(means)
    means(i, 2) = mean(ISD(ISD(:,1) == means(i), 3));
end