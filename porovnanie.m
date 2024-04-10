pic1 = double(imread('C:\Users\Martin\Documents\Vzdelanie\Inzinierske FEI\ZS2rocnik\DP\Matlab_vsetko\MatlabProjekt\Saved_Output\xi_stripLED_HDR_RL_smallest.png'));
pic2 = double(imread('C:\Users\Martin\Documents\Vzdelanie\Inzinierske FEI\ZS2rocnik\DP\Matlab_vsetko\MatlabProjekt\Saved_Output\xi_stripLED_HDR_RL_zle.png'));
pic3 = double(imread('C:\Users\Martin\Documents\Vzdelanie\Inzinierske FEI\ZS2rocnik\DP\Matlab_vsetko\MatlabProjekt\Saved_Output\xi_stripLED_HDR_RL_mean.png'));

pic4 = double(imread('C:\Users\Martin\Documents\Vzdelanie\Inzinierske FEI\ZS2rocnik\DP\Matlab_vsetko\MatlabProjekt\Saved_Output\xi_stripLED_custom_HDR.png'));
pic5 = double(imread('C:\Users\Martin\Documents\Vzdelanie\Inzinierske FEI\ZS2rocnik\DP\Matlab_vsetko\MatlabProjekt\Saved_Output\xi_stripLED_custom_HDR_noFill.png'));
pic6 = double(imread('C:\Users\Martin\Documents\Vzdelanie\Inzinierske FEI\ZS2rocnik\DP\Matlab_vsetko\MatlabProjekt\Saved_Output\xi_stripLED_custom_HDR_NormalizationDiff.png'));
%relativna_expozicia normovana min porovnana s priamo vlozenou expoziciou v ms
MSE12 = calculateMSE(pic1,pic2)
%relativna_expozicia normovana min porovnana s normovanou mean
MSE13 = calculateMSE(pic1,pic3)
%hodnoty expozicie porovnanen s relativnou normovanou min
MSE23 = calculateMSE(pic2,pic3)

%porovnanie mojho kodu s a bez pridanych "fillerov"
MSE_custom_FILL_noFill = calculateMSE(pic4,pic5)

MSE_custom_pic3 = calculateMSE(pic3,pic5)
MSE_auto_custom_pic3 = immse(pic3,pic4)
MSE_new_mean36 = immse(pic3,pic6)
m = localtonemap