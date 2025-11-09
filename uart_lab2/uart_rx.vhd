-- uart_rx.vhd
-- Модуль: UART Приймач (Receiver)
-- Формат: 8-N-1, 16x oversampling
-- Використовує FSM + лічильник семплів

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx is
    Port (
        clk        : in  STD_LOGIC;                      -- Такт (50 МГц)
        reset      : in  STD_LOGIC;                      -- Скид
        rxd        : in  STD_LOGIC;                      -- Лінія прийому (UART RX)
        baud_tick  : in  STD_LOGIC;                      -- Імпульс від baud_rate_gen
        data_out   : out STD_LOGIC_VECTOR(7 downto 0);   -- Прийняті дані
        data_valid : out STD_LOGIC                       -- Дані готові
    );
end uart_rx;

architecture Behavioral of uart_rx is
    -- Стани FSM
    type state_type is (IDLE, START, DATA, STOP);
    signal state         : state_type := IDLE;
    
    -- Лічильник бітів
    signal bit_counter   : integer range 0 to 7 := 0;
    
    -- Лічильник семплів (0..15)
    signal sample_counter : integer range 0 to 15 := 0;
    
    -- Регістр даних
    signal data_reg      : STD_LOGIC_VECTOR(7 downto 0);
    
    -- Семпл по центру бода (8-й з 16)
    constant MID_SAMPLE  : integer := 7;
begin
    process(clk, reset)
    begin
        if reset = '1' then
            state         <= IDLE;
            data_valid    <= '0';
            bit_counter   <= 0;
            sample_counter <= 0;
        elsif rising_edge(clk) and baud_tick = '1' then
            case state is
                when IDLE =>
                    data_valid <= '0';
                    if rxd = '0' then
                        state <= START;
                        sample_counter <= 0;
                    end if;
                    
                when START =>
                    if sample_counter = MID_SAMPLE then
                        if rxd = '0' then
                            state <= DATA;
                            sample_counter <= 0;
                        else
                            state <= IDLE;
                        end if;
                    else
                        sample_counter <= sample_counter + 1;
                    end if;
                    
                when DATA =>
                    if sample_counter = MID_SAMPLE then
                        data_reg(bit_counter) <= rxd;
                        if bit_counter = 7 then
                            state <= STOP;
                        else
                            bit_counter <= bit_counter + 1;
                        end if;
                        sample_counter <= 0;
                    else
                        sample_counter <= sample_counter + 1;
                    end if;
                    
                when STOP =>
                    if sample_counter = MID_SAMPLE and rxd = '1' then
                        data_out   <= data_reg;
                        data_valid <= '1';
                    end if;
                    state <= IDLE;
            end case;
        end if;
    end process;
end Behavioral;