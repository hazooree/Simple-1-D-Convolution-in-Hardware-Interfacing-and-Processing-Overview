memy1 = bin2dec(num2str(dlmread('memoryy.list')))/2^8;
y1 = double(fi(memy1,0,16,8));

memy2 = bin2dec(num2str(dlmread('memoryyMATLAB.list')))/2^8;
y2 = double(fi(memy2,0,16,8));

plot(y1);
hold
plot(y2);
legend('Y[n] From Xilinx','Y[n] From Fixed Point Toolbox')
cross       = xcorr(y1,y2);
cross_coeff = max(crosscorr(y1,y2));
RMS   = sqrt(mse(y1,y2));
figure,plot(cross);


