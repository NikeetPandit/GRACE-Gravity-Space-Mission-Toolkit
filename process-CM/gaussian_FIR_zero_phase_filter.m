function [yOut, kernel] = gaussian_FIR_zero_phase_filter(yIn, Fs, Fc, varargin)
%--- NEEDS a few tweaks to be fully operational. Is calculated in the
% frequency domain for maximum efficiency, wrapping the non-causal part of
% the kernel to the end of the signal. 

%GAUSSIAN_SMOOTH is a simple utility which performs gaussian kernel FIR smoothing
%   (i.e, zero-phase shift filtering). User may select to low-pass, high-pass,
%   band-pass, band-reject, with a selected cut-off frequency(s). Cut-off
%   frequency is interpreted as 1/2 peak power value or 1/sqrt(2) peak
%   amplitude, or -3dB point. 
%
%   Inputs:
%   (1) yIn: Input signal to be filtered. If input is matrix, it treates
%   each column as an independent chanel to be smoothed. 
%   (2) Fs: Sample rate
%   'fc': Cut off frequency one 
%   'fc1': Cut off frequency two (only use if BP or BR). Otherwise error is thrown
%   'filter': 'LP', 'HP', 'BP', 'BR'
%   'shape': 'same', 'valid' ... subsection of the convolution 
%       'same': returns same size as yIn (boundaries of the convolution will be spoiled due to circular assumption)
%       'valid' only returns parts of convolution without overlapped edges with rest set to NaN
%
% Example ... gaussian_smooth(yIn, 1, 'fc', 1e-4, 'lp', 'filter', 'shape','same')
%
%   Outputs:
%   (1) yOut: Smoothed signal
%   (2) kernel: Kernel used to smooth signal in time domain
%
%   Author: Nikeet Pandit
%   Email: nikeet1@gmail.com
%
%------------------------------------------------------------------------------------------------------------------

%--- Multi-dimensional check  
[row, col] = size(yIn); 
if col > row
    error("Dimensions of input data not correct. See documentation"); 
end

%--- Runing function along each column 
%yOut = zeros(length(yIn), col); 
for i = 1:col
    [yOut(:,i), kernel{i}] = gaussian_smooth_col(yIn(:,i), Fs, Fc, varargin);
end

end

function [yOut, kernel] = gaussian_smooth_col(yIn, Fs, Fc, varargin)
varargin = varargin{1}; 

%--- Column input check 
[row, col] = size(yIn); 
if col > row
    error("Input must be column vector"); 
end

%--- Assign filter selection and shape and do input check 
[filt_select, shape] = read_varargin(Fc, varargin);

% Determining width of kernel described by sigma releated to cut off frequency
sigma_fun = @(Fs, Fc) (Fs*sqrt(log(2))/(2*pi*Fc)); %Noise and signal interference in optical fibers

% Formula for gaussian kernel
kernel_fun = @(x1, x2, mu, sigma, N) vertcat((1/(sigma*sqrt(2*pi))).*exp(-0.5*((x1-mu)./sigma).^2), zeros(N,1), ((1/(sigma*sqrt(2*pi))).*exp(-0.5*((x2-mu)./sigma).^2))); 

% Formula to wrap negative times of kernel to extreme right end of array 
wrap_kernel_fun = @(x1, x2, yIn) (numel(yIn) - (numel(x1) + numel(x2)));

% Formula for determining filter size
mu = 0; 

