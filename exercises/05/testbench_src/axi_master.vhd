----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/30/2018 11:09:12 AM
-- Design Name: 
-- Module Name: axi_master - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity axi_master is
    generic (
        addr_width_g        : integer;
        data_width_g        : integer
    );
    port (
        -- Common
        ACLK                : in std_logic;
        rst                 : in std_logic;
        -- Input
        write_address       : in std_logic_vector(addr_width_g-1 downto 0);
        write_data          : in std_logic_vector(data_width_g-1 downto 0);
        write_start         : in std_logic;
        write_done          : out std_logic;
        -- AXI4-Lite master channel signals
        m_axi_awaddr        : out std_logic_vector(addr_width_g-1 downto 0);
        m_axi_awvalid       : out std_logic := '0';
        m_axi_awready       : in std_logic := '0';
        m_axi_wdata         : out std_logic_vector(data_width_g-1 downto 0);
        m_axi_wvalid        : out std_logic := '0';
        m_axi_wready        : in std_logic := '0';
        m_axi_bresp         : in std_logic_vector(1 downto 0);
        m_axi_bvalid        : in std_logic := '0';
        m_axi_bready        : out std_logic := '0'
    );
end axi_master;

architecture Behavioral of axi_master is
    signal slave_responded_r    : std_logic := '1';
    signal write_done_r         : std_logic := '0';
begin

    write_done <= write_done_r;
    
     process(ACLK)
     begin
         if(rst = '1') then
             slave_responded_r <= '1';
             write_done_r <= '0';
         elsif(rising_edge(ACLK)) then 
             -- Slave is not sending a write response
             if(m_axi_bvalid = '0') then
                 m_axi_bready <= '0';
             -- Slave indicates a slave response
             elsif(m_axi_bvalid = '1') then
                 m_axi_bready <= '1'; -- Accept the slave write response
                 slave_responded_r <= '1';
             end if;
             
             -- Test bench requests for a write
             if(write_start = '1') then
                write_done_r <= '0';
             end if;
             
             if((m_axi_awready = '0') and (m_axi_wready = '0') and (slave_responded_r = '1') and (write_start = '1')) then
                 m_axi_awaddr <= write_address;
                 m_axi_awvalid <= '1';
                 m_axi_wdata <= write_data;
                 m_axi_wvalid <= '1';
                 slave_responded_r <= '0';
             -- Slave has accepted the address and data
             elsif((m_axi_awready = '1') and (m_axi_wready = '1')) then
                 m_axi_awaddr <= (others => '0');
                 m_axi_awvalid <= '0';
                 m_axi_wdata <= (others => '0');
                 m_axi_wvalid <= '0';
                 write_done_r <= '1';
             end if;
         end if;
     end process;
end Behavioral;