% 步骤1：加载训练好的KNN模型
model = load('knnModel.mat');
knnModel = model.knnClassifier; % .mat文件中的变量名称是knnClassifier

% 步骤2：分割图像并获取边界框
imagePath = 'hello_world.png'; % 图像文件的路径
img = imread(imagePath); % 读取图像

% 设置过滤阈值
widthThreshold = 50;    % 宽度阈值
areaThreshold = 400;    % 面积阈值
heightThreshold = 40;   % 高度阈值

% 'splitAndDisplayBoundingBoxes'函数返回边界框
bboxes = splitAndDisplayBoundingBoxes(imagePath, widthThreshold, areaThreshold, heightThreshold);

% 步骤3：对于每个边界框，提取特征并预测标签
recognizedText = ''; % 初始化一个空字符串来存储识别的文本
outputImage = img; % 初始化输出图像

for i = 1:size(bboxes, 1)
    % 从边界框中裁剪出字符图像
    try
        charImage = imcrop(img, bboxes(i,:));
    catch ME
        warning('无法裁剪图像：%s', ME.message);
        continue; % 如果出错，跳过当前循环
    end

    % 调整图像大小为 128x128 像素
    charImage = imresize(charImage, [128, 128]);

    % 将裁剪的图像保存为临时文件
    tempFileName = fullfile(tempdir, ['tempImage_', num2str(i), '.png']);
    imwrite(charImage, tempFileName);

    % 使用保存的图像文件创建ImageDatastore
    imds = imageDatastore(tempFileName);

    % 使用featureExtractor函数提取特征
    features = featureExtractor(imds); % 确保这个函数接受ImageDatastore作为输入

    % 使用KNN模型预测标签
    label = predict(knnModel, features);

    if iscategorical(label)
        label = char(label); 
    end
    label = label(end);
    % 将标签拼接到识别文本字符串
    recognizedText = [recognizedText, label];

    % 计算边界框的中心位置
    position = [bboxes(i,1) + bboxes(i,3)/2, bboxes(i,2) + bboxes(i,4)/2];

    % 将标签写在图像的相应位置
    outputImage = insertText(outputImage, position, label, 'AnchorPoint', 'Center');

    % 删除临时文件
    delete(tempFileName);
end

% 步骤4：输出识别的文本
disp(['识别的文本: ', recognizedText]);

% 显示带有文本标签的图像
imshow(outputImage);
