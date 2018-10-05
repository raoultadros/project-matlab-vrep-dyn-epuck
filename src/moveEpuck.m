% Copyright 2006-2013 Dr. Marc Andreas Freese. All rights reserved. 
% marc@coppeliarobotics.com
% www.coppeliarobotics.com
% 
% -------------------------------------------------------------------
% This file is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
% 
% You are free to use/modify/distribute this file for whatever purpose!
% -------------------------------------------------------------------
%
% This file was automatically created for V-REP release V3.0.5 on October 26th 2013

% Make sure to have the server side running in V-REP!
% Start the server from a child script with following command:
%simExtRemoteApiStart(19999) % -- starts a remote API server service on port 19999
% change error code returned -> my be one variable is sufficient (todo)
% write Readme file (todo)
% complete the copyright and info part (todo)

function moveEpuck()
    clc
    clear all
	disp('Program started');

    % call constants into workspace
    mathConstants
    robotConstants
    
    %----- attractive forcelet parameters ---
    % strength of attraction
    lambda_tar = 1;
    
    %----- repulsive forcelets parameters ----
    % overall repulsion strength
    beta1_obs = 0;
    % spatial rate of decay
    beta2_obs = 0;
    % range of the force-let sensor sector
    delta_theta = 45*DEG2RAD; % rad
    
    %----- simulation parameters ----
    % step time
    delta_t = 0.02;
    % time constant
    tau_t = 0.5;
    
    %----- robot's kinematics parameters ----
    % robot velocity
    rob_vel=3;
    
    %----- target information ----
    tar_idx = 1;
    tar_positions= zeros(4, 2);
    tar_nbr=4*ones(1, 4);
    tar_selected=false;
    d_tar=0;
    
    % using the prototype file (remoteApiProto.m)
    vrep=remApi('remoteApi'); 
    
    % just in case, close all opened connections
    vrep.simxFinish(-1); 
    
    % starts a communication thread with the server (i.e. V-REP)
    clientID=vrep.simxStart('127.0.0.1',19999,true,true,5000,5);
  
    % create a clean up object
    cleanupObj = onCleanup(@()cleanMeUp(clientID,vrep));

    if (clientID>-1)
            
        disp('Connected to remote API server');   
        

        
        % specify the simulation timestep
         vrep.simxSetFloatingParameter(clientID, vrep.sim_floatparam_simulation_time_step, ...
             delta_t,  vrep.simx_opmode_oneshot);
        
         
        % retrieve robot handle 
        [err_code,rh]=vrep.simxGetObjectHandle(clientID,'ePuck',vrep.simx_opmode_blocking);
        while (err_code~=vrep.simx_error_noerror)  
            [err_code,rh]=vrep.simxGetObjectHandle(clientID,'ePuck',vrep.simx_opmode_blocking);
        end

        % get robot position
        rob_pos=zeros(1, 2);
        [err_code, rob_pos_vrep]=vrep.simxGetObjectPosition(clientID,rh,-1,vrep.simx_opmode_blocking);
        rob_pos= rob_pos_vrep(1:2); % m
        while (err_code~=vrep.simx_error_noerror)  
            [err_code, rob_pos_vrep]=vrep.simxGetObjectPosition(clientID,rh,-1,vrep.simx_opmode_blocking);
            rob_pos= rob_pos_vrep(1:2); % m
        end
        rob_pos=[0,0];
        tar_positions(4,1:2)=rob_pos;
        
        % get robot orientation
        [err_code, rob_ori_vrep]=vrep.simxGetObjectOrientation(clientID,rh,-1,vrep.simx_opmode_blocking);
        rob_ori= rob_ori_vrep(3); % rad
        while (err_code~=vrep.simx_error_noerror)  
            [err_code, rob_ori_vrep]=vrep.simxGetObjectOrientation(clientID,rh,-1,vrep.simx_opmode_blocking);
            rob_ori= rob_ori_vrep(3); % rad
        end

        % retrieve target1 handle
        th=zeros(1, 3);
        [err_code, th(1)]=vrep.simxGetObjectHandle(clientID,'tarPos1',vrep.simx_opmode_blocking);
        while (err_code~=vrep.simx_error_noerror)  
            [err_code, th(1)]=vrep.simxGetObjectHandle(clientID,'tarPos1',vrep.simx_opmode_blocking);
        end
        
        % retrieve target2 handle
        [err_code, th(2)]=vrep.simxGetObjectHandle(clientID,'tarPos2',vrep.simx_opmode_blocking);
        while (err_code~=vrep.simx_error_noerror)  
            [err_code, th(2)]=vrep.simxGetObjectHandle(clientID,'tarPos2',vrep.simx_opmode_blocking);
        end
        
        % retrieve target3 handle
        [err_code, th(3)]=vrep.simxGetObjectHandle(clientID,'tarPos3',vrep.simx_opmode_blocking);
        while (err_code~=vrep.simx_error_noerror)  
            [err_code, th(3)]=vrep.simxGetObjectHandle(clientID,'tarPos3',vrep.simx_opmode_blocking);
        end
        
        % get target1 position
        [err_code, tar_pos_vrep]=vrep.simxGetObjectPosition(clientID,th(1),-1,vrep.simx_opmode_blocking);
        tar_positions(1,1:2)= tar_pos_vrep(1:2); % m
        while (err_code~=vrep.simx_error_noerror)  
            [err_code, tar_pos_vrep]=vrep.simxGetObjectPosition(clientID,th(1),-1,vrep.simx_opmode_blocking);
            tar_positions(1,1:2)= tar_pos_vrep(1:2); % m
        end
        
        % get target2 position
        [err_code, tar_pos_vrep]=vrep.simxGetObjectPosition(clientID,th(2),-1,vrep.simx_opmode_blocking);
        tar_positions(2,1:2)= tar_pos_vrep(1:2); % m
        while (err_code~=vrep.simx_error_noerror)  
            [err_code, tar_pos_vrep]=vrep.simxGetObjectPosition(clientID,th(2),-1,vrep.simx_opmode_blocking);
            tar_positions(2,1:2)= tar_pos_vrep(1:2); % m
        end
        
        % get target3 position
        [err_code, tar_pos_vrep]=vrep.simxGetObjectPosition(clientID,th(3),-1,vrep.simx_opmode_blocking);
        tar_positions(3,1:2)= tar_pos_vrep(1:2); % m
        while (err_code~=vrep.simx_error_noerror)  
            [err_code, tar_pos_vrep]=vrep.simxGetObjectPosition(clientID,th(3),-1,vrep.simx_opmode_blocking);
            tar_positions(3,1:2)= tar_pos_vrep(1:2); % m
        end

        % retrieve left joint handle
        jh=zeros(1, 2);
        [err_code,jh(1)]=vrep.simxGetObjectHandle(clientID,'ePuck_leftJoint',vrep.simx_opmode_blocking);
        while (err_code~=vrep.simx_error_noerror)  
            [err_code,jh(1)]=vrep.simxGetObjectHandle(clientID,'ePuck_leftJoint',vrep.simx_opmode_blocking);
        end

        % get right joint handle
        [err_code,jh(2)]=vrep.simxGetObjectHandle(clientID,'ePuck_rightJoint',vrep.simx_opmode_blocking);
        while (err_code~=vrep.simx_error_noerror)  
            [err_code,jh(2)]=vrep.simxGetObjectHandle(clientID,'ePuck_rightJoint',vrep.simx_opmode_blocking);
        end 

        % get left joint initial encoder value  
        enc_old=zeros(1, 2);
        enc_new=zeros(1, 2);
        jp=zeros(1, 2);
        [err_code]=vrep.simxSetJointPosition(clientID, jh(1), 0, vrep.simx_opmode_oneshot);
        while (err_code~=vrep.simx_error_noerror) 
                    [err_code]=vrep.simxSetJointPosition(clientID, jh(1), 0, vrep.simx_opmode_oneshot);
        end
        
        [err_code, jp(1)]=vrep.simxGetJointPosition(clientID, jh(1), vrep.simx_opmode_streaming);
        enc_old(1)  =jp(1)*ROBOT_WHEEL_RADUIS; % m
        enc_new(1) =enc_old(1); % m
        while (err_code~=vrep.simx_error_noerror)  
            [err_code, jp(1)]=vrep.simxGetJointPosition(clientID, jh(1), vrep.simx_opmode_streaming);
            enc_old(1)  =jp(1)*ROBOT_WHEEL_RADUIS; % m
            enc_new(1) =enc_old(1); % m
        end  


       % get right joint initial encoder value  
        [err_code]=vrep.simxSetJointPosition(clientID, jh(2), 0, vrep.simx_opmode_oneshot);
        
        while (err_code~=vrep.simx_error_noerror) 
                    [err_code]=vrep.simxSetJointPosition(clientID, jh(2), 0, vrep.simx_opmode_oneshot);
        end
        
        [err_code, jp(2)]=vrep.simxGetJointPosition(clientID, jh(2), vrep.simx_opmode_streaming);
        enc_old(2)  =jp(2)*ROBOT_WHEEL_RADUIS; % m
        enc_new(2) =enc_old(2); % m
        while (err_code~=vrep.simx_error_noerror)  
            [err_code, jp(2)]=vrep.simxGetJointPosition(clientID, jh(2), vrep.simx_opmode_streaming);
            enc_old(2)  =jp(2)*ROBOT_WHEEL_RADUIS; % m
            enc_new(2) =enc_old(2); % m
        end

        % retrieve proximity sensors handles 
        psh = zeros(1, 8);
        for i = 1:8
            [err_code,psh(i)]=vrep.simxGetObjectHandle(clientID,sprintf('%s%d','ePuck_proxSensor',i),vrep.simx_opmode_blocking);
            while (err_code~=vrep.simx_error_noerror)
                [err_code,psh(i)]=vrep.simxGetObjectHandle(clientID,sprintf('%s%d','ePuck_proxSensor',i),vrep.simx_opmode_blocking);
            end
        end

        % set robot initial orientation to 0
       vrep.simxSetObjectOrientation(clientID,rh,-1,[0,0,0],vrep.simx_opmode_oneshot);

        % set robot initial target velocity to 0
        vrep.simxSetJointTargetVelocity(clientID,jh(1),0,vrep.simx_opmode_oneshot);
        vrep.simxSetJointTargetVelocity(clientID,jh(2),0,vrep.simx_opmode_oneshot);
        

        % target selection
        tar_nbr(1,1:3)=randperm(3);
        tar_pos = tar_positions(tar_nbr(tar_idx),:);
        %tar_pos = tar_positions(2,:);

        % enable the synchronous mode    
        vrep.simxSynchronous(clientID,true);
        
        % start vrep simulation
        vrep.simxStartSimulation(clientID,vrep.simx_opmode_blocking);
        
        while (vrep.simxGetConnectionId(clientID)>-1)           
            
            % get left joint encoder value           
            [errc(12), jp(1)]=vrep.simxGetJointPosition(clientID, jh(1), vrep.simx_opmode_blocking); 
            enc_new(1)  = jp(1)*ROBOT_WHEEL_RADUIS; % m 

            % get right joint initial encoder value       
            [errc(13), jp(2)]=vrep.simxGetJointPosition(clientID, jh(2), vrep.simx_opmode_blocking); 
            enc_new(2)  = jp(2)*ROBOT_WHEEL_RADUIS; % m

            % get delta displacements feedback  (position and orientation in the allocentric (world) coordinates frame) 
            [enc_old, delta_pos, delta_phi] = getDeltaPosAllo(enc_old, enc_new, rob_ori);

            % current robot orinetation
            rob_ori = rob_ori + delta_phi; % rad
                        
            % current robot position
            rob_pos = rob_pos + delta_pos; % m
          
            % compute the direction and distance to target
            [psi_tar, d_tar] = getPsi(rob_pos, tar_pos);
