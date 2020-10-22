`timescale 1ns / 1ps

module irqgen_controller#(
        parameter integer C_AMOUNT_OF_IRQLINES = "required",
        parameter integer C_WIDTH_OF_IRQRATE = "required",
        parameter integer C_WIDTH_OF_IRQAMT = "required"
    )(
        // Global  
        input wire                              ACLK,
        input wire                              ARESETN,
        // Input
        input wire [C_WIDTH_OF_IRQRATE-1:0]     irq_rate,
        input wire [C_WIDTH_OF_IRQAMT-1:0]      irq_amt,
        input wire [4-1:0]                      irq_line,
        input wire [5-1:0]                      irq_handled,
        input wire                              start,
        // Registered output
        output reg [C_AMOUNT_OF_IRQLINES-1:0]   irq_out
    );
    
    // Input registers
    reg [C_WIDTH_OF_IRQRATE-1:0]     irq_rate_r;
    reg [C_WIDTH_OF_IRQAMT-1:0]      irq_amt_r;
    reg [4-1:0]                      irq_line_r;
    // Control registers
    reg                              running;
    reg [C_WIDTH_OF_IRQAMT-1:0]      handled_irq_count_r;
    reg [C_WIDTH_OF_IRQRATE-1:0]     irq_throttle_r;
    
    // Input registering state machine
    always @(posedge ACLK) begin
        if (~ARESETN) begin
            irq_rate_r <= 'd0;
            irq_amt_r <= 'd0;
            irq_line_r <= 'd0;
            running <= 1'b0;
        end
        else begin
            if(~running && start) begin
                irq_rate_r <= irq_rate;
                irq_amt_r <= irq_amt;
                irq_line_r <= irq_line;
                running <= 1'b1;
            end
            else if(handled_irq_count_r == irq_amt_r) begin
                running <= 1'b0;
            end
        end
    end
    
    // IRQ generation circuit
    always @(posedge ACLK) begin
        if(~ARESETN) begin
            irq_out <= 'd0;
            handled_irq_count_r <= 'd0;
            irq_throttle_r <= 'd0;
        end
        else begin
            if(running) begin
                // IRQ has been serviced
                if((irq_handled[0]) && (irq_handled[4:1] == irq_line_r)) begin
                    irq_out[irq_line_r] <= 1'b0;
                    handled_irq_count_r <= handled_irq_count_r + 'd1;
                end
                // Throttle a new IRQ after the previous one is serviced
                else if(~(irq_out[irq_line_r]) && (handled_irq_count_r < irq_amt_r)) begin
                    if(irq_throttle_r >= irq_rate_r) begin
                        irq_out[irq_line_r] <= 1'b1;
                        irq_throttle_r <= 'd0;
                    end
                    else begin
                        irq_throttle_r <= irq_throttle_r + 'd1;
                    end
                end      
            end
            else begin
                handled_irq_count_r <= 'd0;
            end
        end
    end
endmodule