# High-Performance ChaCha20-Poly1305 AEAD Hardware Implementation

A SystemVerilog-based hardware implementation of the ChaCha20 stream cipher targeting maximum performance with minimal area, power consumption, and heat generation. This project focuses on creating a modular, synthesis-ready design optimized for FPGA deployment and parallel processing.

## Project Status: 🚧 In Development

**Current Phase**: Core ChaCha20 Implementation  
**Target**: Complete ChaCha20-Poly1305 AEAD (Authenticated Encryption with Associated Data) scheme

## Overview

ChaCha20 is a modern stream cipher designed by Daniel J. Bernstein, offering strong security, high performance, and simple design. When paired with Poly1305 for message authentication, it forms the ChaCha20-Poly1305 AEAD scheme widely used in internet protocols like TLS and SSH.

### Design Goals

- **Maximum Performance**: Optimized for high-throughput encryption
- **Minimal Resource Usage**: Efficient area, power, and heat generation
- **Parallelization Ready**: Architecture designed for parallel processing
- **FPGA Deployment**: Synthesis-ready SystemVerilog implementation
- **Modular Design**: Clean, maintainable, and extensible architecture

## Current Implementation Status

### ✅ Completed Components

#### 1. ChaCha State Matrix Generator (`ChaChaState`)
- **Functionality**: Initial state setup with 256-bit key, 96-bit nonce, and block counter
- **Implementation**: Matrix formation following RFC 8439 specifications
- **Features**:
  - 4×4 matrix initialization with ChaCha20 constants
  - Key mapping algorithm for systematic 256-bit key placement
  - Block counter integration for multi-block encryption
  - Synchronous reset capability

#### 2. Quarter-Round Processor (`PerformQround`)
- **Functionality**: Core ChaCha20 quarter-round operations
- **Implementation**: State machine-driven ARX (Add-Rotate-XOR) operations
- **Features**:
  - 8-state FSM for quarter-round execution (S0-S7)
  - 8 quarter-round types (Q0-Q7) for column and diagonal operations
  - 20-round ChaCha20 processing
  - Optimized clocking for maximum throughput

#### 3. Block Counter Module (`Block_Counter`)
- **Functionality**: Parameterized counter for multi-block encryption
- **Implementation**: Configurable bit-width counter with initialization
- **Features**:
  - Parameterized design for flexibility
  - Synchronous initialization
  - Interface compatibility with block function

#### 4. Block Function Integration (`Block_Function`)
- **Functionality**: Top-level integration of core components
- **Status**: Framework established for complete integration

### 🔧 Current Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Block_Counter │────│   ChaChaState    │────│ PerformQround   │
│                 │    │                  │    │                 │
│ - Counter Logic │    │ - Matrix Setup   │    │ - Quarter Round │
│ - Parameterized │    │ - Key Mapping    │    │ - 8-State FSM   │
│ - Init Control  │    │ - Nonce/Counter  │    │ - ARX Operations│
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## Technical Specifications

### ChaCha20 Implementation Details

#### State Matrix Layout
```
Row [0] [1] [2] [3]
0   C0  C1  C2  C3   (Constants: "expand 32-byte k")
1   K0  K1  K2  K3   (256-bit Key: Words 0-3)
2   K4  K5  K6  K7   (256-bit Key: Words 4-7)
3   BC  N0  N1  N2   (Block Counter + 96-bit Nonce)
```

#### Quarter-Round State Machine
| State | Operation | Description |
|-------|-----------|-------------|
| S0 | `a = a + b; d = d ⊕ (a + b)` | Addition and XOR |
| S1 | `c = c + d; d = d ≪ 16` | Addition and 16-bit rotation |
| S2 | `b = b ⊕ c; d = d ⊕ a` | XOR operations |
| S3 | `b = b ≪ 12; d = d ≪ 16` | 12 and 16-bit rotations |
| S4 | `a = a + b; d = d ≪ 8` | Addition and 8-bit rotation |
| S5 | `c = c + d; d = d ≪ 7` | Addition and 7-bit rotation |
| S6 | `b = b ⊕ c` | Final XOR |
| S7 | Advance to next quarter-round | State transition |

#### Quarter-Round Sequence
- **Q0-Q3**: Column operations (0,1,2,3)
- **Q4-Q7**: Diagonal operations for diffusion
- **20 Rounds**: Complete ChaCha20 encryption (10 double-rounds)

### Performance Characteristics

- **Throughput**: Designed for single-cycle quarter-round operations
- **Latency**: Minimal pipeline depth for low-latency encryption
- **Resource Usage**: Optimized for FPGA LUT and register efficiency
- **Power**: Low-power design with clock gating capabilities

## File Structure

```
ChaCha20-Poly1305_AEAD/
├── src/
│   ├── ChaChaState.sv           # State matrix generator
│   ├── PerformQround.sv         # Quarter-round processor
│   ├── Block_Counter.sv         # Block counter module
│   └── Block_Function.sv        # Top-level integration
├── docs/
│   ├── Project_Update_May2025.pdf    # Development progress
│   ├── Signal_Dictionary.pdf         # Complete signal reference
│   └── Architecture_Overview.md      # Design documentation
├── testbenches/
│   └── (To be implemented)
├── constraints/
│   └── (FPGA-specific constraints)
└── README.md
```

