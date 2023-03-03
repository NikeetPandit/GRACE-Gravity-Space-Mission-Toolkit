function yOut = gaussFIRzero_phase(yIn, Fs, Fc, varargin)

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


%--- Column input check 
[row, col] = size(yIn); 
if col > row
    error("Input must be column vector"); 
end

%--- Assign filter selection and shape and do input check 
[filt_select, shape] = read_varargin(Fc, varargin); 

switch lower(filt_select)
    case 'lp'
        
        Fc = recursive_FIR_design(Fc, filt_select);
        yOut = filt_lp(yIn, Fs, Fc);

    case 'hp'
        Fc = recursive_FIR_design(Fc, filt_select);
        yOut =  filt_hp(yIn, Fs, Fc); 
    
    case 'bp'
        yOut = filt_lp(yIn, Fs, Fc(1));
        
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
        end
        
        if mod(N,2) == 0
            error("Kernel should be odd. There is a bug in the software."); 
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

%--- Low pass filter function 
function yOut = filt_lp(yIn, Fs, Fc)

% Determining width of kernel described by sigma releated to cut off frequency
sigma_fun = @(Fs, Fc) (Fs*sqrt(log(2))/(2*pi*Fc)); %Noise and signal interference in optical fibers
mu = 0; 

% Formula for gaussian kernel
kernel_fun = @(x1, x2, mu, sigma, N) vertcat((1/(sigma*sqrt(2*pi))).*exp(-0.5*((x1-mu)./sigma).^2), zeros(N,1), ((1/(sigma*sqrt(2*pi))).*exp(-0.5*((x2-mu)./sigma).^2))); 

% Formula to wrap negative times of kernel to extreme right end of array 
wrap_kernel_fun = @(x1, x2, yIn) (numel(yIn) - (numel(x1) + numel(x2)));

%--- Determine width of kernel based on cut-off frequency
sigma = sigma_fun(Fs, Fc); 

%--- Determine array of where to evaluate kernel
L = ceil(length(yIn)/2); 
if isequal(mod(L, 2), 0)
    L = L - 1; 
end
x = -L:1:L; 
if ~isequal(median(x), 0)
    error("Median must be zero for kernel. Investigate."); 
end

%--- Extracting negative time and positive time kernel components
x1 = x >= 0; x1 = x(x1); 
x2 = x < 0; x2 = x(x2); 

%--- Wrap negative kernel to extreme end of array (size of yIn)
N = wrap_kernel_fun(x1, x2, yIn);

%--- Construct low pass kernel
kernel = kernel_fun(transpose(x1), transpose(x2), mu, sigma, N); 

%--- Apply system to input data
yOut = ifft(fft(yIn).* fft(kernel)); %circular convolution by FFT mult

end

%--- High pass filter function
function yOut = filt_hp(yIn, Fs, Fc)

yOut = yIn - filt_lp(yIn, Fs, Fc); 

end


%--- Reading variable-inputs and doing debug checks
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

 






