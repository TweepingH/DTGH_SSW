% =========================================================================
% Paper Information:
%
% Title:
% Robust Optical-to-SAR Image Registration via Dense Tukey-Weighted
% Gradient Histogram and Structural Saliency Weight
%
% Authors:
% Wenhao Tong, Anxi Yu, Huatao Yu, Chenshuo Ma, Ziyu Yan, and Zhen Dong*
%
% Status:
% Accepted for publication in IEEE Journal of Selected Topics in Applied
% Earth Observations and Remote Sensing (J-STARS).
%
% Description:
% This code implements the proposed optical-to-SAR image registration
% framework, including:
%
%   (1) Block-wise Harris feature point detection
%   (2) DTGH (Dense Tukey-weighted Gradient Histogram) descriptor extraction
%   (3) SSW (Structural Saliency Weight)
%   (4) FFT-based feature matching
%   (5) Matching error evaluation and visualization
%
% The algorithm parameters are configured according to Experiment II
% in the corresponding paper.
%
% For academic inquiries or further information about this algorithm,
% please contact: twh10355@nudt.edu.cn
%
% =========================================================================
% 论文信息：
%
% 标题：
% Robust Optical-to-SAR Image Registration via Dense Tukey-Weighted
% Gradient Histogram and Structural Saliency Weight
%
% 作者：
% Wenhao Tong, Anxi Yu, Huatao Yu, Chenshuo Ma, Ziyu Yan, and Zhen Dong*
%
% 状态：
% 已被 IEEE Journal of Selected Topics in Applied Earth Observations and
% Remote Sensing (J-STARS) 接收，待正式出版。
%
% 本程序实现论文提出的光学-SAR图像配准框架，包括：
%   (1) 分块 Harris 特征点提取
%   (2) DTGH（Dense Tukey-weighted Gradient Histogram）特征描述子构建
%   (3) 结构显著性权重
%   (4) 基于 FFT 的特征匹配
%   (5) 匹配误差计算与结果可视化
%
% 算法参数设置遵循论文实验二（Experiment II）中的配置。
%
% 如对本文算法或相关研究感兴趣，请联系：
% twh10355@nudt.edu.cn
%
% =========================================================================

i=1;

OPT_img = imread(['OSEval_Uint8\' 'OPT' num2str(i) '.tif']);
SAR_img = imread(['OSEval_Uint8\' 'SAR' num2str(i) '.tif']);

OPT_img=im2gray(OPT_img);
SAR_img=im2gray(SAR_img);

%% Match

[CP_OPT,CP_SAR] = matchFrame(OPT_img,SAR_img);

[corrCP_OPT, corrCP_SAR] = ErrorDet(CP_OPT,CP_SAR,1,1.5);

%% visualize

% figure;imagesc(OPT_img);colormap gray;hold on;
% plot(CP_OPT(:,1),CP_OPT(:,2),'b.','MarkerSize',15);
% 
% % figure;imagesc(SAR_img);colormap gray;hold on;
% % plot(CP_OPT(:,1),CP_OPT(:,2),'b.','MarkerSize',15);
% figure;imagesc(SAR_img);colormap gray;hold on;
% plot(CP_SAR(:,1),CP_SAR(:,2),'r.','MarkerSize',15);


load(['OSEval_Uint8\' num2str(i) '.mat']);


tform_est = fitgeotrans(corrCP_SAR, corrCP_OPT, 'projective');

% Dense Grid RMSE

[h, w, ~] = size(SAR_img);
[h_ref, w_ref, ~] = size(OPT_img);

gridSpacing = 20;

[X, Y] = meshgrid(1:gridSpacing:w, 1:gridSpacing:h);
gridPoints = [X(:), Y(:)];


% ----- Ground Truth -----
[gt_x, gt_y] = transformPointsForward(tform_gt, ...
                                      gridPoints(:,1), ...
                                      gridPoints(:,2));
gt_pts = [gt_x, gt_y];

% ----- Estimated -----
[est_x, est_y] = transformPointsForward(tform_est, ...
                                        gridPoints(:,1), ...
                                        gridPoints(:,2));
est_pts = [est_x, est_y];


valid = gt_pts(:,1) >= 1 & gt_pts(:,1) <= w_ref & ...
        gt_pts(:,2) >= 1 & gt_pts(:,2) <= h_ref & ...
        est_pts(:,1) >= 1 & est_pts(:,1) <= w_ref & ...
        est_pts(:,2) >= 1 & est_pts(:,2) <= h_ref;

gt_valid  = gt_pts(valid, :);
est_valid = est_pts(valid, :);

% Dense RMSE
diff_valid = gt_valid - est_valid;
errors = sqrt(sum(diff_valid.^2, 2));

RMSE_dense = sqrt(mean(errors.^2));

fprintf('Dense Grid RMSE (overlap) = %.4f pixels\n', RMSE_dense);

Rfixed = imref2d(size(OPT_img));
SAR_img_warp = imwarp(SAR_img, tform_est, 'OutputView', Rfixed);


% Checkerboard
Checkerboard(OPT_img, SAR_img_warp, 240);
% Pseudo-color
figure;imshowpair(OPT_img, SAR_img_warp);

%% Correct Match Ratio


[gt_mx, gt_my] = transformPointsForward(tform_gt, ...
                                        corrCP_SAR(:,1), ...
                                        corrCP_SAR(:,2));
gt_matched = [gt_mx, gt_my];


match_diff = corrCP_OPT - gt_matched;
match_error = sqrt(sum(match_diff.^2, 2));


threshold = 2;

correct_matches = match_error < threshold;

CMR = sum(correct_matches) / length(correct_matches);

fprintf('Correct Matches = %d / %d\n', ...
        sum(correct_matches), length(correct_matches));

fprintf('Correct Match Ratio (CMR) = %.4f\n', CMR*100);

%% 
figure;
imshow([OPT_img, SAR_img]);
hold on;
w_offset = w_ref;

x_correct = [corrCP_OPT(correct_matches,1), ...
             corrCP_SAR(correct_matches,1)+w_offset]';
y_correct = [corrCP_OPT(correct_matches,2), ...
             corrCP_SAR(correct_matches,2)]';

line(x_correct, y_correct, ...
     'Color','g','LineWidth',0.5);


x_wrong = [corrCP_OPT(~correct_matches,1), ...
           corrCP_SAR(~correct_matches,1)+w_offset]';
y_wrong = [corrCP_OPT(~correct_matches,2), ...
           corrCP_SAR(~correct_matches,2)]';

line(x_wrong, y_wrong, ...
     'Color','r','LineWidth',0.5);

title(sprintf('Feature Matches (CMR = %.2f%%)', CMR*100));
axis off;

