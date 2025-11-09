-- uart_tx.vhd
-- Модуль: UART Передавач (Transmitter)
-- Формат: 8-N-1 (8 біт даних, без паритету, 1 стоп-біт)
-- Використовує FSM (Finite State Machine)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_tx is
    Port (
        clk       : in  STD_LOGIC;                      -- Такт (50 МГц)
        reset     : in  STD_LOGIC;                      -- Скид (активний '1')
        tx_start  : in  STD_LOGIC;                      -- Сигнал початку передачі
        data_in   : in  STD_LOGIC_VECTOR(7 downto 0);   -- Дані для передачі
        baud_tick : in  STD_LOGIC;                      -- Імпульс від baud_rate_gen
        tx_done   : out STD_LOGIC;                      -- Передача завершена
        txd       : out STD_LOGIC                       -- Лінія передачі (UART TX)
    );
end uart_tx;

architecture Behavioral of uart_tx is
    -- Стани FSM
    type state_type is (IDLE, START, DATA, STOP);
    signal state      : state_type := IDLE;
    
    -- Лічильник бітів (0..7)
    signal bit_counter : integer range 0 to 7 := 0;
    
    -- Регістр даних
    signal data_reg   : STD_LOGIC_VECTOR(7 downto 0);
begin
    -- Основний процес FSM
    process(clk, reset)
    begin
        if reset = '1' then
            -- Скид: повертаємо в IDLE, лінія в '1'
            state       <= IDLE;
            txd         <= '1';
            tx_done     <= '0';
            bit_counter <= 0;
        elsif rising_edge(clk) and baud_tick = '1' then
            case state is
                when IDLE =>
                    txd     <= '1';           -- Лінія в спокої
                    tx_done <= '0';
                    if tx_start = '1' then
                        data_reg <= data_in;  -- Захоплюємо дані
                        state    <= START;
                    end if;
                    
                when START =>
                    txd   <= '0';             -- Старт-біт
                    state <= DATA;
                    bit_counter <= 0;
                    
                when DATA =>
                    txd <= data_reg(bit_counter);  -- Передаємо біт
                    if bit_counter = 7 then
                        state <= STOP;
                    else
                        bit_counter <= bit_counter + 1;
                    end if;
                    
                when STOP =>
                    txd     <= '1';           -- Стоп-біт
                    tx_done <= '1';           -- Сигнал завершення
                    state   <= IDLE;
            end case;
        end if;
    end process;
end Behavioral;