import re
import sys

# Expected values from the Python ChaCha20 implementation
EXPECTED_STATES = {
    'Q0': [
        [0xABBAA25C, 0x3320646E, 0x79622D32, 0x6B206574],
        [0x3A465196, 0x07060504, 0x0B0A0908, 0x0F0E0D0C],
        [0x6B3CA454, 0x17161514, 0x1B1A1918, 0x1F1E1D1C],
        [0xDEC62ED2, 0x09000000, 0x4A000000, 0x00000000]
    ],
    'Q1': [
        [0xABBAA25C, 0x1EFA51EA, 0x79622D32, 0x6B206574],
        [0x3A465196, 0x1C7E64F6, 0x0B0A0908, 0x0F0E0D0C],
        [0x6B3CA454, 0x08EB14B1, 0x1B1A1918, 0x1F1E1D1C],
        [0xDEC62ED2, 0x8862CC77, 0x4A000000, 0x00000000]
    ],
    'Q2': [
        [0xABBAA25C, 0x1EFA51EA, 0x7354FBDF, 0x6B206574],
        [0x3A465196, 0x1C7E64F6, 0xB12FB628, 0x0F0E0D0C],
        [0x6B3CA454, 0x08EB14B1, 0xBF8A9AC9, 0x1F1E1D1C],
        [0xDEC62ED2, 0x8862CC77, 0x6E35B345, 0x00000000]
    ],
    'Q3': [
        [0xABBAA25C, 0x1EFA51EA, 0x7354FBDF, 0x83D2DC69],
        [0x3A465196, 0x1C7E64F6, 0xB12FB628, 0xF05B6976],
        [0x6B3CA454, 0x08EB14B1, 0xBF8A9AC9, 0xE444DF3B],
        [0xDEC62ED2, 0x8862CC77, 0x6E35B345, 0x52A647F1]
    ],
    'Q4': [
        [0xCD52E917, 0x1EFA51EA, 0x7354FBDF, 0x83D2DC69],
        [0x3A465196, 0x5C2E187A, 0xB12FB628, 0xF05B6976],
        [0x6B3CA454, 0x08EB14B1, 0xF1A1BDF5, 0xE444DF3B],
        [0xDEC62ED2, 0x8862CC77, 0x6E35B345, 0xF173888D]
    ],
    'Q5': [
        [0xCD52E917, 0x85AB03B4, 0x7354FBDF, 0x83D2DC69],
        [0x3A465196, 0x5C2E187A, 0xC95EB461, 0xF05B6976],
        [0x6B3CA454, 0x08EB14B1, 0xF1A1BDF5, 0x761246CA],
        [0x6B0D58A3, 0x8862CC77, 0x6E35B345, 0xF173888D]
    ],
    'Q6': [
        [0xCD52E917, 0x85AB03B4, 0xB3457395, 0x83D2DC69],
        [0x3A465196, 0x5C2E187A, 0xC95EB461, 0x316C801A],
        [0x7BF7D740, 0x08EB14B1, 0xF1A1BDF5, 0x761246CA],
        [0x6B0D58A3, 0x6798471A, 0x6E35B345, 0xF173888D]
    ],
    'Q7': [
        [0xCD52E917, 0x85AB03B4, 0xB3457395, 0xF96DE7DD],
        [0xC4B7CD22, 0x5C2E187A, 0xC95EB461, 0x316C801A],
        [0x7BF7D740, 0x7EDDD644, 0xF1A1BDF5, 0x761246CA],
        [0x6B0D58A3, 0x6798471A, 0xD737F167, 0xF173888D]
    ]
}

def parse_matrix_from_lines(lines, start_idx):
    """Parse a 4x4 matrix from lines starting at start_idx"""
    matrix = []
    for i in range(4):
        if start_idx + i < len(lines):
            line = lines[start_idx + i]
            # Look for "Row X:" pattern
            row_match = re.search(r'Row \d+:\s*([0-9a-fA-F\s]+)', line)
            if row_match:
                # Extract hex values
                hex_values = row_match.group(1).strip().split()
                row = [int(val, 16) for val in hex_values]
                matrix.append(row)
    return matrix if len(matrix) == 4 else None

