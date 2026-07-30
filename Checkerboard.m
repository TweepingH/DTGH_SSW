%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Tong Wenhao
% Contact: twh10355@nudt.edu.cn
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function I_cb = Checkerboard(I1, I2, blockSize)

if isscalar(blockSize)
    bh = blockSize;
    bw = blockSize;
else
    bh = blockSize(1);
    bw = blockSize(2);
end

assert(all(size(I1) == size(I2)), 'The two images have to be the same size');

[H, W, C] = size(I1);


rowBlock = floor((0:H-1)'/bh);
colBlock = floor((0:W-1)/bw);


checkerMask = mod(rowBlock + colBlock, 2);


if C == 3
    checkerMask = repmat(checkerMask, [1 1 3]);
end


I1 = im2double(I1);
I2 = im2double(I2);

I_cb = checkerMask .* I1 + (1 - checkerMask) .* I2;


figure;
imshow(I_cb);
title(sprintf('Manual Checkerboard (Block Size = %dx%d)', bh, bw));

end