----------------------------------------------------------------------------------
-- Trabalho K&S
-- Alunos: Carlos Ricardo, Debora Garcia
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.k_and_s_pkg.all;

entity control_unit is
  port (
    rst_n               : in  std_logic;
    clk                 : in  std_logic;
    branch              : out std_logic;
    pc_enable           : out std_logic;
    ir_enable           : out std_logic;
    write_reg_enable    : out std_logic;
    addr_sel            : out std_logic;
    c_sel               : out std_logic;
    operation           : out std_logic_vector (1 downto 0);
    flags_reg_enable    : out std_logic;
    decoded_instruction : in  decoded_instruction_type;
    zero_op             : in  std_logic;
    neg_op              : in  std_logic;
    unsigned_overflow   : in  std_logic;
    signed_overflow     : in  std_logic;
    ram_write_enable    : out std_logic;
    halt                : out std_logic
    );
end control_unit;

architecture rtl of control_unit is

type estados is (
    FETCH,
    DECODE,
    PROX,
    PROX1,
    LOAD,
    LOAD1,
    STORE,
    MOVE,
    ULA,
    BRANCHI,
    NOP,
    HALTI
    );
    signal estado_atual : estados;
    signal prox_estado : estados;
begin
    process (clk)
        begin
            if (clk'event and clk='1') then
                if (rst_n='0') then
                    estado_atual <= FETCH;
                else
                    estado_atual <= prox_estado;
                end if;
            end if;
    end process;