ps=psi_tar*RAD2DEG;
tar_pos;
rob_pos;
            % get target position
            [tar_pos, tar_idx ] = getTargetPosition( tar_positions, tar_pos, d_tar, tar_nbr, tar_idx);

  
            % compute rate of change of attractive forcelet   
            delta_phi_tar = getDeltaPhiTarDynamics(psi_tar, rob_ori, lambda_tar, delta_t, tau_t);
            
                        
            % compute rate of change of repulsive forcelet 
            %delta_phi_obs = getDeltaPhiObsDynamics(clientID, vrep, psh, rob_ori, beta1_obs,beta2_obs, delta_theta, delta_t, tau_t);

            % compute heading direction overall rate of change 
            delta_phi = delta_phi_tar;% + delta_phi_obs;


             % compute right and left wheels speeds
             [ vr, vl ] = getRotationVelocity(delta_phi, delta_t);
             vr = vr + rob_vel;
             vl = vl + rob_vel;
             
             % send commands to the robot
             vrep.simxPauseCommunication(clientID,1);
             vrep.simxSetJointTargetVelocity(clientID,jh(1),vl,vrep.simx_opmode_streaming);			
             vrep.simxSetJointTargetVelocity(clientID,jh(2),vr,vrep.simx_opmode_streaming);
             vrep.simxPauseCommunication(clientID,0);
             
             if tar_idx > 4
                break
             end
             
             % move simulation ahead one time step
             vrep.simxSynchronousTrigger(clientID);
             vrep.simxGetPingTime(clientID);
            
            
                          
         end

    else
		disp('Failed connecting to remote API server');
    end

end
 