switch lower(filt_select)
    case 'lp'

        %--- Determine width of kernel based on cut-off frequency
        sigma = sigma_fun(Fs, Fc); 

        %--- Evaluate time vector where x1 is negative and x2 is positive time 
        [x1, x2] = sample_array(sigma, Fs);

        %--- Wrap negative kernel to extreme end of array (size of yIn)
        N = wrap_kernel_fun(x1, x2, yIn);

        %--- Construct low pass kernel
        kernel = kernel_fun(transpose(x1), transpose(x2), mu, sigma, N); 

        %--- Apply system to input data
        yOut = ifft(fft(yIn).* fft(kernel)); %circular convolution by FFT mult

    case 'hp'

        %--- Determine width of kernel based on cut-off frequency
        sigma = sigma_fun(Fs, Fc); 

        %--- Evaluate time vector where x1 is negative and x2 is positive time 
        [x1, x2] = sample_array(sigma, Fs);

        %--- Wrap negative kernel to extreme end of array (size of yIn)
        N = wrap_kernel_fun(x1, x2, yIn);

        %--- Construct low pass kernel
        lp_kernel = kernel_fun(transpose(x1), transpose(x2), mu, sigma, N); 

        %--- Construct hp kernel (see fun at end for notes)
        kernel = construct_hp_kernel_from_lp_kernel(lp_kernel);

        %--- Apply system to input data
        yOut = ifft(fft(yIn).* fft(kernel)); %circular convolution by FFT mult

    case 'bp'

        %--- Cut off 1 (see low pass or high pass process)
        sigma1 = sigma_fun(Fs, Fc(1)); 
        [x1_1, x2_1] = sample_array(sigma1, Fs); 
        x_len1 = numel(x1_1) + numel(x2_1); 
        N_1 = wrap_kernel_fun(x1_1, x2_1, yIn);

        %--- Cut off 2 (see low pass or high pass process)
        sigma2 = sigma_fun(Fs, Fc(2)); 
        [x1_2, x2_2] = sample_array(sigma2, Fs);
        x_len2 = numel(x1_2) + numel(x2_2); 
        N_2 = wrap_kernel_fun(x1_2, x2_2, yIn);

        %--- Make shorter kernel evaluated over same length as longer kernel so can add and subtract kernels
        if x_len2 > x_len1
            x1_1 = x1_2; 
            x2_1 = x2_2; 
            N_1 = N_2; 
        elseif x_len1 > x_len2
            x1_2 = x1_1; 
            x2_2 = x2_1; 
            N_2 = N_1; 
        end
        
        %--- Constructing low pass kernels
        kernel1 = kernel_fun(transpose(x1_1), transpose(x2_1), mu, sigma1, N_1); 
        kernel2 = kernel_fun(transpose(x1_2), transpose(x2_2), mu, sigma2, N_2); 

        %--- Construct band reject kernel
        kernel_br = kernel1 + construct_hp_kernel_from_lp_kernel(kernel2);

        %--- Construct band pass kernel
        kernel = construct_hp_kernel_from_lp_kernel(kernel_br); 
    
        %--- Apply system to input data
        yOut = ifft(fft(yIn).* fft(kernel)); %circular convolution by FFT mult

    case 'br'
        %--- Cut off frequency kernel 1  (see low pass or high pass process)
        sigma1 = sigma_fun(Fs, Fc(1)); 
        [x1_1, x2_1] = sample_array(sigma1, Fs); 
        x_len1 = numel(x1_1) + numel(x2_1); 
        N_1 = wrap_kernel_fun(x1_1, x2_1, yIn);

        %--- Cut off frequency kernel 2 (see low pass or high pass process)
        sigma2 = sigma_fun(Fs, Fc(2)); 
        [x1_2, x2_2] = sample_array(sigma2, Fs);
        x_len2 = numel(x1_2) + numel(x2_2); 
        N_2 = wrap_kernel_fun(x1_2, x2_2, yIn);

        %--- Make shorter kernel evaluated over same length as longer kernel so can add and subtract kernels
        if x_len2 > x_len1
            x1_1 = x1_2; 
            x2_1 = x2_2; 
            N_1 = N_2; 
        elseif x_len1 > x_len2
            x1_2 = x1_1; 
            x2_2 = x2_1; 
            N_2 = N_1; 
        end
        
        %--- Constructing low pass kernels
        kernel1 = kernel_fun(transpose(x1_1), transpose(x2_1), mu, sigma1, N_1);
        kernel2 = kernel_fun(transpose(x1_2), transpose(x2_2), mu, sigma2, N_2); 

        %--- Construct band reject kernel
        kernel = kernel1 + construct_hp_kernel_from_lp_kernel(kernel2);
    
        %--- Apply system to input data
        yOut = ifft(fft(yIn).* fft(kernel)); %circular convolution by FFT mult
    
    otherwise
        error("Invalid filter selection"); 
