clear ; close all; clc;

clear m;
clear mobiledev;

m = mobiledev;

m.Logging = 1;

m.Logging = 0;

[av,tav] = angvellog(m);
[o,to] = orientlog(m);

yAngVel = av(:,2);
roll = o(:,3);
plot(tav,yAngVel,to,roll);
legend('Y Angular Velocity','Roll');
xlabel('Relative time (s)');