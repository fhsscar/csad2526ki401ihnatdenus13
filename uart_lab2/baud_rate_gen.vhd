-- baud_rate_gen.vhd
-- Модуль: Генератор тактового імпульсу для UART (baud tick)
-- Тактова частота: 50 МГц
-- Baud rate: 115200 бод
-- Кількість тактів на 1 бод: 50_000_000 / 115_200 ≈ 434

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity baud_rate_gen is
    Generic (
        CLK_FREQ  : integer := 50_000_000;  -- Вхідна тактова частота (Гц)
        BAUD_RATE : integer := 115_200      -- Бажана швидкість передачі (бод)
    );
    Port (
        clk       : in  STD_LOGIC;          -- Вхідний такт (50 МГц)
        reset     : in  STD_LOGIC;          -- Асинхронний скид (активний '1')
        baud_tick : out STD_LOGIC           -- Імпульс 1 раз на бод (115200 Гц)
    );
end baud_rate_gen;

architecture Behavioral of baud_rate_gen is
    -- Константа: кількість тактів на 1 бод
    constant TICKS_PER_BAUD : integer := CLK_FREQ / BAUD_RATE;
    
    -- Лічильник тактів
    signal counter : integer range 0 to TICKS_PER_BAUD - 1 := 0;
    
    -- Вихідний імпульс
    signal tick : STD_LOGIC := '0';
begin
    -- Процес генерації baud_tick
    process(clk, reset)
    begin
        if reset = '1' then
            -- Скид: обнуляємо лічильник і імпульс
            counter <= 0;
            tick    <= '0';
        elsif rising_edge(clk) then
            if counter = TICKS_PER_BAUD - 1 then
                -- Досягли кінця бод → видаємо імпульс
                counter <= 0;
                tick    <= '1';
            else
                counter <= counter + 1;
                tick    <= '0';
            end if;
        end if;
    end process;
    
    -- Присвоюємо вихід
    baud_tick <= tick;
end Behavioral;