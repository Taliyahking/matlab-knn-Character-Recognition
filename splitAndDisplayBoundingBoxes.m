function bboxes = splitAndDisplayBoundingBoxes(imagePath, widthThreshold, areaThreshold, heightThreshold)
    % 读取图像
    img = imread(imagePath);

    % 转换为灰度图像
    grayImg = rgb2gray(img);

    % 应用阈值化以获得二值图像
    binaryImg = imbinarize(grayImg);

    % 使用形态学操作（腐蚀和膨胀）以分离字符
    se = strel('rectangle', [1, 5]);
    erodedImg = imerode(binaryImg, se);
    dilatedImg = imdilate(erodedImg, se);

    % 查找连通组件
    [~, L] = bwboundaries(dilatedImg, 'noholes');
    stats = regionprops(L, 'BoundingBox', 'Area');

    % 过滤掉小的连通组件
    stats = stats([stats.Area] > areaThreshold);
    stats = stats(arrayfun(@(s) s.BoundingBox(4) >= heightThreshold, stats));
    stats = stats(arrayfun(@(s) s.BoundingBox(3) >= widthThreshold / 2, stats)); % 宽度至少为分割阈值的一半

    % 初始化边界框数组
    bboxes = [];

    for k = 1:length(stats)
        bb = stats(k).BoundingBox;

        % 如果边界框宽度大于阈值，则分割为两个边界框
        if bb(3) >= widthThreshold
            % 计算中点
            midpoint = bb(1) + bb(3)/2;

            % 分割边界框为两个新的边界框
            bb1 = [bb(1), bb(2), midpoint - bb(1), bb(4)]; % 左半边
            bb2 = [midpoint, bb(2), bb(1) + bb(3) - midpoint, bb(4)]; % 右半边

            % 将两个新的边界框添加到数组中
            bboxes = [bboxes; bb1; bb2];
        else
            % 否则，添加原始边界框到数组中
            bboxes = [bboxes; bb];
        end
    end
end
