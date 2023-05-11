function [ACC_A, ACC_B, POS_A_IRF, POS_B_IRF, SCA1B_A, SCA1B_B]...
    = min_norm(ACC_A, ACC_B, POS_A_IRF, POS_B_IRF, SCA1B_A, SCA1B_B)

MaxIter = 50; 

%--- Determining average sampling rate scaled by Max Iterations
time_GPS_B = ACC_B(:,1); 
M = round((length(time_GPS_B) - 1 ) / (time_GPS_B(length(time_GPS_B)) -time_GPS_B(1))) * MaxIter;
n = length(POS_A_IRF)-M;

%--- Finding index shift for min 3D distance (brute force)
index_shift_min = zeros(1,n); 

for i = 1:n
    search_min = POS_A_IRF(i,:) - POS_B_IRF(i:i + M,:); 
    [~, index_shift_min(i)] = min(vecnorm(search_min, 2, 2));
end

%--- Extracting GPS time epochs where min. distance occurs by shifting trailing to leading
indexB = (0:n-1) + index_shift_min; %index needed for extraction
indexA = 1:n;

%--- Shifting trailing measurements by determine closest desistance
POS_A_IRF = POS_A_IRF(indexA,:); 
POS_B_IRF = POS_B_IRF(indexB,:); 

ACC_A = ACC_A(indexA,:); 
ACC_B = ACC_B(indexB,:); 

SCA1B_A = interp_spline(SCA1B_A, ACC_A(:,1)); 
SCA1B_B = interp_spline(SCA1B_B, ACC_B(:,1)); 

end