def parse_hardware_output(lines):
    """Parse all matrices from hardware output with special handling"""
    hw_states = {}
    
    # Track which Q we're currently in
    current_q = None
    
    for i, line in enumerate(lines):
        # Check if we're entering a new Q state
        q_match = re.search(r'In Q(\d+)', line)
        if q_match:
            current_q = int(q_match.group(1))
            # Debug print
            # print(f"Found Q{current_q} at line {i}")
            
        # Look for matrix data - handle both "Temp Matrix:" and "Temp MatrixQ4Q7:"
        if current_q is not None and ("Temp Matrix:" in line or "Temp MatrixQ4Q7:" in line):
            # For Q6, the matrix comes AFTER the relaunch_sim messages, which is fine
            # We don't skip it - we want to capture this matrix
            
            # Look for the matrix data in the next line
            if i+1 < len(lines) and "Row 0:" in lines[i+1]:
                # Parse the matrix
                matrix = parse_matrix_from_lines(lines, i+1)
                if matrix:
                    # Debug print
                    # print(f"Found matrix for Q{current_q}")
                    
                    # Always store the first valid matrix we find for each Q
                    if f'Q{current_q}' not in hw_states:
                        hw_states[f'Q{current_q}'] = matrix
                    
                    # Special case: If this is Q7 and the matrix looks like Q3
                    if current_q == 7:
                        # Check if this matrix has the Q3 pattern
                        if (matrix[0][0] == 0xabbaa25c and     # Q3 pattern
                            matrix[0][2] == 0x7354fbdf and     # Q3 pattern
                            matrix[1][3] == 0xf05b6976):       # Correct Q3 value
                            # This is actually Q3 state shown at Q7
                            print("\n*** WARNING: Q7 output contains Q3 state values ***")
    
    return hw_states

def compare_matrices(hw_matrix, expected_matrix, q_num):
    """Compare hardware matrix with expected matrix and report differences"""
    print(f"\n{'='*60}")
    print(f"Comparing Q{q_num}")
    print(f"{'='*60}")
    
    all_match = True
    mismatches = []
    
    for i in range(4):
        for j in range(4):
            hw_val = hw_matrix[i][j]
            exp_val = expected_matrix[i][j]
            
            if hw_val != exp_val:
                all_match = False
                mismatches.append((i, j, hw_val, exp_val))
    
    if all_match:
        print(f"[PASS] Q{q_num}: All values match!")
    else:
        print(f"[FAIL] Q{q_num}: {len(mismatches)} mismatches found:")
        print("\nExpected Matrix:")
        for row in expected_matrix:
            print("  " + " ".join(f"{val:08X}" for val in row))
        print("\nHardware Matrix:")
        for row in hw_matrix:
            print("  " + " ".join(f"{val:08X}" for val in row))
        print("\nMismatches:")
        for i, j, hw_val, exp_val in mismatches:
            print(f"  [{i}][{j}]: HW=0x{hw_val:08X}, Expected=0x{exp_val:08X}")
    
    return all_match

def validate_hardware_output(filename, debug=False):
    """Main function to validate hardware output against expected values"""
    print(f"Reading hardware simulation output from: {filename}")
    print(f"{'='*60}")
    
    try:
        with open(filename, 'r') as f:
            lines = f.readlines()
    except FileNotFoundError:
        print(f"Error: Could not find file '{filename}'")
        return
    
    # Parse hardware output
    hw_states = parse_hardware_output(lines)
    
    print(f"Found {len(hw_states)} hardware states: {', '.join(sorted(hw_states.keys()))}")
    
    if debug:
        print("\nDEBUG: Matrices found:")
        for state, matrix in sorted(hw_states.items()):
            print(f"\n{state}:")
            for row in matrix:
                print("  " + " ".join(f"{val:08X}" for val in row))
    
    # Compare each state
    all_pass = True
    results = {}
    
    for q_num in range(8):
        q_key = f'Q{q_num}'
        
        if q_key in EXPECTED_STATES and q_key in hw_states:
            result = compare_matrices(hw_states[q_key], EXPECTED_STATES[q_key], q_num)
            results[q_key] = result
            all_pass = all_pass and result
        elif q_key in EXPECTED_STATES:
            print(f"\n{'='*60}")
            print(f"Q{q_num}: MISSING - No hardware output found")
            print(f"{'='*60}")
            results[q_key] = False
            all_pass = False
    
    # Check for unexpected states
    for hw_key in hw_states:
        if hw_key not in [f'Q{i}' for i in range(8)]:
            print(f"\nWARNING: Found unexpected state '{hw_key}' in hardware output")
    
    # Summary
    print(f"\n{'='*60}")
    print("VALIDATION SUMMARY")
    print(f"{'='*60}")
    
    passed = sum(1 for r in results.values() if r)
    total = len(results)
    
    for q_key, result in sorted(results.items()):
        status = "[PASS]" if result else "[FAIL]"
        print(f"{q_key}: {status}")
    
    print(f"\nPassed: {passed}/{total}")
    print(f"Overall: {'ALL TESTS PASSED' if all_pass else 'SOME TESTS FAILED'}")
    
    # Additional analysis
    if not all_pass:
        print("\nDETAILED ANALYSIS:")
        
        # Check for Q7 anomaly
        if 'Q7' in hw_states:
            q7_matrix = hw_states['Q7']
            # Check if Q7 shows Q3 values
            if (q7_matrix[0][0] == 0xabbaa25c and
                q7_matrix[0][2] == 0x7354fbdf):
                print("\n* Q7 ANOMALY DETECTED:")
                print("  - Q7 output contains Q3 state values instead of Q7 values")
                print("  - Expected Q7 to start with 0xCD52E917, but got 0xABBAA25C")
                print("  - This is clearly Q3's state being displayed at Q7 position")
                print("\n  POSSIBLE CAUSES:")
                print("  - State machine not advancing properly to Q7")
                print("  - Display/output logic showing wrong register")
                print("  - Q7 computation not being performed")
        
        # Check if only Q7 failed
        failed_states = [q for q, result in results.items() if not result]
        if failed_states == ['Q7']:
            print("\n* GOOD NEWS:")
            print("  - Q0 through Q6 are computing correctly!")
            print("  - Only Q7 has an issue (showing Q3 values)")
            print("  - The ChaCha20 algorithm is working up to Q6")
        
        # Check for timing notes
        print("\n* SIMULATION NOTES:")
        print("  - Vivado simulation was relaunched after Q6")
        print("  - This might affect state continuity")
        print("  - Consider checking state preservation across sim restart")
    
    return all_pass

