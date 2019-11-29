library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package SGTL5000_pack is
    constant setup_num : integer := 19;

    constant SGTL5000_CHIP_ID               : std_logic_vector(15 downto 0) := x"0000";
    constant SGTL5000_CHIP_DIG_POWER        : std_logic_vector(15 downto 0) := x"0002";
    constant SGTL5000_CHIP_CLK_CTRL         : std_logic_vector(15 downto 0) := x"0004";
    constant SGTL5000_CHIP_I2S_CTRL         : std_logic_vector(15 downto 0) := x"0006";
    constant SGTL5000_CHIP_SSS_CTRL         : std_logic_vector(15 downto 0) := x"000a";
    constant SGTL5000_CHIP_ADCDAC_CTRL      : std_logic_vector(15 downto 0) := x"000e";
    constant SGTL5000_CHIP_DAC_VOL          : std_logic_vector(15 downto 0) := x"0010";
    --- 0x0012 ?
    constant SGTL5000_CHIP_PAD_STRENGTH     : std_logic_vector(15 downto 0) := x"0014";
    --- 0x0016 ?
    constant SGTL5000_CHIP_ANA_ADC_CTRL     : std_logic_vector(15 downto 0) := x"0020";
    constant SGTL5000_CHIP_ANA_HP_CTRL      : std_logic_vector(15 downto 0) := x"0022";
    constant SGTL5000_CHIP_ANA_CTRL         : std_logic_vector(15 downto 0) := x"0024";
    constant SGTL5000_CHIP_LINREG_CTRL      : std_logic_vector(15 downto 0) := x"0026";
    constant SGTL5000_CHIP_REF_CTRL         : std_logic_vector(15 downto 0) := x"0028";
    constant SGTL5000_CHIP_MIC_CTRL         : std_logic_vector(15 downto 0) := x"002a";
    constant SGTL5000_CHIP_LINE_OUT_CTRL    : std_logic_vector(15 downto 0) := x"002c";
    constant SGTL5000_CHIP_LINE_OUT_VOL     : std_logic_vector(15 downto 0) := x"002e";
    constant SGTL5000_CHIP_ANA_POWER        : std_logic_vector(15 downto 0) := x"0030";
    constant SGTL5000_CHIP_PLL_CTRL         : std_logic_vector(15 downto 0) := x"0032";
    constant SGTL5000_CHIP_CLK_TOP_CTRL     : std_logic_vector(15 downto 0) := x"0034";
    constant SGTL5000_CHIP_ANA_STATUS       : std_logic_vector(15 downto 0) := x"0036";
    constant SGTL5000_CHIP_ANA_TEST1        : std_logic_vector(15 downto 0) := x"0038";
    constant SGTL5000_CHIP_ANA_TEST2        : std_logic_vector(15 downto 0) := x"003a";
    constant SGTL5000_CHIP_SHORT_CTRL       : std_logic_vector(15 downto 0) := x"003c";

    -- DAP (Digital Audio Processor) Registers
    constant SGTL5000_DAP_CTRL              : std_logic_vector(15 downto 0) := x"0100";
    constant SGTL5000_DAP_PEQ               : std_logic_vector(15 downto 0) := x"0102";
    constant SGTL5000_DAP_BASS_ENHANCE      : std_logic_vector(15 downto 0) := x"0104";
    constant SGTL5000_DAP_BASS_ENHANCE_CTRL : std_logic_vector(15 downto 0) := x"0106";
    constant SGTL5000_DAP_AUDIO_EQ          : std_logic_vector(15 downto 0) := x"0108";
    constant SGTL5000_DAP_SURROUND          : std_logic_vector(15 downto 0) := x"010a";
    constant SGTL5000_DAP_FLT_COEF_ACCESS   : std_logic_vector(15 downto 0) := x"010c";
    constant SGTL5000_DAP_COEF_WR_B0_MSB    : std_logic_vector(15 downto 0) := x"010e";
    constant SGTL5000_DAP_COEF_WR_B0_LSB    : std_logic_vector(15 downto 0) := x"0110";
    constant SGTL5000_DAP_EQ_BASS_BAND0     : std_logic_vector(15 downto 0) := x"0116";
    constant SGTL5000_DAP_EQ_BASS_BAND1     : std_logic_vector(15 downto 0) := x"0118";
    constant SGTL5000_DAP_EQ_BASS_BAND2     : std_logic_vector(15 downto 0) := x"011a";
    constant SGTL5000_DAP_EQ_BASS_BAND3     : std_logic_vector(15 downto 0) := x"011c";
    constant SGTL5000_DAP_EQ_BASS_BAND4     : std_logic_vector(15 downto 0) := x"011e";
    constant SGTL5000_DAP_MAIN_CHAN         : std_logic_vector(15 downto 0) := x"0120";
    constant SGTL5000_DAP_MIX_CHAN          : std_logic_vector(15 downto 0) := x"0122";
    constant SGTL5000_DAP_AVC_CTRL          : std_logic_vector(15 downto 0) := x"0124";
    constant SGTL5000_DAP_AVC_THRESHOLD     : std_logic_vector(15 downto 0) := x"0126";
    constant SGTL5000_DAP_AVC_ATTACK        : std_logic_vector(15 downto 0) := x"0128";
    constant SGTL5000_DAP_AVC_DECAY         : std_logic_vector(15 downto 0) := x"012a";
    constant SGTL5000_DAP_COEF_WR_B1_MSB    : std_logic_vector(15 downto 0) := x"012c";
    constant SGTL5000_DAP_COEF_WR_B1_LSB    : std_logic_vector(15 downto 0) := x"012e";
    constant SGTL5000_DAP_COEF_WR_B2_MSB    : std_logic_vector(15 downto 0) := x"0130";
    constant SGTL5000_DAP_COEF_WR_B2_LSB    : std_logic_vector(15 downto 0) := x"0132";
    constant SGTL5000_DAP_COEF_WR_A1_MSB    : std_logic_vector(15 downto 0) := x"0134";
    constant SGTL5000_DAP_COEF_WR_A1_LSB    : std_logic_vector(15 downto 0) := x"0136";
    constant SGTL5000_DAP_COEF_WR_A2_MSB    : std_logic_vector(15 downto 0) := x"0138";
    constant SGTL5000_DAP_COEF_WR_A2_LSB    : std_logic_vector(15 downto 0) := x"013a";
    
    type SETUP_VECT is array (0 to (setup_num - 1)) of STD_LOGIC_VECTOR (31 downto 0);
    
    signal SGTL5000_settings : SETUP_VECT := ( SGTL5000_CHIP_ANA_POWER & x"4160",
                                               SGTL5000_CHIP_LINREG_CTRL & x"006C",
                                               SGTL5000_CHIP_PLL_CTRL & x"8312",
                                               SGTL5000_CHIP_I2S_CTRL & x"0010",
                                               SGTL5000_CHIP_LINE_OUT_CTRL & x"0F22",
                                               SGTL5000_CHIP_SHORT_CTRL & x"4446",
                                               SGTL5000_CHIP_ANA_CTRL & x"0137",
                                               SGTL5000_CHIP_ANA_POWER & x"45FF",
                                               SGTL5000_CHIP_DIG_POWER & x"0073",
                                               SGTL5000_CHIP_LINE_OUT_VOL & x"1D1D",
                                               SGTL5000_CHIP_CLK_CTRL & x"0008",
                                               SGTL5000_CHIP_SSS_CTRL & x"0010", --ADC->I2S, I2S->DAC
                                               SGTL5000_CHIP_ADCDAC_CTRL & x"0000",
                                               SGTL5000_CHIP_DAC_VOL & x"3C3C",
                                               SGTL5000_CHIP_ANA_HP_CTRL & x"3030",
                                               SGTL5000_CHIP_ANA_CTRL & x"0026",
                                               SGTL5000_CHIP_PAD_STRENGTH & x"0030",
                                               SGTL5000_CHIP_ANA_ADC_CTRL & x"00FF",
                                               SGTL5000_CHIP_REF_CTRL & x"01F2");
                                               
 
    
end SGTL5000_pack;