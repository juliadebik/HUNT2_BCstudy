[Data_num, Data_str, Data_all] = xlsread('Molecules.xlsx');

data = Data_num;

seed = 1610;
rng(seed);
cv = cvpartition(size(data,1),'KFold',8);

AUC = zeros(8, 1);
Accuracy = zeros(8, 1);
nloadings = zeros(8, 1);

for i = 1:8
    dataTrain = data(cv.training(i),:);
    dataTest  = data(cv.test(i),:);

    Xtrain = dataTrain(:,5:end);
    Ytrain = dataTrain(:,1);

    Xtest = dataTest(:,5:end);
    Ytest = dataTest(:,1);

    opts               = plsda('options');
    opts.plots = {'none'};
    opts.preprocessing = {preprocess('default','autoscale')};

    [results] = crossval(Xtrain, Ytrain,'plsda',{'rnd',10,10},20,opts);
    [loadings_min, min_indx] = min(results.classerrcv(1,:));

    nloadings(i) = min_indx;
    plsda_model = plsda(Xtrain, Ytrain, min_indx, opts);

    predict = plsda(Xtest, Ytest, plsda_model, opts);
    pred_prob = predict.classification.probability(:,1);

    Ypred = pred_prob;
    Ypred(pred_prob < 0.5) = 0;
    Ypred(pred_prob >= 0.5) = 1;

    [X, Y, T, auc] = perfcurve(double(Ytest),pred_prob,1);

    conf = confusionmat(Ytest, Ypred);
    accuracy = (conf(1,1)+conf(2,2))/(sum(sum(conf)));

    AUC(i) = auc;
    Accuracy(i) = accuracy;
end





