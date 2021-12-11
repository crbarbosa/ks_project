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
    process(clk,estado_atual)
        begin
            prox_estado <= estado_atual;
            case(estado_atual) is
                when FETCH =>
                    --ram_write_enable <= '0';
                    addr_sel <= '1';
                    c_sel <= '0';
                    ir_enable <= '1';
                    flags_reg_enable <= '0';
                    pc_enable <='0';
                    write_reg_enable <='0';
                    halt <= '0';
                    prox_estado <= DECODE;
                when DECODE =>
                    ir_enable <= '0';
                    case decoded_instruction is
                        when I_NOP =>
                            prox_estado <= NOP;
                            
                        when I_MOVE =>
                            prox_estado <= MOVE;
                        
                        when I_STORE =>
                            prox_estado <= STORE;
                            
                        when I_LOAD =>
                            prox_estado <= LOAD;

                        when I_OR =>
                            operation <= "00";
                            prox_estado <= ULA;

                        when I_ADD =>
                            operation <= "01";
                            prox_estado <= ULA;

                        when I_SUB =>
                            operation <= "10";
                            prox_estado <= ULA;

                        when I_AND =>
                            operation <= "11";
                            prox_estado <= ULA;

                        when I_BRANCH =>
                            prox_estado <= BRANCHI;

                        when I_BNEG =>
                            if (neg_op = '1') then
                                prox_estado <= BRANCHI;
                            else
                                prox_estado <= PROX;
                            end if;
                        when I_BZERO =>
                            if (zero_op = '1') then
                                prox_estado <= BRANCHI;
                            else
                                prox_estado <= PROX;
                            end if;
                        when others =>
                            prox_estado <= HALTI;
                    end case;
                when NOP =>
                    ir_enable <= '0';
                    flags_reg_enable <= '0';
                    branch <= '0';
                    pc_enable <='0';
                    halt <= '0';
                    write_reg_enable <='0';
                    prox_estado <= PROX;

                when HALTI =>
                    ir_enable <= '0';
                    flags_reg_enable <= '0';
                    branch <= '0';
                    pc_enable <='0';
                    write_reg_enable <='0';
                    halt <= '1';
                    prox_estado <= HALTI;

                when LOAD =>
                    ir_enable <= '0';
                    flags_reg_enable <= '0';
                    addr_sel <= '0';
                    branch <= '0';
                    halt <= '0';
                    write_reg_enable <= '0';
                    prox_estado <= LOAD1;
                    
                when LOAD1 =>
                    c_sel <= '1';
                    write_reg_enable <= '1';
                    prox_estado <= PROX;

                when STORE =>
                    addr_sel <= '0';    
                    ram_write_enable <= '1';
                    prox_estado <= PROX;      

                when MOVE =>
                    ir_enable <= '0';
                    flags_reg_enable <= '0';
                    operation <= "00";
                    c_sel <= '0';
                    halt <= '0';
                    write_reg_enable <= '1';
                    prox_estado <= PROX;
                    
                when ULA =>
                    c_sel <= '0';
                    write_reg_enable <= '1';
                    ir_enable <= '0';
                    flags_reg_enable <= '1';
                    prox_estado <= PROX;

                when BRANCHI =>
                    branch <= '1';
                    ir_enable <= '0';
                    flags_reg_enable <= '0';
                    addr_sel <= '0';  
                    prox_estado <= PROX;

                when PROX =>       
                    ir_enable <= '0';
                    flags_reg_enable <= '0';
                    pc_enable <='1';
                    addr_sel <= '1';
                    halt <= '0';
                    write_reg_enable <='0';
                    ram_write_enable <='0';
                    prox_estado <= PROX1;
            
                when others =>  --PROX1
                    branch <= '0';
                    ir_enable <= '0';
                    flags_reg_enable <= '0';
                    pc_enable <='0';
                    halt <= '0';
                    write_reg_enable <='0';
                    prox_estado <= FETCH;
            end case ;
    end process ;
end rtl;