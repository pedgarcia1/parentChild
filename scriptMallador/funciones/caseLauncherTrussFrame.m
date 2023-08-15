% Case launcher
clear; close all; 

%% Structure definition
structuralJointsArray=[ 0 0 0          % In [mm]
                        0 2 0
                        0 0 2
                        0 2 2]*1000; %For direction only

% Input of members connecting joints and which dof they connect
% Begin | End | Cross Section Orientation
structuralMembersArray.nodes=[1 2 4 
                              2 3 4
                              1 3 4];
% Connected Dof                          
structuralMembersArray.dof=true(size(structuralMembersArray.nodes,1),12);

% Number of elements in member
structuralMembersArray.refinement=ones(size(structuralMembersArray.nodes,1));

% Member cross section number
structuralMembersArray.crossSection=ones(size(structuralMembersArray.nodes,1));

% Member material number
structuralMembersArray.material=ones(size(structuralMembersArray.nodes,1));
                    
% Cross sections definition
% Area | Inertia Moment in P123 plane | Inertia Moment orthogonal to P123 plane | Torsional Stiffness
membersCrossSection = [pi*20^2 pi*20^4/4 pi*20^4/4 pi*20^4/2];

% Material definition
% Young Modulus | Transverse Modulus | Density 
membersMaterial=[200000 76923 7800]; %MPa kg/m3 Steel

% Structure plot
linearMeshPlot(structuralMembersArray.nodes(:,1:2),structuralJointsArray,'b','Yes');
             
%% Preprocess
% Mesh generation
[elementArray,nodesPositionArray]=trussFrameMeshGenerator(structuralMembersArray,structuralJointsArray);

% Problem parameters
nElements=size(elementArray.nodes,1);    %Number of elements
nNodes=size(nodesPositionArray,1);       %Number of nodes
nTotalDof=max(max(elementArray.dof));    %Number of total dofs

% Boundary conditions
boundaryConditionsArray = false(nNodes,6);    % Boundary conditions array true=fixed
boundaryConditionsArray(3,1:3) = true;
boundaryConditionsArray(1,2)   = true;
boundaryConditionsArray(:,[4 5 6]) = true;    % Rotations elimination

% Load definition
pointLoadsArray = zeros(nNodes,6);     % Point load nodal value for each direction
pointLoadsArray(2,2) = -2000;

%% Solver

% Stiffness calculation and assembly
[stiffnessMatrix]=assemble1DStiffnessMatrix(elementArray,nodesPositionArray,structuralJointsArray,membersCrossSection,membersMaterial);

% Matrix reduction
isFixed = reshape(boundaryConditionsArray',1,[])';
isFree = ~isFixed;

% Loads vector rearrangement
loadsVector = reshape(pointLoadsArray',1,[])';

% Equation solving
displacementsReducedVector = stiffnessMatrix(isFree,isFree)\loadsVector(isFree);

% Reconstruction
displacementsVector = zeros(nTotalDof,1);
displacementsVector(isFree) = displacementsVector(isFree) + displacementsReducedVector;

%% Postprocess
magnificationScale=10000;

% Nodal displacements rearranged
nodalDisplacements=reshape(displacementsVector,6,size(nodesPositionArray,1))';
nodalPositions=nodesPositionArray+nodalDisplacements(:,1:3)*magnificationScale;

% Deformed Structure plot
linearMeshPlot(elementArray.nodes(:,1:2),nodalPositions,'r','No');
