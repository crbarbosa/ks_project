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

  process (instruction)
  begin
    --decoded_instruction <= I_NOP;
    a_addr <= "00";
    b_addr <= "00";
    c_addr <= "00";
    mem_addr <= instruction(4 downto 0);

    if ((instruction(15 downto 13)) = "101") then
      c_addr <= instruction(5 downto 4);
      elsif (instruction(15 downto 12) = "1000") then
        c_addr <= instruction(6 downto 5);
      elsif (instruction(15 downto 12) = "1001") then
        c_addr <= instruction(3 downto 2);
    end if ;

    if (instruction(15) = '0')  then
      case (instruction(9 downto 8)) is
        when "01" =>
          decoded_instruction <= I_BRANCH;
        when "10" =>
          decoded_instruction <= I_BZERO;
        when "11" =>
          decoded_instruction <= I_BNEG;
        when others => 
          decoded_instruction <= I_NOP;
      end case;

    elsif (instruction(15) = '1') then
      case (instruction(14 downto 7)) is
        when "00100010" =>  --MOVE
          decoded_instruction <= I_MOVE;
        when "01000010" => --ADD
          decoded_instruction <= I_ADD;
        when "01000100" => --SUB
          decoded_instruction <= I_SUB;
        when "01000110" => --AND
          decoded_instruction <= I_AND;
        when "01001000" => --OR
          decoded_instruction <= I_OR;
        when "00000010" => --LOAD
          decoded_instruction <= I_LOAD;
        when "00000100" => --STORE
          decoded_instruction <= I_STORE;
        when others =>
          decoded_instruction <= I_HALT;
      end case;
    end if ;
    
    
    if (instruction(14 downto 7) = "00100010") then --MOVE
      a_addr <= instruction(1 downto 0);
      b_addr <= instruction(1 downto 0);
    elsif (instruction(14 downto 7) = "00000100") then  --STORE
      a_addr <= instruction(6 downto 5);
    else  --Outras operacoes
      a_addr <= instruction(3 downto 2);
      b_addr <= instruction(1 downto 0);  
    end if;
  end process;

  
  
  --Controle da ULA
  process(bus_a,bus_b,operation)
    begin
      data_out <= bus_a;
      if (operation = "11") then
        ula_out <=  bus_a and bus_b;--AND   11
      elsif (operation = "10")  then
        ula_out <=  bus_a - bus_b;  --SUB   10
      elsif (operation = "01") then
        ula_out <=  bus_a + bus_b;  --ADD   01
      else
        ula_out <= bus_a or bus_b;  --OR    00
      end if;
  end process;

  process(clk)
  begin
    if (clk'event and clk = '1') then
      --Banco de Registradores
      if (write_reg_enable = '1') then
        banco_de_reg(conv_integer(a_addr)) <= bus_a;
        banco_de_reg(conv_integer(b_addr)) <= bus_b;
        banco_de_reg(conv_integer(c_addr)) <= bus_c;
      end if ;