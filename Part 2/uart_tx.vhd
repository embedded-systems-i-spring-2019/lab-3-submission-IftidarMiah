library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_tx is
    port(
    clk, en, send, rst  : in std_logic;     -- When send = 1, store char into register and send data
    char                : in std_logic_vector (7 downto 0);
    ready, tx           : out std_logic -- Ready  = 1 means idle
);
end uart_tx;

architecture fsm of uart_tx is

    -- state type enumeration and state variable
    type state is (idle, start, data);
    signal curr : state := idle;
    
    -- counter for data state
    signal count : std_logic_vector(4 downto 0) := (others => '0');
    
    -- register for storing char
    signal char_reg : std_logic_vector(7 downto 0) := (others => '0');

begin

    -- FSM process (single process implementation)
    process(clk)
    begin
        if rising_edge(clk) then

            -- resets the state machine and its outputs
            if rst = '1' then
                tx <= '1';  -- Asserts high constantly because we are not transmitting or stopping
                curr <= idle;
                char_reg <= (others => '0');
                count <= (others => '0');
                ready <= '1';
                
            -- usual operation
            elsif en = '1' then
                

                
                case curr is
                    when idle =>
                        ready <= '1';
                        tx <= '1';
                        if send = '1' then
                            curr <= start;
                            char_reg <= char;
                        end if;
                        
                    when start =>
                        tx <= '0';  -- Start of data transmission
                        count <= (others => '0');
                        ready <= '0';
                        curr <= data;
    
                    when data =>
                        if unsigned(count) < 8 then
                            tx <= char_reg(0);
                            char_reg <= '0' & char_reg(7 downto 1);
--                            tx <= char_reg(to_integer(unsigned(count)));
                            count <= std_logic_vector(unsigned(count) + 1);
                        else
                            curr <= idle;
                        end if;
                    
                    when others =>
                        curr <= idle;
                        ready <= '1';
                        tx <= '1';
    
                end case;
            end if;
        end if;
    end process;
    
end fsm;