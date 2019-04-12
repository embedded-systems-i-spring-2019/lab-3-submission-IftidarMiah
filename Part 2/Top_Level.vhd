library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Top_Level is
    port(   clk : in std_logic;
            btn : in std_logic_vector(1 downto 0);
            TXD : in std_logic;
            RXD : out std_logic;
--            newChar : out std_logic;
            CTS, RTS    : out std_logic);
--            charRec : out std_logic_vector (7 downto 0));
end Top_Level;

architecture Top_Level_arch of Top_Level is
    
    signal rst, sender_btn, en, ready, send :   std_logic;
    signal char                             :   std_logic_vector(7 downto 0);
    
    signal zero                             :   std_logic:= '0';
    signal zeroes                           :   std_logic_vector(7 downto 0) := (others => '0');
    
    component sender is
        port (  rst, clk, en, btn, rdy          : in std_logic;
                send                            : out std_logic;
                char                            : out std_logic_vector(7 downto 0));
    end component;
    
    component uart
        port (
    
                clk, en, send, rx, rst      : in std_logic;
                charSend                    : in std_logic_vector (7 downto 0);
                ready, tx, newChar          : out std_logic;
                charRec                     : out std_logic_vector (7 downto 0));
    end component;
    
    component debounce
        port(   clk, btn0    : in    std_logic;
                dbnc         : out   std_logic);
    end component;
    
    component clock_div
        port(   clk    : in    std_logic;
                div    : out    std_logic);
    end component;
    
begin

    CTS <= '0';     -- Grounding CTS and RTS, connect PMOD JB7 Y18 pin5 = GND
    RTS <= '0';

    u1: debounce
        Port Map(    clk     => clk,
                     btn0     => btn(0),
                     dbnc    => rst
        );

    u2: debounce
        Port Map(    clk     => clk,
                     btn0     => btn(1),
                     dbnc    => sender_btn
        );
        
    u3: clock_div
        Port Map(   clk => clk,
                    div => en
        );
        
    u4: sender
        Port Map(   rst => rst, 
                    clk => clk, 
                    en  => en, 
                    btn => sender_btn, 
                    rdy => ready,
                    send => send,
                    char => char
        );
        
    u5: UART
        Port Map(   clk => clk, 
                    en => en, 
                    send => send, 
                    rx => TXD, 
                    rst => rst,
                    charSend => char,
                    ready => ready, 
                    tx => RXD
--                    newChar => newChar,
--                    charRec => charRec
        );
end Top_Level_arch;