## Development Roadmap

### Phase 1: Core ChaCha20 (Current)
- [x] State matrix initialization
- [x] Quarter-round operations
- [x] Block counter functionality
- [ ] Complete integration testing
- [ ] Testbench development
- [ ] Functional verification

### Phase 2: Optimization & Verification
- [ ] Performance optimization for parallelization
- [ ] Power and area optimization
- [ ] Comprehensive testbench suite
- [ ] FPGA synthesis and timing analysis
- [ ] Security analysis and side-channel resistance

### Phase 3: Poly1305 Integration
- [ ] Poly1305 authenticator implementation
- [ ] AEAD scheme integration
- [ ] Complete ChaCha20-Poly1305 system
- [ ] Performance benchmarking

### Phase 4: Advanced Features
- [ ] Parallel processing implementation
- [ ] Multi-stream capability
- [ ] Hardware acceleration interfaces
- [ ] Power management features

## Usage

### Prerequisites
- **SystemVerilog-compatible simulator** (ModelSim, VCS, Xcelium)
- **FPGA synthesis tools** (Vivado, Quartus Prime)
- **Basic knowledge** of cryptographic principles and HDL design

### Simulation
```bash
# Example using ModelSim (when testbenches are available)
vlog -sv src/*.sv
vsim -do "run -all" testbench_top
```

### Synthesis
```bash
# Example using Vivado
vivado -mode batch -source synthesis_script.tcl
```

## Signal Interface

### ChaChaState Module
| Signal | Width | Direction | Description |
|--------|-------|-----------|-------------|
| `clk` | 1 | Input | System clock |
| `clrMatrix` | 1 | Input | Matrix reset signal |
| `Key[0:7]` | 32×8 | Input | 256-bit encryption key |
| `Nonce[2:0]` | 32×3 | Input | 96-bit nonce |
| `Block` | 32 | Input | Block counter |
| `Constant[3:0]` | 32×4 | Input | ChaCha20 constants |
| `chachatoQround` | 32×16 | Output | State matrix to quarter-round |

### PerformQround Module
| Signal | Width | Direction | Description |
|--------|-------|-----------|-------------|
| `chachamatrixIN` | 32×16 | Input | Input state matrix |
| `clk` | 1 | Input | System clock |
| `setRounds` | 1 | Input | Initialize quarter-rounds |
| `chachamatrixOUT` | 32×16 | Output | Processed state matrix |

## Standards Compliance

- **RFC 8439**: ChaCha20 and Poly1305 for IETF Protocols
- **IEEE Standards**: SystemVerilog design practices
- **NIST Guidelines**: Cryptographic implementation standards

## Security Considerations

- **Side-Channel Resistance**: Design considerations for timing attack mitigation
- **Key Handling**: Secure key input and storage mechanisms
- **Random Number Generation**: Integration points for secure randomness
- **Constant-Time Operations**: Implementation of timing-invariant operations

## Contributing

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/optimization`)
3. **Implement** changes with comprehensive testing
4. **Document** modifications and performance impacts
5. **Submit** pull request with detailed description

### Development Guidelines
- Follow SystemVerilog coding standards
- Include comprehensive comments
- Maintain modular design principles
- Provide testbenches for new features
- Document performance and resource impacts

## Performance Targets

| Metric | Target | Current Status |
|--------|--------|----------------|
| **Throughput** | >1 Gbps | In Development |
| **Latency** | <10 cycles | In Development |
| **Area** | <5K LUTs | In Development |
| **Power** | <100mW @ 100MHz | In Development |
| **Frequency** | >200 MHz | In Development |

## Testing Strategy

### Verification Approach
- **Unit Testing**: Individual module verification
- **Integration Testing**: Complete datapath validation
- **Performance Testing**: Throughput and latency measurement
- **Security Testing**: Side-channel and fault injection analysis
- **Standards Compliance**: RFC 8439 test vector validation

## License

This project is open source and available under the [MIT License](LICENSE).

## References

- [RFC 8439: ChaCha20 and Poly1305 for IETF Protocols](https://tools.ietf.org/html/rfc8439)
- [ChaCha20 Original Paper by D.J. Bernstein](https://cr.yp.to/chacha.html)
- [SystemVerilog IEEE Standard 1800-2017](https://standards.ieee.org/standard/1800-2017.html)

## Contact

**Author**: Destiny Newman  
**GitHub**: [@DestinyN1](https://github.com/DestinyN1)  
**Project Repository**: [ChaCha20-Poly1305_AEAD](https://github.com/destinyN1/ChaCha20-Poly1305_AEAD)

---

*This project is part of ongoing research in high-performance cryptographic hardware implementations. Contributions and feedback are welcome as we work toward a complete, production-ready ChaCha20-Poly1305 AEAD system.*
