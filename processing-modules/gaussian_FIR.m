function [yOut, kernel] = gaussian_FIR(x, y, filter, Fc, order, truncate)
% gaussian_FIR performs gaussian FIR zero-phase filtering. 
%   User may select high-pass, low-pass, band-pass, band-reject filter. 
%   Fitler is applied in frequency domain for computational efficiency. 
% 
%   The width of the kernel is evaluated for the entire input series. 
%   This means the kernel is not rectangularly windowed. 
%   Therefore, the FIR filter's disotortion to Gibbs phenomenon tends to
%   zero, as the series length tends to infinity. 
%
%   The procedure is only limited by by the digital numeric representation type. 
%
%   Inputs:
%   (1) x: Time-Tags of data. Size [nx1]. OR, sample rate. Size [1] | scalar.
%   (2) y: Input data. Size [nxm]. Operates on each on input column independently.
%   (3) filter: 'LP', 'HP', 'BP', 'BR'. Denotes low-pass, high-pass,
%   'band-pass', and 'band-reject filter, respectively.
%   (4) Fc:  Cut-off frequency, where mangitude response is 1/sqrt(2).
%       If filter is 'HP', or 'LP', input must be scalar. 
%       If filter is 'BP', or 'BR', input must be size [nx2] where 
%       n2 > n1.
%
%   (5) Optional: N. Default is 1. N denotes how many times the
%       input series is filtered. If an order of 10 was selected, the
%       input signal is filtered 10 times series with the designed impulse
%       response. 
%   
%       The motiivation for this: 
%       A value of N = 10 will provide a sharper transition band than N = 1. 
% 
%       N non-interacting linear systems in series is equivalent 
%       to the product of the frequency response of the individual systems.
%       So, the product of the frequency response of the designed invidiual
%       system is taken, and this resultant system is applied for
%       computaitonal efficiency. 

%   Outputs:
%   (1) yOut:   Filtered signal.
%   (2) kernel: Impulse response of filter in time-domain. Use fftshift to center kernel.
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com
%
%------------------------------------------------------------------------------------------------------------------

%--- Determine filtering order based on inputs
switch nargin 
    case 5
        if     isempty(order)
            order = 1; 

        elseif order < 1
            error("Selected filter order is not valid."); 
        end

    case 4
        order = 1; 

end

try 
    isempty(truncate);
catch
    truncate = []; 
end

%--- Check inputs are valid/throw error if not
check_inputs(x, y, Fc, filter); 

%--- Calculate series column length/sample rate
[yInLen, ~] = size(y); 

if ~isscalar(x)
    Fs = avg_sample_rate(x); 
else
    Fs = x; % If sample rate is explicitly parsed
end

switch lower(filter)
    case 'lp'
        kernel = lp_kernel(Fc, Fs, yInLen, truncate);

    case 'hp'
        kernel = hp_kernel(Fc, Fs, yInLen, truncate);
    
    case 'bp'
        kernel = bp_kernel(Fc, Fs, yInLen, truncate); 

    case 'br'
        kernel = br_kernel(Fc, Fs, yInLen, truncate);

    otherwise
        error("Invalid filter selection"); 
end

%--- Apply filter in frequency domain and return to time/space domain
yOut = ifft(fft(y).*(fft(kernel).^order)); 

end


%% Low pass kernel
function kernel = lp_kernel(Fc, Fs, yInLen, truncate)

% Determining width of kernel described by sigma releated to cut off frequency
sigma_fun = @(Fs, Fc) (Fs*sqrt(log(2))/(2*pi*Fc)); mu = 0; 

% Formula for gaussian kernel
kernel_fun = @(x1, x2, mu, sigma, N) vertcat((1/(sigma*sqrt(2*pi))).*exp(-0.5*((x1-mu)./sigma).^2), zeros(N,1), ((1/(sigma*sqrt(2*pi))).*exp(-0.5*((x2-mu)./sigma).^2))); 

