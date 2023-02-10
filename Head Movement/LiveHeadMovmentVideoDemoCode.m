%Connect to phone and get accel data'
clc;
close all;
clear eulFilt;

% Connect to MATLAB Mobile
clear AndroidPhone;
disp('Connecting to Phone')
AndroidPhone = mobiledev;
disp('Connected')
% Define MOBILEDEV object and enable sensor data streaming
AndroidPhone.SampleRate = 50;
AndroidPhone.OrientationSensorEnabled = 1;
AndroidPhone.AngularVelocitySensorEnabled = 1;
AndroidPhone.AccelerationSensorEnabled = 1;
AndroidPhone.MagneticSensorEnabled = 1;

%Filter
aFilter = imufilter('SampleRate',AndroidPhone.SampleRate); 
aFilter.GyroscopeNoise          = 0.0002;
aFilter.AccelerometerNoise      = 0.0006;
aFilter.LinearAccelerationNoise = 0.0025;
aFilter.GyroscopeDriftNoise     = 3.0462e-12;
qyaw = quaternion([sqrt(2)/2 0 0 sqrt(2)/2]);

%3D Object
object = readObj('basic_head.obj');
texture = imread('blank.png');
texture_img = flip('blank.png',1);
[sy, sx, sz] = size(texture_img);
texture_img =  reshape(texture_img,sy*sx,sz);
% Make image 3D if grayscale
if sz == 1
    texture_img = repmat(texture_img,1,3);
end
% Select what texture correspond to each vertex according to face
[vertex_idx, fv_idx] = unique(object.f.v);
texture_idx = object.f.vt(fv_idx);
x = abs(round(object.vt(:,1)*(sx-1)))+1;
y = abs(round(object.vt(:,2)*(sy-1)))+1;
xy = sub2ind([sy sx],y,x);
texture_pts = xy(texture_idx);
tval = double(texture_img(texture_pts,:))/255;
disp('Loaded OBJ')

disp('Setting Up Visuals')
%Visualization
figure(1)
turtle = patch('vertices',object.v,'faces',object.f.v,'FaceVertexCData', tval);
view(3)
shading interp
colormap gray(256);
lighting phong;
camproj('perspective');
axis square; 
axis on;
axis equal
axis tight;
xlabel 'Pitch'
ylabel 'Roll'
zlabel 'Yaw'
rotate(turtle,[1,0,0],90)
cameratoolbar

%Loop Start
hmd = 0;
hmu = 0;
hml = 0;
hmr = 0;
htl = 0;
htr = 0;
lp = 2;
disp('Calibrating')
oncestart = 0;
AndroidPhone.Logging = 1;
pause(1)
disp('Live')
tic
while (toc < 30) %run for 30 secs
      [oin, to] = orientlog(AndroidPhone);
      
      lim = size(to,1);
      
      %Initalise Data
      if oncestart == 1
      rotate(turtle,[1,0,0],((oin(1,2)))) %Pitch
      rotate(turtle,[0,1,0],((oin(1,3)))) %Roll
      rotate(turtle,[0,0,1],((oin(1,1)))) %Yaw
      drawnow
      view(3)
      oncestart = 1;
      end
      
      if lp < lim
      % Redraw plot
      rotate(turtle,[1,0,0],((oin(lp,2)) - (oin(lp - 1,2)))) %Pitch
      rotate(turtle,[0,1,0],((oin(lp,3)) - (oin(lp - 1,3)))) %Roll
      rotate(turtle,[0,0,1],((oin(lp,1)) - (oin(lp - 1,1)))) %Yaw
      drawnow
      view(3)
      lp = lp + 1;
      
      if (oin(lp,2) < 25) && (oin(lp,2) > -25)
        hmd = 0;
        hmu = 0;
      end
      
      if (oin(lp,3) < 25) && (oin(lp,3) > -25)
        hml = 0;
        hmr = 0;
      end
      
      if (oin(lp,1) > 135) || (oin(lp,1) < -135)
        htl = 0;
        htr = 0;
      end
      
      %Classification
      if (oin(lp,2) > 25) && (hmd == 0)
        disp('Head Moved Down');
        hmd = 1;
        hmu = 0;
        hml = 0;
        hmr = 0;
        htl = 0;
        htr = 0;
      elseif (oin(lp,2) < -25) && (hmu == 0)
        disp('Head Moved Up');
        hmd = 0;
        hmu = 1;
        hml = 0;
        hmr = 0;
        htl = 0;
        htr = 0;
      elseif (oin(lp,3) < -25) && (hml == 0)
        disp('Head Moved Left');
        hmd = 0;
        hmu = 0;
        hml = 1;
        hmr = 0;
        htl = 0;
        htr = 0;
      elseif (oin(lp,3) > 25) && (hmr == 0)
        disp('Head Moved Right');
        hmd = 0;
        hmu = 0;
        hml = 0;
        hmr = 1;
        htl = 0;
        htr = 0;
      elseif (oin(lp,1) > -135) && (oin(lp,1) < -80) && (htr == 0)
        disp('Head Turned Right');
        hmd = 0;
        hmu = 0;
        hml = 0;
        hmr = 0;
        htl = 0;
        htr = 1;
      elseif (oin(lp,1) < 135) && (oin(lp,1) > 80) && (htl == 0)
        disp('Head Turned Left');
        hmd = 0;
        hmu = 0;
        hml = 0;
        hmr = 0;
        htl = 1;
        htr = 0;
      end
   
      end
      
end
% Stop logging
[a, ta] = accellog(AndroidPhone);
[w, tw] = angvellog(AndroidPhone);
[m, tm] = magfieldlog(AndroidPhone);
[oin, to] = orientlog(AndroidPhone);
AndroidPhone.Logging = 0;
disp('Phone Logging Disabled')

tfin = min([length(ta),length(tm),length(tw),length(to)]);
t = ta(1:tfin);

%Optimiser
eulFilt = zeros(length(t),3,'double');
orientation = zeros(1,length(t),'quaternion');

disp('Running IMU Filter')
%Graph Data
for i=1:length(t)
    % This is where the IMU fusion function is called
    orientation(i) = aFilter(a(i,:),w(i,:));
    
    % 90 deg rotation to match the phone frame
    orientation(i) = orientation(i)*qyaw;
    
    % Convert quaternion into Euler angles
    eulFilt(i,:)= euler(orientation(i),'ZYX','frame');
end
disp('Displaying Data')
% Release the system object
release(aFilter)

inityaw = eulFilt(1,1)*180/pi - (oin(1,1));

figure(2)
plot(t,eulFilt(:,3)*180/pi,t,oin((1:tfin),3));
xlabel('Time [s]');
ylabel('Roll [deg]');
legend('Filter', 'Android Device');

figure(3)
plot(t,eulFilt(:,2)*180/pi,t,oin((1:tfin),2));
xlabel('Time [s]');
ylabel('Pitch [deg]');
legend('Filter', 'Android Device');

figure(4)
plot(t,eulFilt(:,1)*180/pi-inityaw,t,oin((1:tfin),1));
xlabel('Time [s]');
ylabel('Yaw [deg]');
legend('Filter', 'Android Device');