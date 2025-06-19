# ChaCha20-Poly1305 AEAD Cryptographic Processor - RTL to GDSII ASIC Implementation

A complete SystemVerilog-based ASIC implementation of the ChaCha20-Poly1305 AEAD cryptographic system following the full RTL-to-GDSII design flow. This project targets a manufacturable silicon chip optimized for high-performance encryption with minimal area, power consumption, and heat generation.

## Project Status: 🚧 ChaCha20 RTL Design & Verification Phase

**Current Focus**: Complete ChaCha20 cipher implementation through physical design  
**Primary Goal**: Full RTL-to-GDSII experience on ChaCha20 core  
**Ultimate Target**: Manufacturable ChaCha20-Poly1305 AEAD cryptographic processor in silicon

## Project Strategy & Implementation Plan

### ChaCha20-First Approach
**Primary Development Focus**: Complete ChaCha20 cipher through physical design phase
- **Rationale**: Maximize ASIC design flow exposure on single, well-understood component
- **Learning Objective**: Gain hands-on experience with synthesis, placement, routing, and signoff
- **Scope**: RTL verification → Logic synthesis → Physical design → Signal integrity analysis
- **Benefit**: Deep understanding of complete ASIC flow before expanding system complexity

### Poly1305 Implementation Strategy
**Future Development Options**:
1. **Integrated Approach**: Implement Poly1305 within same silicon die after ChaCha20 completion
2. **Separate Silicon Strategy**: Develop Poly1305 as independent ASIC with inter-chip connectivity
   - Separate die allows independent optimization of each algorithm
   - Reduces initial complexity while maintaining system-level AEAD capability
   - Enables parallel development streams for different algorithm characteristics

### Implementation Decision Timeline
- **Phase 1-3**: Focus exclusively on ChaCha20 RTL through physical design
- **Phase 4 Decision Point**: Evaluate integration vs. separate silicon approach based on:
  - ChaCha20 implementation complexity and area requirements
  - Available resources and timeline for complete AEAD system
  - Performance requirements and inter-chip communication overhead

### Design Goals

**ChaCha20 Implementation (Current Focus):**
- **Complete ASIC Flow**: Full RTL-to-GDSII experience on single cipher component
- **Silicon Implementation**: Manufacturable ChaCha20 processor targeting advanced nodes
- **High Performance**: Multi-Gbps throughput with optimized datapath
- **Power Efficiency**: Optimized for mobile and IoT applications
- **Learning Objective**: Maximum exposure to synthesis, physical design, and signoff processes

**System-Level Goals (Future):**
- **AEAD Capability**: Complete ChaCha20-Poly1305 authenticated encryption
- **Modular Architecture**: Flexible implementation allowing separate or integrated silicon
- **Industry Standards**: Full compliance with ASIC design practices and DFT
- **Scalable Design**: Configurable for different performance/area trade-offs

## Current Implementation Status

### ✅ Completed Components

#### 1. ChaCha Core Engine
- **ChaCha State Matrix Generator (`ChaChaState`)**: Complete ✅
  - 4×4 matrix initialization with ChaCha20 constants
  - 256-bit key mapping with systematic placement
  - 96-bit nonce and 32-bit block counter integration
  - Synchronous reset and real-time input updates

- **Quarter-Round Processor (`PerformQround`)**: Complete ✅
  - State machine-driven ARX (Add-Rotate-XOR) operations
  - 8-state FSM for quarter-round execution (IDLE, S0-S7)
  - 8 quarter-round types (Q0-Q7) for column and diagonal operations
  - 20-round ChaCha20 processing with automatic counter management
  - Dual matrix storage for Q0-Q3 and Q4-Q7 operations

#### 2. System Integration & Control
- **Block Function (`Block_Function`)**: Complete ✅
  - Top-level state machine coordination
  - Reset sequencing and initialization control
  - Block production tracking and serialization enablement
  - Integrated ChaCha state and quarter-round modules

- **Block Counter (`Block_Counter`)**: Complete ✅
  - Parameterized counter with overflow detection
  - Block increment synchronization with encryption completion
  - Initialization control and state tracking

- **Complete System Integration (`ChaCha20_System`)**: Complete ✅
  - Full ChaCha20 encryption pipeline
  - Automatic block counter management
  - Serialization and concatenation integration

#### 3. Data Processing Pipeline
- **Serializer Module (`Serialiser`)**: Complete ✅
  - 32-bit word to 8-bit byte conversion
  - Little-endian byte ordering
  - Load enable control and validity signaling
  - Real-time concatenator enablement

- **Concatenator (`Concatenator`)**: Complete ✅
  - Parameterized multi-matrix storage (configurable size)
  - Synchronous buffer with overflow detection
  - Change-based input detection for efficiency
  - Full buffer signaling for downstream processing

- **Top-Level Integration (`Concat_Serialiser_TOP`)**: Complete ✅
  - Combined serialization and concatenation
  - Parameterized for multiple matrix handling
  - Synchronized operation control

#### 4. Plaintext Processing & XOR Engine
- **Plaintext Handler (`Plain_Text`)**: Complete ✅
  - Parameterized ASCII storage with configurable capacity
  - Write/read enable control for data management
  - XOR-ready signaling for encryption synchronization

- **XOR Engine (`XOR`)**: Complete ✅
  - Byte-wise XOR operation between keystream and plaintext
  - Parameterized data width and matrix handling
  - Synchronous operation with ready-based control
  - Ciphertext output generation

