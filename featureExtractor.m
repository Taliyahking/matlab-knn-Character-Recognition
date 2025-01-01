function features = featureExtractor(imgDatastore)
    % 初始化特征数组
    features = [];
    while hasdata(imgDatastore)
        img = read(imgDatastore);
        extractedFeatures = extractHOGFeatures(img);
        features = [features; extractedFeatures];
    end
    reset(imgDatastore);
end
