-- Iftidar Miah
-- imm45 ASCII
-- i = 01101001
-- m = 01101101
-- m = 01101101
-- 4 = 00110100
-- 5 = 00110101

-- Showed partial demo on 4/4/19 but the output was iÿmÿmÿ4ÿ5ÿ and I'm not sure how to fix it. 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity sender is
  port (    rst, clk, en, btn, rdy          : in std_logic;
            send                            : out std_logic;
            char                            : out std_logic_vector(7 downto 0));
end sender;

architecture sender_arch of sender is
    type ASCII is array (0 to 4) of std_logic_vector(7 downto 0);   -- 2D array storing ASCII imm45
    constant NETID : ASCII := (
    0 => "01101001",
    1 => "01101101",
    2 => "01101101",
    3 => "00110100",
    4 => "00110101");
    
    type state is (idle, busyA, busyB, busyC);
    signal curr : state := idle;
    
    signal i    : std_logic_vector(2 downto 0) := (others => '0'); -- counter to count up to 5
    
begin

    fsm_proc: process(clk)
    begin
        if rising_edge(clk) then
            
            if en = '1' then
                
                if rst = '1' then
                    send <= '0';
                    char <= (others => '0');
                    i <= (others => '0');
                    curr <= idle;
                end if;
            
            
                case curr is
                    when idle =>
                        if (rdy = '1' AND btn = '1') then
                            if unsigned(i) < 5 then
                                send <= '1';
                                char <= NETID(to_integer(unsigned(i)));
                                i <= std_logic_vector(unsigned(i) + 1);
                                curr <= busyA;
                            else
                                i <= (others => '0');
                            end if;
                        end if;
                    
                    when busyA =>
                        curr <= busyB;
                    
                    when busyB =>
                        send <= '0';
                        curr <= busyC;
                        
                    when busyC =>
                        if (rdy = '1' AND btn = '0') then
                            curr <= idle;
                        end if;
                        
                end case;
            end if;  
        end if;
    end process fsm_proc;

end sender_arch;
