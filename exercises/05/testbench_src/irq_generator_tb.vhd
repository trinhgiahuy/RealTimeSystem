library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity irq_generator_tb is
    generic (
        data_width_g        : integer := 32;
        addr_width_g        : integer := 16;
        number_of_irqs_g    : integer := 16
    );
end irq_generator_tb;

architecture testbench of irq_generator_tb is   
    
    component axi_master
        generic(
            addr_width_g        : integer;
            data_width_g        : integer
        );
        port(
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
    end component;
        
    component irq_generator
        generic(
            C_S_AXI_DATA_WIDTH      : integer;
            C_S_AXI_ADDR_WIDTH      : integer;
            C_AMOUNT_OF_IRQLINES    : integer
        );
        port(
            -- Common input
            ACLK                : in std_logic;
            ARESETN             : in std_logic;
            -- Ouput
            irqgen_introut      : out std_logic_vector(15 downto 0);
            -- AXI4-Lite slave channel
            -- Write address channel
            S_AXI_AWADDR        : in std_logic_vector(addr_width_g-1 downto 0);
            S_AXI_AWPROT        : in std_logic_vector(2 downto 0);
            S_AXI_AWVALID       : in std_logic;
            S_AXI_AWREADY       : out std_logic;
            -- Write data channel
            S_AXI_WDATA         : in std_logic_vector(data_width_g-1 downto 0);
            S_AXI_WSTRB         : in std_logic_vector((data_width_g/8)-1 downto 0);
            S_AXI_WVALID        : in std_logic;
            S_AXI_WREADY        : out std_logic;
            -- Write response channel
            S_AXI_BRESP         : out std_logic_vector(1 downto 0);
            S_AXI_BVALID        : out std_logic;
            S_AXI_BREADY        : in std_logic;
            -- Read address channel
            S_AXI_ARADDR        : in std_logic_vector(addr_width_g-1 downto 0);
            S_AXI_ARPROT        : in std_logic_vector(2 downto 0);
            S_AXI_ARVALID       : in std_logic;
            S_AXI_ARREADY       : out std_logic;
            -- Read data channnel
            S_AXI_RDATA         : out std_logic_vector(data_width_g-1 downto 0);
            S_AXI_RRESP         : out std_logic_vector(1 downto 0);
            S_AXI_RVALID        : out std_logic;
            S_AXI_RREADY        : in std_logic 
        );
    end component;
    
    -- Constants
    constant period_10ns_c	    : time := 10 ns;       -- For 100MHz clock gen
    constant ctrl_reg_addr_c    : std_logic_vector(addr_width_g-1 downto 0) := B"0000_0000_0000_0000"; -- 0x0000
    constant genirq_reg_addr_c  : std_logic_vector(addr_width_g-1 downto 0) := B"0000_0000_0000_0100"; -- 0x0004
    -- Writes to registers
    constant enable_c           : std_logic_vector(data_width_g-1 downto 0) := B"00000000_00000000_00000000_00000001"; -- Enable IRQ gen
    -- Generate IRQs register irq_gen_genirq_r: [IRQ amnt, IRQ rate, reserved, IRQ line] [31:20, 19:6, 5:4, 3:0] (12, 14, 2, 4 bits)
    constant gen_irqs_c         : std_logic_vector(data_width_g-1 downto 0) := B"000111110100_00010111011100_00_0001"; -- 500 IRQs to line 1 with IRQ rate 1500
    constant irq_serve_delay_c  : integer := 86; -- IRQs are served after 86 clock edges
    
    -- State machine state definitions
    type state_type is (IRQ_ENABLE, IRQ_GENERATE, IRQ_SERVE, IRQ_WAIT, IDLE);
    signal curr_state : state_type := IRQ_ENABLE;
    signal last_state : state_type;
    
    -- Clock and reset signals   
    signal ACLK                 : std_logic := '0';     -- 100MHz axi clock for the dsp_stage
    signal rst                  : std_logic := '1';     -- Active low reset
    
    -- Test bench signals
    signal irq_line_s           : integer := 0;
    signal handle_irq_s         : std_logic_vector(31 downto 0) := (others => '0');
    signal delay_counter_r      : integer := 0;
    signal write_address_s      : std_logic_vector(addr_width_g-1 downto 0);
    signal write_data_s         : std_logic_vector(data_width_g-1 downto 0);
    signal write_start_s        : std_logic;
    signal write_done_s         : std_logic;
    signal irqgen_introut_s     : std_logic_vector(number_of_irqs_g-1 downto 0) := (others => '0');
    -- AXI4-Lite master channel signals
    signal m_axi_awaddr_s       : std_logic_vector(addr_width_g-1 downto 0) := (others => '0');
    signal m_axi_awvalid_s      : std_logic := '0';
    signal m_axi_awready_s      : std_logic := '0';
    signal m_axi_wdata_s        : std_logic_vector(data_width_g-1 downto 0) := (others => '0');
    signal m_axi_wvalid_s       : std_logic := '0';
    signal m_axi_wready_s       : std_logic := '0';
    signal m_axi_bresp_s        : std_logic_vector(1 downto 0) := (others => '0');
    signal m_axi_bvalid_s       : std_logic := '0';
    signal m_axi_bready_s       : std_logic := '0'; 
begin

    -- Scheduled tasks
    rst <= '0' after 50ns;
    
	-- Process to generate 100MHz clock
    process(ACLK)
    begin
        ACLK <= not ACLK after period_10ns_c/2;
    end process;
    
    -- Keep track on witch line IRQ was generated on
    irq_line_s <= to_integer(unsigned(gen_irqs_c(3 downto 0)));
    -- Handle IRQ
    handle_irq_s(1 downto 1) <= "1";
    -- On line 0-15
    handle_irq_s(5 downto 2) <= gen_irqs_c(3 downto 0);
     
    -- State machine controlling the AXI master writing data to the DUV
    process(ACLK)
    begin
        if(rst = '1') then
            curr_state <= IRQ_ENABLE;
            write_start_s <= '0';
            delay_counter_r <= 0;
        elsif(rising_edge(ACLK)) then                
            case curr_state is
            when IRQ_ENABLE =>
                write_address_s <= ctrl_reg_addr_c;
                write_data_s <= enable_c;
                write_start_s <= '1';
                curr_state <= IDLE;
                last_state <= IRQ_ENABLE;
                           
            when IRQ_GENERATE =>
                write_address_s <= genirq_reg_addr_c;
                write_data_s <= gen_irqs_c;
                write_start_s <= '1';
                curr_state <= IDLE;
                last_state <= IRQ_GENERATE;
                
            when IRQ_SERVE =>
                -- Handle an IRQ after delay, then move to IDLE
                if((delay_counter_r = irq_serve_delay_c)) then
                    write_address_s <= ctrl_reg_addr_c;
                    write_data_s <= (handle_irq_s or enable_c);
                    write_start_s <= '1';
                    curr_state <= IDLE;
                    last_state <= IRQ_SERVE;
                    delay_counter_r <= 0;
                else
                    curr_state <= IRQ_SERVE;
                    delay_counter_r <= delay_counter_r + 1;
                end if;           
            
            when IRQ_WAIT =>
                -- IRQ DETECTED!
                if(irqgen_introut_s(irq_line_s) = '1') then
                    curr_state <= IRQ_SERVE;
                    last_state <= IRQ_WAIT;
                end if;
            
            when IDLE =>
                write_start_s <= '0';
                -- Go to next state when AXI master is done
                if(write_done_s = '1') then
                    if(last_state = IRQ_ENABLE) then
                        curr_state <= IRQ_GENERATE;
                    elsif(last_state = IRQ_GENERATE) then
                        curr_state <= IRQ_WAIT;
                    elsif(last_state = IRQ_SERVE) then
                        -- IRQ successfully served!
                        if(irqgen_introut_s(irq_line_s) = '0') then
                            -- Wait for the next one
                            curr_state <= IRQ_WAIT;
                        end if;
                    end if;
                else
                    curr_state <= IDLE;
                end if;
            end case;
        end if;
    end process;
    
    ----------------------------------------------------- Testbench entities -----------------------------------------------------
    AXI_MASTER_WRITER : axi_master
        generic map(
            addr_width_g => addr_width_g,
            data_width_g => data_width_g
        )
        port map(
            -- Common
            ACLK => ACLK,
            rst => rst,
            -- Input
            write_address => write_address_s,
            write_data => write_data_s,
            write_start => write_start_s,
            write_done => write_done_s,
            -- AXI4-Lite master channel signals
            m_axi_awaddr => m_axi_awaddr_s,
            m_axi_awvalid => m_axi_awvalid_s,
            m_axi_awready => m_axi_awready_s,
            m_axi_wdata => m_axi_wdata_s,
            m_axi_wvalid => m_axi_wvalid_s,
            m_axi_wready => m_axi_wready_s,
            m_axi_bresp => m_axi_bresp_s,
            m_axi_bvalid => m_axi_bvalid_s,
            m_axi_bready => m_axi_bready_s
        );
    
    ----------------------------------------------------- DUV instantiations -----------------------------------------------------        
    IRQ_GENERATOR_IRQGEN_TEST : irq_generator
        generic map(
            C_S_AXI_DATA_WIDTH => data_width_g,
            C_S_AXI_ADDR_WIDTH => addr_width_g,
            C_AMOUNT_OF_IRQLINES => number_of_irqs_g  
        )
        port map(
            ACLK => ACLK,
            ARESETN => (not rst),
            irqgen_introut => irqgen_introut_s,
            -- Write address channel
            S_AXI_AWADDR => m_axi_awaddr_s,
            S_AXI_AWPROT => "000",
            S_AXI_AWVALID => m_axi_awvalid_s,
            S_AXI_AWREADY => m_axi_awready_s,
            -- Write data channel
            S_AXI_WDATA => m_axi_wdata_s,
            S_AXI_WSTRB => "0000",
            S_AXI_WVALID => m_axi_wvalid_s,
            S_AXI_WREADY => m_axi_wready_s,
            -- Write response channel
            S_AXI_BRESP => m_axi_bresp_s,
            S_AXI_BVALID => m_axi_bvalid_s,
            S_AXI_BREADY => m_axi_bready_s,
            -- Read address channel
            S_AXI_ARADDR => "0000000000000000",
            S_AXI_ARPROT => "000",
            S_AXI_ARVALID => '0',
            S_AXI_ARREADY => open,
            -- Read data channnel
            S_AXI_RDATA => open,
            S_AXI_RRESP => open,
            S_AXI_RVALID => open,
            S_AXI_RREADY => '0'
        );
            
end testbench;