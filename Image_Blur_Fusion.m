load mask
x1 = X;
load bust
x2 = X;

wv = 'db2';
lv = 5;
xfusmean = wfusimg(x1,x2,wv,lv,'mean','mean');

xfusmaxmin = wfusimg(x1,x2,wv,lv,'max','min');

subplot(2,2,1)
image(x1)
axis square
title('Mask')
subplot(2,2,2)
image(x2)
axis square
title('Bust')
subplot(2,2,3)
image(xfusmean)
axis square 
title('Synthesized Image: mean-mean')
subplot(2,2,4)
image(xfusmaxmin)
axis square
title('Synthesized Image: max-min')
colormap(map)