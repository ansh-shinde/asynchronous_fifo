# Asynchronous FIFO (Verilog HDL)

## Overview

A modular and parameterized Asynchronous FIFO implemented in Verilog HDL featuring:

* Dual clock domains
* Clock Domain Crossing (CDC)
* Gray-code pointer synchronization
* Full and Empty detection
* Almost Full and Almost Empty detection
* RTL Verification
* Synthesis using Sky130 Standard Cell Library
* Static Timing Analysis (STA)
* Gate-Level Simulation (GLS)

---

# Features

* Parameterized FIFO depth and data width
* Independent read and write clocks
* Gray-code based CDC handling
* Two Flip-Flop synchronizers
* Binary to Gray code conversion
* Full and Empty detection logic
* Almost Full / Almost Empty generation
* Simultaneous read and write support
* Verification testbench with asynchronous clocks
* Technology mapped synthesized netlist
* Static Timing Analysis using OpenSTA
* Gate-Level Simulation using Sky130 standard cells

---

# Architecture

## Datapath

Contains:

* FIFO memory
* Write pointer logic
* Read pointer logic

### Modules

* `memo` → FIFO memory array
* `wr_ptr` → Write pointer generator
* `rd_ptr` → Read pointer generator
* `data` → Datapath integration

---

## Control Path

Handles:

* Clock Domain Crossing (CDC)
* Gray-code synchronization
* Gray-to-Binary conversion
* Full/Empty detection
* Almost Full/Almost Empty generation
* Read/Write enable generation

---

# Clock Domain Crossing (CDC)

Since read and write clocks are asynchronous, Gray-coded pointers are synchronized using Two Flip-Flop synchronizers to reduce metastability during clock domain crossing.

---

# Gray Code Synchronization

Binary pointers are converted into Gray code using:

```verilog
gray = binary ^ (binary >> 1);
```

Gray code ensures only one bit changes at a time, reducing CDC synchronization errors.

---

# Full Detection Logic

FIFO becomes FULL when the next write pointer equals the synchronized read pointer with inverted MSBs.

```verilog
full <= (gray_nxt_wr ==
        {~g_syn_rd[N:N-1], g_syn_rd[N-2:0]});
```

---

# Empty Detection Logic

FIFO becomes EMPTY when the synchronized write pointer equals the read pointer.

```verilog
empty <= (gray_adrs_rd == g_syn_wr);
```

---

# Almost Full / Almost Empty

## Almost Full

```verilog
nr_full <= ((bin_adrs_wr - bin_syn_rd) >= DEPTH-2);
```

## Almost Empty

```verilog
nr_empty <= ((bin_syn_wr - bin_adrs_rd) <= 2);
```

---

# Next Address Logic

## Write Pointer

```verilog
bin_nxt_wr  = bin_adrs_wr + (wr_en && wr);
gray_nxt_wr = bin_nxt_wr ^ (bin_nxt_wr >> 1);
```

## Read Pointer

```verilog
bin_nxt_rd  = bin_adrs_rd + (rd_en && rd);
gray_nxt_rd = bin_nxt_rd ^ (bin_nxt_rd >> 1);
```

---

# Verification Testbench

The RTL and GLS testbenches verify:

* FIFO fill operation
* FIFO drain operation
* Simultaneous read/write operation
* CDC synchronization
* Full/Empty behavior
* Data integrity
* Gate-level functional correctness

Waveforms are generated using GTKWave.

---

# RTL Simulation

## Compile

```bash
iverilog -o fifo.out *.v
```

## Run

```bash
vvp fifo.out
```

## View Waveform

```bash
gtkwave async_fifo.vcd
```

---

# Synthesis Flow

Synthesis was performed using:

* Yosys
* Sky130 HD Standard Cell Library

Technology Mapping Library:

```text
sky130_fd_sc_hd
```

---

# Synthesis Results

## Total Standard Cells

```text
333 Cells
```

## Total Chip Area

```text
4194.0224 µm²
```

## Key Cell Usage

| Cell Type      | Count |
| -------------- | ----- |
| D Flip-Flops   | 102   |
| Inverters      | 26    |
| XOR/XNOR Gates | 33    |
| Multiplexers   | 88    |
| NAND Gates     | 20    |
| NOR Gates      | 21    |

Synthesis statistics generated using Yosys and Sky130 liberty timing library.

---

# Static Timing Analysis (STA)

STA was performed using:

* OpenSTA
* Sky130 HD Liberty Timing Models

Clock Constraints:

| Clock  | Period | Frequency |
| ------ | ------ | --------- |
| clk_wr | 10 ns  | 100 MHz   |
| clk_rd | 12 ns  | 83.3 MHz  |

---

# Timing Results

## Setup Timing

Worst Setup Slack (WNS):

```text
+0.62 ns
```

## Hold Timing

Worst Hold Slack:

```text
+0.33 ns
```

All setup and hold constraints are successfully met.

---

# Maximum Operating Frequency

Estimated maximum operating frequency:

f_{max} \approx \frac{1}{9.38\text{ ns}} \approx 106.6\text{ MHz}

---

# Gate-Level Simulation (GLS)

GLS was performed using:

* Synthesized netlist
* Sky130 standard-cell Verilog models
* Icarus Verilog

The GLS environment verifies:

* Post-synthesis functionality
* Sequential behavior after technology mapping
* FIFO correctness at gate level
* CDC synchronization after synthesis
* Read/write concurrency

---

# Tools Used

| Tool           | Purpose                |
| -------------- | ---------------------- |
| Icarus Verilog | RTL & GLS Simulation   |
| GTKWave        | Waveform Viewing       |
| Yosys          | Logic Synthesis        |
| OpenSTA        | Static Timing Analysis |
| Sky130 PDK     | Standard Cell Library  |

---

# Key Concepts Demonstrated

* Asynchronous FIFO Design
* Clock Domain Crossing (CDC)
* Gray Code Synchronization
* Two Flip-Flop Synchronizers
* Full/Empty Detection
* Parameterized RTL Design
* Modular RTL Architecture
* RTL Verification
* Gate-Level Simulation
* Logic Synthesis
* Static Timing Analysis
* ASIC Frontend Flow

---

# Author

**Ansh Shinde**


