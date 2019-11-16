function [ISD, notConverged, means, PoE] = driftsExtract(dir, buildingName, code, noFloors, floorHeight, IML, ISDthreshold, print, stoGlo)
%% IMPORT ALL DRIFTS | EACH FLOOR PER PAGE
switch stoGlo
    case 'local'
        storeis = [1 : noFloors];
    case 'global'
        storeis = [1 noFloors];
end

for i = storeis
    disp_x_in = importdata([dir '\disp_' buildingName '_' code '_x_' num2str(i) '.txt']);
    disp_x (:,:,i) = disp_x_in.data ;
    clear disp_x_in
    disp_y_in = importdata([dir '\disp_' buildingName '_' code '_y_' num2str(i) '.txt']);
    disp_y (:,:,i) = disp_y_in.data ;
    clear disp_y_in
end

timeNrecs = size(disp_x ,2);
%clear buildingName code
%% CALCULATE THE INTER-STORY DRIFT: ISD BEING [IML, RECORD, ISD]
ISD = [];
for i = 2 : 2 : timeNrecs
    recordLength = sum(~isnan(disp_x(:,i,1)));
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
                    interStoryDrift(k, j+1) = sqrt(dif_x ^2 + dif_y ^2);
                end
            case 'global'
                j = noFloors;
        end
        dif_x = disp_x(k, i, j);
        dif_y = disp_y(k, i, j);
        interStoryDrift(k, j+1) = sqrt(dif_x ^2 + dif_y ^2);
    end
    
    maxISDrift = max(max(interStoryDrift(:, [2: noFloors+1])));%maxISDrift = max(max(interStoryDrift(:, [2: noFloors+1]),[],1));
    ISD(end+1,[2 3]) = [i/2 , maxISDrift / (floorHeight*noFloors)]; %until this point ISD is just space-displacement, avoiding a costly calculus
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
%% THE ONES THAT DIDN'T CONVERGED aka also dead give it a value to make it exceed!
notConverged = [];
for i = 1 : noRecs
    nSeismicRec = importdata(sprintf('records_info\\rec_%d_dir1.txt',i));
    seismoRecSize = size(nSeismicRec,1);
    recordLength = sum(~isnan(disp_x(:, 2*i,1)));
    if (seismoRecSize - 10) > recordLength %|| max(abs(disp_x(:,2*i,10))) >
%         ISD(ISD(:,2) == i, :) = [];
        ISD(ISD(:,2) == i, 3) = 2 * ISDthreshold;
        notConverged = [notConverged, i];
    end
end

% notConverged = setxor([1:noRecs]', ISD(:,2));

ISD = sortrows(ISD, [1 3]);
clear disp_x noRecs nSeismicRec recordLength seismoRecSize
%% CALCULATE THE PROBABILITY OF EXCEDENCE
for i = 1 : length(IML)
    aux = ISD(ISD(:,1) == IML(i), [1 3]);
    exceed = sum(aux(:,2) > ISDthreshold);
    PoE(i,:) = [IML(i),  exceed/size(aux,1)];
end
%% PLOT
means = IML' ;
for i = 1 : length(IML)
    means(i, 2) = mean(ISD(ISD(:,1) == IML(i),3));
end

% hold on
% scatter(ISD(:,1), ISD(:,3), 'b');
% scatter(means(:,1), means(:,2), 'filled','o r');
% xticks (IML);
% title([upper(buildingName(1)) lower(buildingName(2:end)) ' ' code]);
% xlabel('IML');
% ylabel('ISD');
% switch print
%     case 'print'
% %         print([upper(buildingName(1)), lower(buildingName(2:end)), ' ', code],'-dpng');
% end
% hold off