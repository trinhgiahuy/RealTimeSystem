`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Wapice Ltd
// Engineer: Jan Lipponen
// 
// Create Date: 05/14/2018 01:09:26 PM
// Design Name: IRQ Generator
// Module Name: irq_generator
// Project Name: Realtime systems
// Target Devices: PYNQ board
// Tool Versions: Generated with Vivado 2017.1
// Description: Generates level-type IRQs to the IRQ_F2P input
// 
// Dependencies: 
// 
// Revision 1.1 - Tested solution
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// IRQ Generator 32-bit control register offsets
`define IRQ_GEN_CTRL_REG                'h0000
`define IRQ_GEN_GENIRQ_REG              'h0004
`define IRQ_GEN_IRQ_COUNT_REG           'h0008
//`define 'h0010
//`define 'h0014
//`define 'h0018
//`define 'h001C
//`define 'h0020
//...
//`define 'hFFFF

module irq_generator#(
		// Width of S_AXI data bus
		// AXI4-Lite requires a fixed data bus width of either 32-bits or 64-bits.
        parameter integer C_S_AXI_DATA_WIDTH = 32,
        // Width of S_AXI address bus
        parameter integer C_S_AXI_ADDR_WIDTH = 16,
        // Number of interrupt lines
        parameter integer C_AMOUNT_OF_IRQLINES = 16
    )(
        //////////////////////////////// Global input ///////////////////////////////
        input wire                              ACLK,
        input wire                              ARESETN,
        
        ///////////////////////////// Registered output /////////////////////////////
        (* X_INTERFACE_INFO = "xilinx.com:signal:interrupt:1.0 irq INTERRUPT" *)
        output wire [C_AMOUNT_OF_IRQLINES-1:0] irqgen_introut,           
        
        ////////////////////////// AXI4 Lite slave channel //////////////////////////   
        
        /////////////// Write address channel ///////////////
		// Write address (issued by master, acceped by Slave)
        input wire [C_S_AXI_ADDR_WIDTH-1:0]     S_AXI_AWADDR,
        // Write channel Protection type. This signal indicates the
        // privilege and security level of the transaction, and whether
        // the transaction is a data access or an instruction access.
        input wire [2:0]                        S_AXI_AWPROT,
        // Write address valid. This signal indicates that the master signaling
        // valid write address and control information.
        input wire                              S_AXI_AWVALID,
        // Write address ready. This signal indicates that the slave is ready
        // to accept an address and associated control signals.
        output reg                              S_AXI_AWREADY,
        
        /////////////// Write data channel ///////////////
        // Write data (issued by master, acceped by Slave) 
        input wire [C_S_AXI_DATA_WIDTH-1:0]     S_AXI_WDATA,
        // Write strobes. This signal indicates which byte lanes hold
        // valid data. There is one write strobe bit for each eight
        // bits of the write data bus. Masters are not required to make 
        // use of the write strobe signals if they always performs full 
        // data bus width write transactions.
        input wire [(C_S_AXI_DATA_WIDTH/8)-1:0] S_AXI_WSTRB,
        // Write valid. This signal indicates that valid write
        // data and strobes are available.
        input wire                              S_AXI_WVALID,
        // Write ready. This signal indicates that the slave
        // can accept the write data.
        output reg                              S_AXI_WREADY,
        
        /////////////// Write response channel ///////////////
        // Write response. This signal indicates the status
        // of the write transaction.
        output reg [1:0]                        S_AXI_BRESP,
        // Write response valid. This signal indicates that the channel
        // is signaling a valid write response.
        output reg                              S_AXI_BVALID,
        // Response ready. This signal indicates that the master
        // can accept a write response.
        input wire                              S_AXI_BREADY,
        
        /////////////// Read address channel ///////////////
        // Read address (issued by master, acceped by Slave)
        input wire [C_S_AXI_ADDR_WIDTH-1:0]     S_AXI_ARADDR,
        // Protection type. This signal indicates the privilege
        // and security level of the transaction, and whether the
        // transaction is a data access or an instruction access.
        input wire [2:0]                        S_AXI_ARPROT,
        // Read address valid. This signal indicates that the channel
        // is signaling valid read address and control information.
        input wire                              S_AXI_ARVALID,
        // Read address ready. This signal indicates that the slave is
        // ready to accept an address and associated control signals.
        output reg                              S_AXI_ARREADY,
        
        /////////////// Read data channel ///////////////
        // Read data (issued by slave)
        output reg [C_S_AXI_DATA_WIDTH-1:0]     S_AXI_RDATA,
        // Read response. This signal indicates the status of the
        // read transfer.
        output reg [1:0]                        S_AXI_RRESP,
        // Read valid. This signal indicates that the channel is
        // signaling the required read data.
        output reg                              S_AXI_RVALID,
        // Read ready. This signal indicates that the master can
        // accept the read data and response information.
        input wire                              S_AXI_RREADY
    );

    //                      REGISTER DEFINITIONS
    // IRQ_GEN_CTRL_REG - IRQ generator control register
    // 31:16 IRQ lines [15:0] enable (not supported)
    // 15:6 Default IRQ delay (not supported)
    // 5:2 IRQ ACK
    // 1:1 IRQ handled
    // 0:0 IRQ generator enable
    reg [C_S_AXI_DATA_WIDTH-1:0]        irq_gen_ctrl_r;
    
    // IRQ_GEN_GENIRQ_REG - Generate IRQs register 
    // 31:20 IRQ amount
    // 19:6 IRQ delay
    // 5:4 Reserved
    // 3:0 IRQ line 0-15
    reg [C_S_AXI_DATA_WIDTH-1:0]        irq_gen_genirq_r;
    
    // IRQ_GEN_IRQ_COUNT_REG - IRQ counter register
    reg [C_S_AXI_DATA_WIDTH-1:0]        irq_count_r;
    
    // IRQ_GEN_IRQ_COUNT_REG  - Last served IRQ latency
    reg [C_S_AXI_DATA_WIDTH-1:0]        irq_latency_r;
    
    //                      WIRING DEFINITIONS
    wire [C_AMOUNT_OF_IRQLINES-1:0]     irq_enable_mask;
    wire [10-1:0]                       irq_default_rate;
    wire [5-1:0]                        irq_line_handled;
    wire                                irq_gen_enable;
    
    wire [12-1:0]                       genirq_amount;
    wire [14-1:0]                       genirq_rate;
    wire [4-1:0]                        genirq_line;
    
    //                      WIRING CONNECTIONS
    assign irq_enable_mask = irq_gen_ctrl_r[31:16];
    assign irq_default_rate = irq_gen_ctrl_r[15:6];
    assign irq_line_handled = irq_gen_ctrl_r[5:1];
    assign irq_gen_enable = irq_gen_ctrl_r[0];
    
    assign genirq_amount = irq_gen_genirq_r[31:20];
    assign genirq_rate = irq_gen_genirq_r[19:6];
    assign genirq_line = irq_gen_genirq_r[3:0];
    
    //                      LOCAL REGISTERS
    reg                                 start_irq_gen_r;
    reg [C_AMOUNT_OF_IRQLINES-1:0]      introut_state_r;
    reg [C_S_AXI_DATA_WIDTH-1:0]        irq_latency_counter_r;
    reg                                 irq_pending_r;
    
    // AXI4-Lite slave circuit to handle writes issued by a AXI master
    always @(posedge ACLK) begin
        if (~ARESETN) begin
            S_AXI_AWREADY <= 1'b0;
            S_AXI_WREADY <= 1'b0;
            S_AXI_BRESP <= 2'b0;
            S_AXI_BVALID <= 1'b0;
            irq_gen_ctrl_r <= 'd0;
            irq_gen_genirq_r <= 'd0;
            start_irq_gen_r <= 'd0;
        end
        else begin
            // Handle a master write to registers
            if((S_AXI_AWVALID && S_AXI_WVALID) && (~S_AXI_AWREADY && ~S_AXI_WREADY)) begin
                case(S_AXI_AWADDR)
                    `IRQ_GEN_CTRL_REG: begin
                        irq_gen_ctrl_r <= S_AXI_WDATA;
                    end
                    `IRQ_GEN_GENIRQ_REG: begin
                        // If over 0 interrupts were requested
                        if((S_AXI_WDATA[C_S_AXI_DATA_WIDTH-1:16] != 'd0) && (irq_gen_ctrl_r[0] == 'd1)) begin
                            irq_gen_genirq_r <= S_AXI_WDATA;
                            start_irq_gen_r <= 1'b1;
                        end
                    end
                endcase
                S_AXI_AWREADY <= 1'b1;
                S_AXI_WREADY <= 1'b1; 
            end
            else begin
                S_AXI_AWREADY <= 1'b0;
                S_AXI_WREADY <= 1'b0;
            end
            
            // Write a slave response
            if((S_AXI_AWVALID && S_AXI_WVALID) && (S_AXI_AWREADY && S_AXI_WREADY) && ~S_AXI_BVALID) begin
                S_AXI_BVALID <= 1'b1;
                S_AXI_BRESP <= 2'b0; // 'OKAY' response
            end
            
            // Response has been received by the master
            if(S_AXI_BREADY && S_AXI_BVALID) begin
                S_AXI_BVALID <= 1'b0;
            end
            
            // Clear the Start IRQ generation register after one clock period
            if(start_irq_gen_r) begin
                start_irq_gen_r <= 1'b0;
            end
            // Clear the IRQ handled register after one clock period
            if(irq_gen_ctrl_r[1] == 1'b1) begin
                irq_gen_ctrl_r[1] <= 1'b0;
            end
        end
    end
  
    // AXI4-Lite slave circuit to handle reads issued by a AXI master
    always @(posedge ACLK) begin
        if (~ARESETN) begin
            S_AXI_ARREADY <= 1'b1; // Always ready for read address
            S_AXI_RVALID <= 1'b0;
        end
        else begin
            // Handle a master read from the registers
            if(S_AXI_ARVALID && S_AXI_ARREADY && ~S_AXI_RVALID) begin
                case(S_AXI_ARADDR)
                    `IRQ_GEN_CTRL_REG: begin
                        S_AXI_RDATA <= irq_gen_ctrl_r;
                    end
                    `IRQ_GEN_IRQ_COUNT_REG: begin
                        S_AXI_RDATA <= irq_count_r;
                    end
                endcase
				
				S_AXI_RVALID <= 1'b1;
				S_AXI_RRESP <= 2'b0; // 'OKAY' response
            end
            
            // Response has been received by the master
            if(S_AXI_RREADY && S_AXI_RVALID) begin
                S_AXI_RVALID <= 1'b0;
            end
        end
    end
    
    // Instance of an IRQ generator controller
    irqgen_controller #(
        .C_AMOUNT_OF_IRQLINES(C_AMOUNT_OF_IRQLINES),
        .C_WIDTH_OF_IRQRATE(14),
        .C_WIDTH_OF_IRQAMT(12)
    ) irqgen_ctrl_inst(
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        .irq_rate(genirq_rate),
        .irq_amt(genirq_amount),
        .irq_line(genirq_line),
        .irq_handled(irq_line_handled),
        .start(start_irq_gen_r),
        .irq_out(irqgen_introut)
    );
    
    // IRQ counter circuit
    always @(posedge ACLK) begin
        if (~ARESETN) begin
            irq_count_r <= 'd0;
            introut_state_r <= 'd0;
            irq_pending_r <= 1'b0;
        end
        else begin
            // If an interrupt was generated to some IRQ line
            if(irqgen_introut > introut_state_r) begin
                introut_state_r <= irqgen_introut;
                irq_count_r <= irq_count_r + 'd1;
                irq_pending_r <= 1'b1;
            end
            // If an interrupt was served from some IRQ line
            else if(irqgen_introut < introut_state_r) begin
                introut_state_r <= irqgen_introut;
                irq_pending_r <= 1'b0;
            end
        end
    end
endmodule
