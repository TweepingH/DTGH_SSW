%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Tong Wenhao
% Contact: twh10355@nudt.edu.cn
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [corrRefPt, corrSenPt] = ErrorDet(refPt, senPt, flag, errTh)

%--------------------------------------------------------------------------
% ErrorDet
% Robust outlier removal for matched control points
%
% Inputs:
%   refPt   - Nx2 reference points
%   senPt   - Nx2 sensed points
%   flag    - 0: polynomial(3)
%             1: projective
%             2: affine
%   errTh   - RMS error threshold
%
% Outputs:
%   corrRefPt - refined reference points
%   corrSenPt - refined sensed points
%--------------------------------------------------------------------------


    assert(size(refPt,2)==2 && size(senPt,2)==2, ...
        'Input points must be Nx2 format.');

    assert(size(refPt,1)==size(senPt,1), ...
        'refPt and senPt must contain same number of points.');


    [modelType, minPts] = getModelType(flag);


    while true

        ptNum = size(refPt,1);


        if ptNum < minPts
            warning('Insufficient points for model estimation.');
            break;
        end


        tform = fitgeotrans(refPt, senPt, modelType);


        refToSen = transformPointsForward(tform, refPt);


        errVec = refToSen - senPt;
        residual = hypot(errVec(:,1), errVec(:,2));


        meanErr = sqrt(mean(residual.^2));


        if meanErr <= errTh
            break;
        end


        [~, idx] = max(residual);
        refPt(idx,:) = [];
        senPt(idx,:) = [];

    end

    corrRefPt = refPt;
    corrSenPt = senPt;

end


%--------------------------------------------------------------------------
function [modelType, minPts] = getModelType(flag)

    switch flag
        case 0
            modelType = 'polynomial';
            minPts = 10;   % 3rd order polynomial needs >=10 points
        case 1
            modelType = 'projective';
            minPts = 4;
        otherwise
            modelType = 'affine';
            minPts = 3;
    end

end