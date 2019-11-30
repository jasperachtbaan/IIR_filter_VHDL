order = 2;
n = 24; %Main number of bits
extra_bit_coeff = 1; %Extra coefficient bits
extra_bit_error = 1; %Extra internal FPGA bits for preventing roundoff errors
wc = 0.0065; %*pi
T = 1/46800;
max_exp = 1;

%[b,a] = butter(order,wc,'high');
[b,a] = designShelvingEQ(6,order/2,wc,'lo' ,'Orientation', 'row');
sys = tf(b, a, 1);
%Make sure that the filter cannot clip with a fixed point implementation
b = b * 0.99 / sum(abs(impulse(sys)));
%Restore the original timing in the system and update with new b
sys = tf(b, a, T);

b_abs = abs(b);
a_abs = abs(a);

if max([a_abs b_abs]) > 2^extra_bit_coeff
    error('Coefficients cannot be larger than 2');
end

max_exp_b = floor(log2(max(b_abs)));
max_exp_a = floor(log2(max(a_abs)));

maxim = max([max_exp_b max_exp_a]);
max_exp_b = maxim;
max_exp_a = maxim;

shift_factor_b = n + extra_bit_error - 1;
shift_factor_a = n + extra_bit_error - 1;

for p = 1:(order + 1)
    val = round(b_abs(p)*2^shift_factor_b);
    bin_b = dec2bin(val);
    bin_b = [char(ones(1,n + extra_bit_coeff + extra_bit_error - length(bin_b)) * '0') bin_b];
    
    if sign(b(p)) == -1
        logicalArray = logical(bin_b - '0');
        logicalArray = not(logicalArray);

        val = sum(logicalArray .* 2.^linspace(length(logicalArray) - 1,0, length(logicalArray))) + 1;
        bin_b = dec2bin(val);
    end
    disp(['constant b' num2str(p - 1) ' : STD_LOGIC_VECTOR ((m - 1) downto 0) := "' bin_b '";']);
end

for p = 2:(order + 1)
    val = round(a_abs(p)*2^shift_factor_a);
    bin_a = dec2bin(val);
    bin_a = [char(ones(1,n + extra_bit_coeff + extra_bit_error - length(bin_a)) * '0') bin_a];
    
    signComp = -1;
    if p > 1
        signComp = 1;
    end
    
    if sign(a(p)) == signComp
        logicalArray = logical(bin_a - '0');
        logicalArray = not(logicalArray);

        val = sum(logicalArray .* 2.^linspace(length(logicalArray) - 1,0, length(logicalArray))) + 1;
        bin_a = dec2bin(val);
    end
    disp(['constant a' num2str(p - 1) ' : STD_LOGIC_VECTOR ((m - 1) downto 0) := "' bin_a '";']);
end


step(sys);