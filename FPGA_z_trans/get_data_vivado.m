%{
Commands to run in Vivado:
relaunch_sim
open_vcd xsim_dump.vcd
log_vcd /tb_iir/iir1/data_out
run 3ms
close_vcd

%}

fid = fopen('C:\Users\jaspe\Documents\Xilinx_Vivado\multiplier_test\multiplier_test.sim\sim_1\behav\xsim\xsim_dump.vcd');
tline = fgetl(fid);

t = [];
data = [];
p = 1;
while ischar(tline)
    tline = fgetl(fid);
    if mod(p, 10000) == 0
        disp(p);
    end
    p = p + 1;
    if tline(1) == '#'
        time = str2num(tline(2:end)) * 1e-12;
        t = [t time];
        
        tline = fgetl(fid);
        if tline(1) == 'b'
            bin_data = tline(2:end-2);
            data = [data bin2dec(bin_data)];
        else
            data = [data 0]';
        end
    end
end
fclose(fid);

p = 1;
while data(p) == 0
    p = p + 1;
end

t = t(p:end);
t = t - t(1);
data = data(p:end);