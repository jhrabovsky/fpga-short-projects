clear

cifers = 1:10;
no_samples_per_cifer = 3;
no_featuremaps = 16;
image_len = 9;
kernel_len = 3;
output_len = image_len - kernel_len + 1;
bias = 0;

inputs = zeros(length(cifers),no_samples_per_cifer,image_len,image_len);
outputs = zeros(length(cifers),no_samples_per_cifer,no_featuremaps,output_len,output_len);

for i = cifers
    inputs(i,:,:,:) = reshape(importdata(sprintf('%i/input.txt',i-1)), no_samples_per_cifer, image_len, image_len);
    outputs(i,:,:,:,:) = reshape(importdata(sprintf('%i/output.txt', i-1)), no_samples_per_cifer, no_featuremaps, output_len, output_len);
end

clear i
weights = importdata('kernels.txt');

% specify testing image as input to the system
% variable has to be structure to enable cyclic usage
test_image_input.time=[];
test_image_input.signals.values = reshape(inputs(1,1,:,:),image_len^2,1);

%reverse order of input pixels to the direction LAST->FIRST
test_image_input.signals.values = test_image_input.signals.values(end:-1:1);

% save currently created workspace into file
save ../data.mat;