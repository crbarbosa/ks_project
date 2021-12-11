----------------------------------------------------------------------------------
-- Trabalho K&S
-- Alunos: Carlos Ricardo, Debora Garcia
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.k_and_s_pkg.all;

entity data_path is
  port (
    rst_n               : in  std_logic;
    clk                 : in  std_logic;
    branch              : in  std_logic;
    pc_enable           : in  std_logic;
    ir_enable           : in  std_logic;
    addr_sel            : in  std_logic;
    c_sel               : in  std_logic;
    operation           : in  std_logic_vector ( 1 downto 0);
    write_reg_enable    : in  std_logic;
    flags_reg_enable    : in  std_logic;
    decoded_instruction : out decoded_instruction_type;
    zero_op             : out std_logic;
    neg_op              : out std_logic;
    unsigned_overflow   : out std_logic;
    signed_overflow     : out std_logic;
    ram_addr            : out std_logic_vector ( 4 downto 0);
    data_out            : out std_logic_vector (15 downto 0);
    data_in             : in  std_logic_vector (15 downto 0)
  );
end data_path;

architecture rtl of data_path is

type reg_bank_type is array(natural range <>) of std_logic_vector(15 downto 0);
  signal banco_de_reg : reg_bank_type(0 to 3);
  signal  bus_a : std_logic_vector(15 downto 0);
  signal  bus_b : std_logic_vector(15 downto 0);
  signal  bus_c : std_logic_vector(15 downto 0);
  signal  a_addr :  std_logic_vector(1 downto 0);
  signal  b_addr :  std_logic_vector(1 downto 0);
  signal  c_addr :  std_logic_vector(1 downto 0);
  signal  ula_out :  std_logic_vector(15 downto 0);
  signal  instruction :  std_logic_vector(15 downto 0);
  signal  mem_addr  : std_logic_vector(4 downto 0);
  signal  program_counter : std_logic_vector(4 downto 0);

begin
  
  --Banco de registradores
  bus_a <= banco_de_reg(conv_integer(a_addr));
  bus_b <= banco_de_reg(conv_integer(b_addr));
  bus_c <= ula_out when (c_sel = '0') else data_in; 

  --Mux RAM
  ram_addr <= mem_addr when (addr_sel = '0') else program_counter;

  --Decoder
  --Recebi: A11B
  --Decode: decoded instruction <= ADD
  --a_addr <= end. reg
  --b_addr <= end. reg
  --c_addr <= end. reg