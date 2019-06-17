% example caller
clear
clc
tic
buildingName = 'regular';
code = 'EC2' ; 
noFloors = 5;
height = 2.8;
IML = [.05, .1, .3, .5, .75, 1, 1.25, 1.5, 1.75, 2];
% IML = [.05, 2];

toc

[ISDmatrix, notConvergedRecords, IMLisd] = driftsExtract(buildingName, code, noFloors, height, IML);

toc