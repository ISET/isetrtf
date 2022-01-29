clear

origin = [  0 0.6  0 ]
theta_deg=50;

err_origin = 1e-5*[1 0 0];


err_theta_deg=0.01;


direction = [0 sind(theta_deg) cosd(theta_deg)]
err_direction = [0 sind(theta_deg+err_theta_deg) cosd(theta_deg+err_theta_deg)]-direction;


%% Identical pathlength

pathlength_mm=1000.16;
ideal =(origin) + pathlength_mm*direction
actual =(origin+err_origin) + pathlength_mm*(direction+err_direction)

error_micron = 1e3*norm(ideal-actual)
error_micron2 = 1e3*(norm(err_origin)+pathlength_mm*sqrt(2-2*cosd(err_theta_deg)))
error_micron_approx= 1e3*(norm(err_origin)+pathlength_mm*deg2rad(err_theta_deg))


%% Error within film plane ( unequal patlength
filmdistance=2000;

ideal_film =(origin) + (filmdistance/direction(3))*direction;

actualdirection =(direction+err_direction);
actual_film =(origin+err_origin) + (filmdistance/actualdirection(3))*actualdirection;

error_filmplane_micron = 1e3*norm(ideal_film-actual_film)

