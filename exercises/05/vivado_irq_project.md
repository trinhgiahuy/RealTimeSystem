# Steps for creating a Vivado project for the `irqgen` IP block

This guide assumes you created the project as per instructions earlier and are now at the situation where you have added:

- board definition files
- set the correct part
- added Verilog sources for the IRQ Generator
- debugged the simulation and resulted in ~90 to delay of the system

## Steps:

- Open the above mentioned project / or create new one and follow these instructions to the end
- From Vivado, under **IP INTEGRATOR**, **Create block diagram**, then open it
- Add `ZYNQ7` Processing system IP from the `+` icon, or right-click and "Add IP". Run the block automation to the processing system.
- connect the `FCLK_CLK0` output to `GP0 ALCK` input.

*You can drag wires only from ports to ports, if you hover the mouse over a port, the shape of the mouse changes*

- configure `ZYNQ7` to enable interrupts by double clicking, then **Interrupts** tab, then enable `PL-PS interrupt IQR_F2P`
- Next add your Verilog file to the diagram by right-click and **Add module** (`irq_generator.v`)
- run the block automation again, it will automatically connect `AXI` bus as necessary.
- Add and configure a `Concat` IP block to use 1 port with width of 16 and connect the `IRQ Generator` output to the `Concat` input
- Connect the output of the `Concat` to the `IRQ_F2P` port of the processing system

*If you regenerate the diagram, you should end up with diagram like one in the irqgen data sheet at page 9.*

- Generate a HDL wrapper of the constructed design by right-clicking the block design (`.bd`) file from the **Sources** tab and selecting **Create HDL Wrapper** and **Let Vivado manage wrapper** and auto-update.
- Select the generated HDL wrapper as top level source file and select **Generate Bitstream** to generate a bitstream binary from the design.
- When the generation is completed without errors, you can choose **Cancel** from the pop-up window. The generated bitstream file is located in `<project_name.runs>\impl_1\<design_name>_wrapper.bit`
- Transfer this file to the SD card and rename it as `bitstream`: the FPGA will be programmed with it during the boot process.