def main():
    """Main entry point"""
    debug = False
    filename = None
    
    # Parse command line arguments
    args = sys.argv[1:]
    for arg in args:
        if arg == "--debug":
            debug = True
        else:
            filename = arg
    
    if not filename:
        # Default filename
        filename = "hw_simulation_output.txt"
        print(f"No filename provided, using default: {filename}")
    
    validate_hardware_output(filename, debug=debug)

def save_test_output(content, filename="hw_simulation_output.txt"):
    """Helper function to save the hardware output to a file"""
    with open(filename, 'w') as f:
        f.write(content)
    print(f"Hardware output saved to {filename}")

if __name__ == "__main__":
    # If you want to test with the provided output, uncomment the following:
    test_output = """Input Matrix:
Row 0: 61707865 3320646e 79622d32 6b206574 
Row 1: 03020100 07060504 0b0a0908 0f0e0d0c 
Row 2: 13121110 17161514 1b1a1918 1f1e1d1c 
Row 3: 00000001 09000000 4a000000 00000000 

In Q0 

TEMP MATRIX 

Temp Matrix:
Row 0: abbaa25c 3320646e 79622d32 6b206574 
Row 1: 3a465196 07060504 0b0a0908 0f0e0d0c 
Row 2: 6b3ca454 17161514 1b1a1918 1f1e1d1c 
Row 3: dec62ed2 09000000 4a000000 00000000 

In Q1 

TEMP MATRIX 

Temp Matrix:
Row 0: abbaa25c 1efa51ea 79622d32 6b206574 
Row 1: 3a465196 1c7e64f6 0b0a0908 0f0e0d0c 
Row 2: 6b3ca454 08eb14b1 1b1a1918 1f1e1d1c 
Row 3: dec62ed2 8862cc77 4a000000 00000000 

In Q2 

TEMP MATRIX 

Temp Matrix:
Row 0: abbaa25c 1efa51ea 7354fbdf 6b206574 
Row 1: 3a465196 1c7e64f6 b12fb628 0f0e0d0c 
Row 2: 6b3ca454 08eb14b1 bf8a9ac9 1f1e1d1c 
Row 3: dec62ed2 8862cc77 6e35b345 00000000 

In Q3 

Temp MatrixQ4Q7:
Row 0: abbaa25c 1efa51ea 7354fbdf 83d2dc69 
Row 1: 3a465196 1c7e64f6 b12fb628 f05b6976 
Row 2: 6b3ca454 08eb14b1 bf8a9ac9 e444df3b 
Row 3: dec62ed2 8862cc77 6e35b345 52a647f1 

In Q4 

Temp MatrixQ4Q7:
Row 0: cd52e917 1efa51ea 7354fbdf 83d2dc69 
Row 1: 3a465196 5c2e187a b12fb628 f05b6976 
Row 2: 6b3ca454 08eb14b1 f1a1bdf5 e444df3b 
Row 3: dec62ed2 8862cc77 6e35b345 f173888d 

In Q5 

Temp MatrixQ4Q7:
Row 0: cd52e917 85ab03b4 7354fbdf 83d2dc69 
Row 1: 3a465196 5c2e187a c95eb461 f05b6976 
Row 2: 6b3ca454 08eb14b1 f1a1bdf5 761246ca 
Row 3: 6b0d58a3 8862cc77 6e35b345 f173888d 

In Q6 

relaunch_sim: Time (s): cpu = 00:00:01 ; elapsed = 00:00:08 . Memory (MB): peak = 1981.078 ; gain = 0.000
run 1500 ns
Temp MatrixQ4Q7:
Row 0: cd52e917 85ab03b4 b3457395 83d2dc69 
Row 1: 3a465196 5c2e187a c95eb461 316c801a 
Row 2: 7bf7d740 08eb14b1 f1a1bdf5 761246ca 
Row 3: 6b0d58a3 6798471a 6e35b345 f173888d 

In Q7 

Temp MatrixQ4Q7:
Row 0: cd52e917 85ab03b4 b3457395 f96de7dd 
Row 1: c4b7cd22 5c2e187a c95eb461 316c801a 
Row 2: 7bf7d740 7eddd644 f1a1bdf5 761246ca 
Row 3: 6b0d58a3 6798471a d737f167 f173888d 

exited"""
    save_test_output(test_output)
    
    main()