### 🔧 Current RTL Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   ChaCha20      │    │   Serialization  │    │   XOR Engine    │
│   Core Engine   │────│   & Buffering    │────│   & Output      │
│                 │    │                  │    │                 │
│ • State Matrix  │    │ • Serializer     │    │ • Plaintext     │
│ • Quarter Round │    │ • Concatenator   │    │ • XOR Operation │
│ • Block Counter │    │ • Buffer Mgmt    │    │ • Ciphertext    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## ASIC Design Flow Status

### Phase 1: RTL Design & Verification ✅ (Current)
- [x] **RTL Implementation**: Complete ChaCha20 core and data pipeline
- [x] **Module-Level Verification**: Individual testbenches for all components
- [x] **Integration Testing**: System-level verification in progress
- [ ] **Reference Model Validation**: Python reference comparison (planned)
- [ ] **Coverage Analysis**: Functional and code coverage assessment
- [ ] **Performance Analysis**: Throughput and latency characterization

### Phase 2: Logic Synthesis (Next)
- [ ] **Technology Mapping**: Target advanced FinFET process library
- [ ] **Timing Optimization**: Multi-corner timing closure
- [ ] **Power Optimization**: Clock gating and power islands
- [ ] **Area Optimization**: Logic optimization and gate sizing
- [ ] **DFT Insertion**: Scan chain and MBIST integration

### Phase 3: Physical Design
- [ ] **Floorplanning**: Optimal block placement and power planning
- [ ] **Clock Tree Synthesis**: Low-skew clock distribution
- [ ] **Placement & Routing**: Detailed routing with timing closure
- [ ] **Parasitic Extraction**: RC modeling for accurate timing
- [ ] **Physical Verification**: DRC, LVS, and antenna checks

### Phase 4: Signoff & Tapeout
- [ ] **Static Timing Analysis**: Multi-corner, multi-mode verification
- [ ] **Power Analysis**: Dynamic and leakage power validation
- [ ] **Signal Integrity**: Crosstalk and IR drop analysis
- [ ] **GDSII Generation**: Final layout for fabrication
- [ ] **Tapeout Package**: Complete design database for foundry

## Current Verification Status

### Comprehensive Unit Testing 
Verification progress across system components:

**✅ Completed Unit Testing:**
- **ChaChaState**: Matrix formation and input validation verified
- **Block_Counter**: Counter logic and overflow behavior validated  
- **Serialiser**: Word-to-byte conversion and control signaling verified
- **Concatenator**: Buffer management and data storage validated

**⏳ Pending Unit Testing:**
- **Plain_Text**: ASCII storage and read/write operations (testbench planned)
- **XOR Engine**: Byte-wise encryption operations (verification pending)
- **System Integration**: Top-level datapath validation (awaiting component completion)

### Quarter-Round Verification Challenges 🔄
The **PerformQround** module presents unique verification complexity:
- **Q0-Q3 Operations**: Column quarter-rounds fully verified and functional
- **Q4-Q7 Operations**: Diagonal quarter-rounds experiencing verification issues
- **Synchronization Challenge**: Timing misalignment between testbench stimulus and DUT state machine
- **Root Cause**: Complex multi-clock state transitions causing testbench/DUT desynchronization
- **Current Debug**: Clock domain analysis and stimulus timing refinement in progress

### Black-Box Verification Strategy 📋
To resolve Q4-Q7 verification challenges, implementing comprehensive validation approach:
- **Python Reference Model**: Developing external ChaCha20 quarter-round implementation
- **Golden Reference**: Bit-accurate Python model following RFC 8439 specifications  
- **Comparison Framework**: Direct output matching between RTL and reference model
- **Synchronization Solution**: External reference eliminates testbench timing dependencies
- **Timeline**: Python model development in progress for complete PerformQround verification

### Integration Testing in Progress 🔧
Parallel development of critical module integration:
- **Serializer-Concatenator Integration**: Testing coordinated operation between modules
- **Data Flow Validation**: End-to-end data path from matrix input to concatenated output
- **Control Signal Timing**: Verifying proper handshaking between serialization and buffering
- **Buffer Management**: Testing full/empty conditions and data integrity across module boundaries

### Current RTL Implementation Status
| Component | Implementation Status | Verification Status |
|-----------|---------------------|-------------------|
| **ChaCha State Matrix** | ✅ Complete | ✅ Unit tests complete |
| **Quarter-Round Processor** | ✅ Complete | 🔄 Q0-Q3 verified, Q4-Q7 debugging |
| **Block Counter** | ✅ Complete | ✅ Unit tests complete |
| **System Integration** | ✅ Complete | ⏳ Pending QRound completion |
| **Serialization Pipeline** | ✅ Complete | ✅ Unit tests complete |
| **Concatenator** | ✅ Complete | ✅ Unit tests complete |
| **XOR Engine** | ✅ Complete | ⏳ Unit testing pending |
| **Plaintext Handler** | ✅ Complete | ⏳ Unit testing pending |

### Silicon Implementation Targets (To Be Determined)
The following specifications will be established during synthesis and physical design phases:
- **Performance Targets**: To be determined post-synthesis
- **Area Estimates**: Pending technology library selection
- **Power Analysis**: Awaiting gate-level implementation
- **Timing Closure**: Multi-corner analysis required
- **Process Technology**: Advanced node selection in progress
