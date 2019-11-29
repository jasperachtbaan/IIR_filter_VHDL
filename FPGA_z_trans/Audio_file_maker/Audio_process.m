n = 24;
[y,Fs] = audioread('Lovestad.wav');
fileID = fopen('Lovestad.bin','w');

y = y(2000:10*44100,1); %Only select left channel
y = y * (2^(n - 2) - 1);

for p = 1:length(y)
    bin = y(p);
    bin = dec2bin(abs(bin));
    bin = [char(ones(1,n - length(bin)) * '0') bin];

    if sign(y(p)) == -1
        logicalArray = logical(bin - '0');
        logicalArray = not(logicalArray);

        val = sum(logicalArray .* 2.^linspace(length(logicalArray) - 1,0, length(logicalArray))) + 1;
        
        %bin = dec2bin(val)
        bin = dec2bin(val);
    end
    
    fwrite(fileID,[bin newline],'char');
end


fclose(fileID);

