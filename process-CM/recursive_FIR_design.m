function FcOut = recursive_FIR_design(FcIn, filter_type)
% recursive_FIR_design takes in the desired cut-off frequency that a user
%   is requested to filter and optimizes this input to output a slightly
%   modified cut-off that will be as close as possible to intersecting
%   the 1/2 peak power point, or -3dB point. 
% 
%   It does this creating a delta impulse function, filtering it based on
%   the user selection, computing the power spectrum, and evaluating the
%   frequency response at the cut-off, and it's error against the -3dB
%   point. 
%
%   The motivation is to ensure, for a selected cut off(s),
%   a system is designed as close as possible to the user selection. 
%
%   Inputs:
%   (1) FcIn: cut off frequencyW(s). [Fc1, Fc2]. Fc2 is put only if
%       band-pass, or band-reject filter is selected. 
%   (2) filter_type: 'LP', 'HP', 'BR', 'BP'. See gaussFIRzero_phase for more
%       information. 
%
%   Outputs:
%   (1) FcOut: Modified cut off frequency(s) that correspond as close as
%   possible to the 1/2 peak power point. 
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com
%
%------------------------------------------------------------------------------------------------------------------

%---- Create Delta Function 
delta = zeros(500000, 1); delta(ceil(end/2)) = 1; 

%--- Initial guesses to find direction 
search_0 = [-1e-7 0 1e-7]; err_0 = zeros(1,3);

for i = 1:length(search_0)

    %--- Applying filter to delta function 
    delta_filt = gaussFIRzero_phase(delta, 1, FcIn + search_0(i), 'filter', filter_type, 'shape', 'same');

    %--- Take PSD
    [pxx, f] = periodogram(delta_filt, [], [], 1); 
    pxx = 10*log10(pxx) - max(10*log10(pxx));
    
    %--- See error differnce of power drop at PSD
    [~, ind] = min(abs(f - FcIn)); 
    err_0(i) = abs(pxx(ind)) - 3; 
end

%--- find minimum error location
[~, ind] = min(err_0); 

%-- Find direction of decreasing error
val = ind + 1; 
if val > 3
    val = ind - 1;
end

dir = err_0(ind) - err_0(val); 

%--- Brute force optimization to ensure FIR filter is designed to -3dB point within tolerence
err_0 = err_0(ind); % Starting at minimum error from step 1

%--- Setting tolerance
tol = 0.25; 

%--- Setting current Fc to test
current_Fc = FcIn(1) + search_0(ind); 

while err_0 >= tol

    %--- Iterating the cut-off of the fitler, calculating the PSD
    if dir < 0
        current_Fc = current_Fc - 1e-6;
    else
        current_Fc = current_Fc + 1e-6; 
    end
    
    delta_filt = gaussFIRzero_phase(delta, 1, current_Fc, 'filter', filter_type, 'shape', 'same');

    [pxx, f] = periodogram(delta_filt, [], [], 1); 
    pxx = 10*log10(pxx) - max(10*log10(pxx));
    
    [~, ind] = min(abs(f - FcIn(1))); 
    err_0 = abs(abs(pxx(ind)) -3); 

end

FcOut = current_Fc; 

end
