%% ------------------------------------------------------------------------
%  Kidnapped Vehicle - Particle Filter Visualization
%  By: Chris Gundling, chrisgundling@gmail.com
% -------------------------------------------------------------------------

%% Program description
%--------------------------------------------------------------------------
%  This program creates a movie of a particle filter implementation to 
%  Localize a vehicle. The particle filter code was implemented in C++ and
%  is run seperately. Once the particles at each timestep are written out,
%  this program can be used to visualize the particles and observations.
%  The observations have only been transformed to the ground truth
%  positions at each time step (rather than to each particle).
%  Number of particles is 100.

%% Initialize workspace
%--------------------------------------------------------------------------
clear all;
close all;
clc;

%% Read in all data
%--------------------------------------------------------------------------
landmarks = readtable('map_data.txt','Delimiter','tab','ReadVariableNames',false);
particles = readtable('output_data.txt','Delimiter',' ','ReadVariableNames',false);
gt_data = readtable('gt_data.txt','Delimiter',' ','ReadVariableNames',false);
vel = readtable('control_data.txt','Delimiter',' ','ReadVariableNames',false);
observation_files;

%% Loop through all time steps and save frames
%--------------------------------------------------------------------------
M = [];
figure(1)
for i = 1:length(gt_data.Var1)
    
    % Dummy legend
    x1 = linspace(390,400,10);
    y1 = linspace(390,400,10);
    plot(x1,y1,'bs','LineWidth',1,'MarkerFaceColor','k','MarkerSize',5)
    hold on;
    plot(x1,y1,'ko','LineWidth',.5,'MarkerFaceColor','r','MarkerSize',5)
    plot(x1,y1,'go','LineWidth',1,'MarkerFaceColor','g','MarkerSize',3)
    plot(x1,y1,'k--','LineWidth',0.5)
    plot(x1,y1,'m-','LineWidth',1)
    legend('Landmarks','Particles','GroundTruth(current)','GroundTruth(path)','Observations');
    xlabel('X Coordinate');
    ylabel('Y Coordinate');
    title('LOCALIZATION PARTICLE FILTER')
    grid on;

    % Load observations and transform to map coordinate frame
    observations = readtable(obs(i,:),'Delimiter',' ','ReadVariableNames',false);
    obs_x = gt_data.Var1(i) + observations.Var1 * cos(gt_data.Var3(i)) - observations.Var2 * sin(gt_data.Var3(i));
    obs_y = gt_data.Var2(i) + observations.Var1 * sin(gt_data.Var3(i)) + observations.Var2 * cos(gt_data.Var3(i));

    % Plot the landmarks 
    plot(landmarks.Var1,landmarks.Var2,'bs','LineWidth',1,'MarkerFaceColor','k','MarkerSize',5)

    % Plot the initial particles
    if i == 1
        plot(particles.Var1(1:100),particles.Var2(1:100),'ko','LineWidth',.5,'MarkerFaceColor','r','MarkerSize',5)
    end

    % Ground truth vehicle position and path
    if i == 1
        plot(gt_data.Var1(1),gt_data.Var2(1),'go','LineWidth',1,'MarkerFaceColor','g','MarkerSize',3)
    end
    plot(gt_data.Var1(1:i),gt_data.Var2(1:i),'k--','LineWidth',.5);

    % Create annotation of timestep
    time_str = num2str(i-1);
    time_str = strcat(time_str);
    dim = [.15 .43 .3 .3];
    str = strcat('TimeStep:  ',time_str);
    annotation('textbox',dim,'String',str,'FitBoxToText','on');
    
    % Global initial axis
    axis([-100 300 -120 60]); 
    
    % Set dynamic axis after timestep 60
    if i > 60
        axis([gt_data.Var1(i)-50 gt_data.Var1(i)+50 gt_data.Var2(i)-50 gt_data.Var2(i)+50]);
    end
    
    % Create ZOOM IN/OUT annotations along with axis changes for clarity
    if i > 60 && i < 120 || i > 260 && i < 340 || i > 460 && i < 540 || i > 660 && i < 740 || i > 860 && i < 940 || i > 1060 && i < 1140
        dim = [.15 .5 .3 .3];
        str = strcat('ZOOM IN');
        annotation('textbox',dim,'String',str,'FitBoxToText','on');
        axis([gt_data.Var1(i)-1 gt_data.Var1(i)+1 gt_data.Var2(i)-1 gt_data.Var2(i)+1]);
    end
    
    if i >= 120 && i < 140 || i >= 340 && i < 360 || i >= 540 && i < 560 || i >= 740 && i < 760 || i >= 940 && i < 960 || i >= 1140 && i < 1160
        dim = [.15 .5 .3 .3];
        str = strcat('ZOOM OUT');
        annotation('textbox',dim,'String',str,'FitBoxToText','on');
    end

    % Particle positions and velocities (if using quiver)
    x = particles.Var1(1+100*i:100+100*i);
    y = particles.Var2(1+100*i:100+100*i);
    %u = vel.Var1(i)*cos(particles.Var2(1+100*i:100+100*i));
    %v = vel.Var1(i)*sin(particles.Var2(1+100*i:100+100*i)); 
    
    % Choose regular or quiver plot for particles
    plot(x,y,'ko','LineWidth',.5,'MarkerFaceColor','r','MarkerSize',5)
    %quiver(x,y,u,v,'Color','red','LineWidth',2)
    plot(gt_data.Var1(i),gt_data.Var2(i),'go','LineWidth',1,'MarkerFaceColor','g','MarkerSize',5)
    
    % Plot observations if length less than or equal to sensor range = 50 
    for j = 1:length(obs_x)
        if sqrt((gt_data.Var1(i)-obs_x(j))^2 + (gt_data.Var2(i)-obs_y(j))^2) <= 50
            line_x = [gt_data.Var1(i) obs_x(j)];
            line_y = [gt_data.Var2(i) obs_y(j)];
            plot(line_x,line_y,'m','LineWidth',1)
        end      
    end
    hold off;
    
    F = getframe(gcf);
    M = [M; F];
    clf('reset')
end

%% Play the movie
%--------------------------------------------------------------------------
[h, w, p] = size(F.cdata);  % use 1st frame to get dimensions
hf = figure; 
set(hf, 'position', [150 150 w h]);
axis off
movie(M,1,30);