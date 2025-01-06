*************************************************************************
   ____  ____ 
  /   /\/   / 
 /___/  \  /   
 \   \   \/    © Copyright 2017 Xilinx, Inc. All rights reserved.
  \   \        This file contains confidential and proprietary 
  /   /        information of Xilinx, Inc. and is protected under U.S. 
 /___/   /\    and international copyright and other intellectual 
 \   \  /  \   property laws. 
  \___\/\___\ 
 
*************************************************************************

Vendor: Xilinx 
Current readme.txt 
Version: 1.0
Date Last Modified:  03APR2017
Date Created: 13MAR2017

Associated Filename: xapp1315-lvds-source-synch-serdes-clock-multiplication.zip
Associated Document: xapp1315-lvds-source-synch-serdes-clock-multiplication.pdf 

Supported Device(s): Ultrascale FPGAs, Ultrascale+ FPGAs
   
*************************************************************************

Disclaimer: 

      This disclaimer is not a license and does not grant any rights to 
      the materials distributed herewith. Except as otherwise provided in 
      a valid license issued to you by Xilinx, and to the maximum extent 
      permitted by applicable law: (1) THESE MATERIALS ARE MADE AVAILABLE 
      "AS IS" AND WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL 
      WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, 
      INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, 
      NON-INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and 
      (2) Xilinx shall not be liable (whether in contract or tort, 
      including negligence, or under any other theory of liability) for 
      any loss or damage of any kind or nature related to, arising under 
      or in connection with these materials, including for any direct, or 
      any indirect, special, incidental, or consequential loss or damage 
      (including loss of data, profits, goodwill, or any type of loss or 
      damage suffered as a result of any action brought by a third party) 
      even if such damage or loss was reasonably foreseeable or Xilinx 
      had been advised of the possibility of the same.

Critical Applications:

      Xilinx products are not designed or intended to be fail-safe, or 
      for use in any application requiring fail-safe performance, such as 
      life-support or safety devices or systems, Class III medical 
      devices, nuclear facilities, applications related to the deployment 
      of airbags, or any other applications that could lead to death, 
      personal injury, or severe property or environmental damage 
      (individually and collectively, "Critical Applications"). Customer 
      assumes the sole risk and liability of any use of Xilinx products 
      in Critical Applications, subject only to applicable laws and 
      regulations governing limitations on product liability.

THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS 
FILE AT ALL TIMES.

*************************************************************************

This readme file contains these sections:

1. REVISION HISTORY
2. OVERVIEW
3. SOFTWARE TOOLS AND SYSTEM REQUIREMENTS
4. DESIGN FILE HIERARCHY
5. INSTALLATION AND OPERATING INSTRUCTIONS
6. OTHER INFORMATION (OPTIONAL)
7. SUPPORT


1. REVISION HISTORY 

                  Readme  
Date              Version      Revision Description
=========================================================================
13MAR2017         0.9         Early access release
14MAR2017         0.91        Corrected top_txrx_0525m.xdc file
03APR2017         1.0         Initial Xilinx release
=========================================================================



2. OVERVIEW

This readme describes how to use the files that come with XAPP1315


3. SOFTWARE TOOLS AND SYSTEM REQUIREMENTS

* Vivado 2016.4 or higher

4. DESIGN FILE HIERARCHY

The directory structure underneath this top-level folder (XAPP1315) is described 
below :

\readme.txt - this file
 |
\Verilog_src
 |   Contains the verilog design source code
 |
\Verilog_example
 |   Contains the verilog top level example and constraints for the 
 |   KCU105 with a XCKU040-FFVA1156-2-C device
 |
\Verilog_sim
 |   Contains the verilog simulation testbench
 
 
5. INSTALLATION AND OPERATING INSTRUCTIONS 

Install the Xilinx Vivado 2016.4 or later tools.

To incorporate the appropriate module into  Vivado design project:

Verilog flow:

1) For receiver designs, instantiate the receiver module rx_channel_1to7.v and set 
   the number of data lines (LINE) and the clock period (CLKIN_PERIOD) appropriately 
   for the application.  The top level design must also include an IDELAYCTRL block.
    
   An example top-level design for 2 channels of 5-bits each is provided in the .zip file

2) For transmitter designs, instantiate the transmitter module tx_channel_1to7.v and
   the clock generator module tx_clkgen_1to7.v  and set the number of data lines (LINE)
   and the clock period (CLKIN_PERIOD).
   
   An example top-level design for 2 channels of 5-bits each is provided in the .zip file

6. OTHER INFORMATION (OPTIONAL) 

1) Warnings

The following warning will be generated during implementation and can be ignored.

PLIDC-14#1 Warning IDELAYCTRL REFCLK should be same as ISERDES CLK The BITSLICE cell 
IDELAYCTRL icontrol REFCLK pin should be driven by the same clock net as the associated i
ISERDES rx_channel1/rxc_gen/iserdes_m CLK or CLKDIV pin

2) Design Notes


3) Fixes


4) Known Issues


7. SUPPORT

To obtain technical support for this reference design, go to 
www.xilinx.com/support to locate answers to known issues in the Xilinx
Answers Database or to create a WebCase.  
