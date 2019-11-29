%First put a filter [b,a] in global variables
acc1 = 0;
acc2 = 0;
s3 = 0;

sig_in = ones(1,100);
out_buff = zeros(1,100);

for p = 1:length(sig_in)
    s3 = sig_in(p) * b(1) + acc1;
    s3 = s3 / a(1);
    out_buff(p) = s3;
    
    acc1 = sig_in(p) * b(2) + acc2;
    acc1 = acc1 - s3 * a(2);
    
    acc2 = sig_in(p) * b(3);
    acc2 = acc2 - s3 * a(3);
    
end