end

switch shape
    case 'same'
        return 
    case 'valid'

        %--- Determine size of kernel without zero padding
        switch lower(filt_select)
            case 'bp'
                N = numel(x1_1) + numel(x2_1);
            case 'br'
                N = numel(x1_1) + numel(x2_1);
            case 'lp'
                N = numel(x1) + numel(x2);
            case 'hp'
                N = numel(x1) + numel(x2);
            otherwise
                error("I am not sure how this is triggered"); 
        end
        

        if mod(N,2) == 0
            error("Kernel should be odd. There is an error with code"); 
        end
        
        %--- Find middle point of even kernel
        midpt = ceil(N/2); % at middle point of size of kernel there is no boundary effect for first element of yIn
    
        %--- Making all smoothed results NaN that are spoiled by boundary effects
        yOut(1:midpt-1) = NaN; 
        yOut(end-midpt+2:end) = NaN; 

        %yOut = yOut(midpt:end-midpt+1);%--- Truncate to convolution without boundary effects


    otherwise
        error("Invalid shape selection. Should have been caught earlier in code"); 
end

end
% --- Function determines array of where to sample kernel in time
function [x1, x2] = sample_array(sigma, Fs)

% Determing filter size (weights further than 3*sigma contribute very minamlly)
L = ceil(sigma*3.5); 
if mod(L,2) == 0 %if width is even make odd so non-casual weighting is symmetric for each smoothed point
    L = L + 1; 
end

% Determine where to evaluate kernel
x = -L+1:1:L-1; 
if median(x) ~= 0 && Fs == 1
    error("Median must be zero for kernel."); 
end
%--- Extracting negative time and positive time kernel components
x1 = find(x >= 0); x1 = x(x1); 
x2 = find(x < 0); x2 = x(x2); 
end

%--- Function creates high-pass kernel from low-pass kernel (based on Digital Image Processing)

function kernel_hp = construct_hp_kernel_from_lp_kernel(lp_kernel)
%--- Centre of delta function and low pass filter must collide
indx = 1; %centre is first element 
delta_fun = zeros([numel(lp_kernel), 1]);
[~, ind] = max(lp_kernel(:)); 
if ind ~= indx
    error("The centre of the low pass kernel does not equal the index of the max of the kernel. There is an issue."); 
end
delta_fun(indx) = 1; 
kernel_hp = delta_fun - lp_kernel;

end

%-- Reading inputs and doing checks
function [filt_select, shape] = read_varargin(Fc, varargin)
varargin = varargin{1}; 

%--- Filter Selection ---%
shape_ind = find(strcmpi(varargin, 'shape')); 
    if ~isempty(shape_ind) 
        shape = (varargin{shape_ind + 1});
    else
        error("Must select shape of output convolution."); 
    end

%--- Filter Selection ---%
Filter_ind = find(strcmpi(varargin, 'filter')); 
    if ~isempty(Filter_ind) 
        filt_select = (varargin{Filter_ind + 1});
    else
        error("Must select filter type."); 
    end

%--- Input check 
if strcmpi(filt_select, 'bp') == 0 && strcmpi(filt_select, 'br') == 0 && strcmpi(filt_select, 'lp') == 0&& strcmpi(filt_select, 'hp') == 0
    error("Did not select valid filter option"); 
end

%--- Input check 
if length(Fc) == 2
    Fc1 = Fc(1); 
    Fc2 = Fc(2); 
end
if length(Fc) == 2
    if Fc1 > Fc2
        error("Cut off frequency 2 must be greater then 1."); 
    elseif Fc1 == Fc2
        error("Cut off frequencies cannot be equal.");
    elseif length(Fc) == 2 &&  strcmpi(filt_select, 'lp') == 1 ||  length(Fc) == 2 && strcmpi(filt_select, 'hp') == 1
         error("Two cut off frequencies inputted, but trying to low-pass or high-pass"); 
    end
end
end

 






