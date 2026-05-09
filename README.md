# Asynchronous FIFO (Verilog HDL)

## Overview

A modular and parameterized asynchronous FIFO implemented in Verilog HDL featuring:

* Dual clock domains
* Clock Domain Crossing (CDC)
* Gray-code pointer synchronization
* Full and Empty detection
* Almost Full and Almost Empty detection
* Verification testbench

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

---

# Architecture

## Datapath

Contains:

* FIFO memory
* Write pointer logic
* Read pointer logic

### Modules

* `memo`   → FIFO memory array
* `wr_ptr` → Write pointer generator
* `rd_ptr` → Read pointer generator
* `data`   → Datapath integration

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

Gray code ensures only one bit changes at a time, reducing CDC errors.

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

The testbench verifies:

* FIFO fill operation
* FIFO drain operation
* Simultaneous read/write operation
* CDC synchronization
* Full/Empty behavior
* Data integrity

Waveforms are generated using GTKWave.

---

# Simulation

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

# Key Concepts Demonstrated

* Asynchronous FIFO Design
* Clock Domain Crossing (CDC)
* Gray Code Synchronization
* Two Flip-Flop Synchronizers
* Full/Empty Detection
* Parameterized RTL Design
* Modular RTL Architecture
* Verification using Testbench

---

# Author

Ansh Shinde