% Formula to wrap negative times of kernel to extreme right end of array 
wrap_kernel_fun = @(x1, x2, yInLen) (yInLen - (length(x1) + length(x2)));

%--- Determine width of kernel based on cut-off frequency
sigma = sigma_fun(Fs, Fc); 

%--- Determine array of where to evaluate kernel
L = ceil(yInLen/2); 

%--- For robustness
while L*2 >= yInLen
    L = L - 1; 
end


if isempty(truncate)
    %--- Making kernel odd
    if isequal(mod(L, 2), 0)
        L = L - 1; 
    end
    x = -L:1:L;

else

    % % Determing filter size where 7 sigma only is used
    L = ceil(sigma*3.5); 
    if mod(L,2) == 0 %if width is even make odd so non-casual weighting is symmetric for each smoothed point
        L = L + 1; 
    end
    x = -L+1:1:L-1; 
end

%--- Debug check
if ~isequal(median(x), 0)
    error("Median must be zero for kernel. Investigate."); 
end
%--- Extracting negative time and positive time kernel components
x1 = x >= 0; x1 = x(x1); 
x2 = x < 0; x2 = x(x2); 

%--- Wrap negative kernel to extreme end of array (size of yIn)
N = wrap_kernel_fun(x1, x2, yInLen);

%--- Construct low pass kernel
kernel = kernel_fun(transpose(x1), transpose(x2), mu, sigma, N); 

end

%%  High Pass Kernel
function kernel = hp_kernel(Fc, Fs, yInLen, truncate)

%--- Deriving low pass kernel
kernel = lp_kernel(Fc, Fs, yInLen, truncate); 

%--- Subtract unit impulse from lp kernel to derive hp kernel
kernel(1) = 1 - kernel(1); kernel(2:end) = -kernel(2:end);

end

%% br kernel
function kernel = br_kernel(Fc, Fs, yInLen, truncate)

%--- Deriving low pass kernel
kernel0 = lp_kernel(Fc(1), Fs, yInLen, truncate); 

%--- Deriving high pass kernel
kernel1 = hp_kernel(Fc(2), Fs, yInLen, truncate); 

%--- Construct band pass kernel
kernel = kernel0 + kernel1; 

end

%% bp kernel
function kernel = bp_kernel(Fc, Fs, yInLen, truncate)

%--- Construct band-reject kernel
kernel = br_kernel(Fc, Fs, yInLen, truncate);

%--- Subtract unit impulse from br kernel to derive bp kernel
kernel(1) = 1 - kernel(1); kernel(2:end) = -kernel(2:end);

end

%% Input Check

function check_inputs(x, y, Fc, filter)

% %--- Debug checks 
% n1 = size(y);
% if  ~isscalar(x)
%     [n, m] = size(x); 
% else
%    n = n1; m = 1;   % if Fs is parsed
% end
%     
% if ~isequal(m, 1) || ~isequal(n, n1(1))
%     error("Dimensions of input data not correct. See documentation"); 
% end  

if length(Fc) == 2
    Fc1 = Fc(1); 
    Fc2 = Fc(2); 
end

if length(Fc) == 2
    if Fc1 > Fc2
        error("Cut off frequency 2 must be greater then 1.");

    elseif Fc1 == Fc2
        error("Cut off frequencies cannot be equal.");

    elseif length(Fc) == 2 &&  strcmpi(filter, 'lp') == 1 ||  length(Fc) == 2 && strcmpi(filter, 'hp') == 1
         error("Two cut off frequencies inputted when trying to low-pass or high-pass"); 
    end
end
end

function M = avg_sample_rate(time)
%--- Debug check 
[~, m] = size(time); 
if ~isequal(m, 1)
    error("Dimensions of input data not correct. See documentation"); 
end
%--- Determine avg sample rate
M = 1./round(mean(diff(time)), 1); 

end
