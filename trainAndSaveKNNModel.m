% 定义数据集路径
dataFolder = 'p_dataset_26';  % 这是数据集的路径

% 创建 imageDatastore 对象
images = imageDatastore(dataFolder, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');

% 分割数据集为训练集和测试集
[trainingSet, testSet] = splitEachLabel(images, 0.7, 'randomize');  % 70% 为训练集，30% 为测试集

% 提取训练集和测试集的特征
trainingFeatures = featureExtractor(trainingSet);
trainingLabels = trainingSet.Labels;
testFeatures = featureExtractor(testSet);
testLabels = testSet.Labels;

% KNN 分类器的参数
numNeighbors = 5;  % 使用 5 个邻居
distanceMetric = 'euclidean';  % 使用欧几里得距离

% 训练 KNN 分类器
knnClassifier = fitcknn(...
    trainingFeatures, ...
    trainingLabels, ...
    'NumNeighbors', numNeighbors, ...
    'Distance', distanceMetric);

% 在测试集上评估分类器
predictedLabels = predict(knnClassifier, testFeatures);

% 计算准确率
correctPredictions = (predictedLabels == testLabels);
accuracy = sum(correctPredictions) / numel(testLabels);

% 显示准确率
fprintf('The accuracy of the KNN classifier is: %.2f%%\n', accuracy * 100);
