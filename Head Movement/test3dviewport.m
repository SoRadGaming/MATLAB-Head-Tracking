clc;
close all;

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

itterator = 0;

while (itterator < 100) 
    rotate(turtle,[1,0,0],(90));
    itterator = itterator + 1;
end