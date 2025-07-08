import random
import gc
import re
import numpy as np

# ============================================================================
# BIT OPERATIONS
# ============================================================================

def add(x, y):
    """32-bit addition with overflow wrap"""
    return (x + y) & 0xFFFFFFFF

def xor(x, y):
    """32-bit XOR operation"""
    return (x ^ y) & 0xFFFFFFFF

def roll16(x):
    """32-bit left rotate by 16 positions"""
    return ((x << 16) | (x >> 16)) & 0xFFFFFFFF

def roll12(x):
    """32-bit left rotate by 12 positions"""
    return ((x << 12) | (x >> 20)) & 0xFFFFFFFF

def roll8(x):
    """32-bit left rotate by 8 positions"""
    return ((x << 8) | (x >> 24)) & 0xFFFFFFFF

def roll7(x):
    """32-bit left rotate by 7 positions"""
    return ((x << 7) | (x >> 25)) & 0xFFFFFFFF

# ============================================================================
# QROUND AND INNER BLOCK OPERATIONS
# ============================================================================

def Qround(state, w, x, y, z):
    """Quarter round operation for ChaCha20"""
    # State element selection logic
    a = state[w // 4][w % 4]  # wth element
    b = state[x // 4][x % 4]  # xth element  
    c = state[y // 4][y % 4]  # yth element
    d = state[z // 4][z % 4]  # zth element

    # Quarter round operations
    a = add(a, b)
    d = xor(d, a)
    d = roll16(d)

    c = add(c, d)
    b = xor(b, c)
    b = roll12(b)

    a = add(a, b)
    d = xor(d, a)
    d = roll8(d)

    c = add(c, d)
    b = xor(b, c)
    b = roll7(b)

    # Put results back into state
    state[w // 4][w % 4] = a
    state[x // 4][x % 4] = b
    state[y // 4][y % 4] = c
    state[z // 4][z % 4] = d

    return state

def inner_block(state):
    """Performs 4 column and 4 diagonal rounds (2 rounds total)"""
    # Column rounds
    Qround(state, 0, 4, 8, 12)
    Qround(state, 1, 5, 9, 13) 
    Qround(state, 2, 6, 10, 14) 
    Qround(state, 3, 7, 11, 15)
    
    # Diagonal rounds
    Qround(state, 0, 5, 10, 15) 
    Qround(state, 1, 6, 11, 12) 
    Qround(state, 2, 7, 8, 13) 
    Qround(state, 3, 4, 9, 14) 

    return state

def twentyrounds(state):
    """Performs 20 rounds (10 inner blocks) of ChaCha20"""
    for i in range(10): 
        inner_block(state)

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

def create_random_state(state):
    """Creates a 4x4 state filled with random 32-bit hex values"""
    for i in range(4):
        row = []
        for j in range(4):
            random_value = random.randint(0, 0xFFFFFFFF)
            row.append(random_value)
        state.append(row)
    return state

def print_state(state, label="State"):
    """Prints a 4x4 state in compact format"""
    print(f"{label}:")
    for row in state:
        formatted_row = []
        for val in row:
            if isinstance(val, str) and val.startswith('0x'):
                formatted_row.append(val)
            else:
                formatted_row.append(f"0x{val:08X}")
        print(" ".join(formatted_row))

def copy_state(state):
    """Creates a deep copy of the state matrix"""
    return [row.copy() for row in state]

def fill_state_with_test_vector(state):
    """Fills the state with the ChaCha20 test vector values"""
    state.clear()
    test_values = [
        [0x61707865, 0x3320646e, 0x79622d32, 0x6b206574],
        [0x03020100, 0x07060504, 0x0b0a0908, 0x0f0e0d0c],
        [0x13121110, 0x17161514, 0x1b1a1918, 0x1f1e1d1c],
        [0x00000001, 0x09000000, 0x4a000000, 0x00000000]
    ]
    
    for row in test_values:
        state.append(row.copy())
    return state

def add_initial_to_final(initial_state, final_state):
    """Adds initial state to final state (ChaCha20 final step)"""
    added_state = []
    for i in range(4):
        row = []
        for j in range(4):
            sum_value = add(final_state[i][j], initial_state[i][j])
            row.append(sum_value)
        added_state.append(row)
    return added_state

# ============================================================================
# FILE READING AND TEST PARSING FUNCTIONS
# ============================================================================

def parse_matrix_from_text(matrix_text):
    """Parse a matrix from text format like 'Row 0: 09f9ae30 b6ba21d9 ...'"""
    matrix = []
    lines = matrix_text.strip().split('\n')
    
    for line in lines:
        if line.startswith('Row'):
            # Extract hex values from the line
            parts = line.split(': ')[1].strip().split()
            row = [int(hex_val, 16) for hex_val in parts]
            matrix.append(row)
    
    return matrix

def read_test_matrices_from_file(filename):
    """Read all test matrices from the provided file"""
    try:
        with open(filename, 'r') as file:
            content = file.read()
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")
        return None
    
    tests = []
    
    # Split content by test cases
    test_blocks = re.split(r'TEST NO\.(\d+)', content)[1:]  # Skip first empty element
    
    for i in range(0, len(test_blocks), 2):
        test_num = int(test_blocks[i])
        test_content = test_blocks[i + 1]
        
        # Extract input matrix
        input_match = re.search(r'Input Matrix:\n((?:Row \d+:.*\n?){4})', test_content)
        if not input_match:
            continue
            
        # Extract output matrix
        output_match = re.search(r'Output Matrix:\n((?:Row \d+:.*\n?){4})', test_content)
        if not output_match:
            continue
        
        input_matrix = parse_matrix_from_text(input_match.group(1))
        output_matrix = parse_matrix_from_text(output_match.group(1))
        
        tests.append({
            'test_num': test_num,
            'input': input_matrix,
            'expected_output': output_matrix
        })
    
    return tests

def compare_matrices(matrix1, matrix2, test_num):
    """Compare two 4x4 matrices and return detailed comparison results"""
    mismatches = []
    all_match = True
    
    for i in range(4):
        for j in range(4):
            if matrix1[i][j] != matrix2[i][j]:
                all_match = False
                mismatches.append({
                    'position': (i, j),
                    'expected': matrix2[i][j],
                    'actual': matrix1[i][j]
                })
    
    return {
        'test_num': test_num,
        'passed': all_match,
        'mismatches': mismatches,
        'total_mismatches': len(mismatches)
    }

def run_chacha20_on_matrix(input_matrix):
    """Run ChaCha20 20-rounds on input matrix and return result"""
    # Create a copy of the input matrix to avoid modifying original
    state = copy_state(input_matrix)
    
    # Save the initial state before running rounds
    initial_state = copy_state(state)
    
    # Perform 20 rounds of ChaCha20
    twentyrounds(state)
    
    # Add initial state to final state (ChaCha20 final step)
    final_output = add_initial_to_final(initial_state, state)
    
    # Check if final_output is already a 2D matrix or a flat list
    if isinstance(final_output[0], list):
        # It's already a 2D matrix
        matrix_4x4 = final_output
    else:
        # It's a flat list, convert to 4x4
        matrix_4x4 = []
        for i in range(0, 16, 4):
            row = final_output[i:i+4]
            matrix_4x4.append(row)
    
    # Print formatted hex output
    print("Output Matrix:")
    for i, row in enumerate(matrix_4x4):
        # Handle both integer values and potential nested lists
        hex_values = []
        for val in row:
            if isinstance(val, int):
                hex_values.append(f"{val:08x}")
            else:
                # If val is not an int, try to convert it
                hex_values.append(f"{int(val):08x}")
        print(f"Row {i}: {' '.join(hex_values)}")
    
    return matrix_4x4

def print_comparison_results(comparison_result):
    """Print detailed comparison results for a single test"""
    test_num = comparison_result['test_num']
    
    if comparison_result['passed']:
        print(f"TEST {test_num}: PASSED [OK]")
    else:
        print(f"TEST {test_num}: FAILED [X]")
        print(f"  Total mismatches: {comparison_result['total_mismatches']}/16")
        
        for mismatch in comparison_result['mismatches']:
            pos = mismatch['position']
            expected = mismatch['expected']
            actual = mismatch['actual']
            print(f"  Position [{pos[0]}][{pos[1]}]: Expected 0x{expected:08X}, Got 0x{actual:08X}")

def run_comprehensive_test_suite(filename='thousandrandtests.txt'):
    """Run comprehensive test suite on all matrices from file"""
    print("="*80)
    print("CHACHA20 COMPREHENSIVE TEST SUITE")
    print("="*80)
    
    # Read test matrices from file
    print(f"Reading test matrices from '{filename}'...")
    tests = read_test_matrices_from_file(filename)
    
    if tests is None:
        print("Failed to read test file. Exiting.")
        return
    
    print(f"Found {len(tests)} test cases.")
    print("="*80)
    
    # Track results
    passed_tests = 0
    failed_tests = 0
    all_results = []
    
    # Run tests
    for test_data in tests:
        test_num = test_data['test_num']
        input_matrix = test_data['input']
        expected_output = test_data['expected_output']
        
        # Run ChaCha20 on input matrix
        actual_output = run_chacha20_on_matrix(input_matrix)
        
        # Compare results
        comparison = compare_matrices(actual_output, expected_output, test_num)
        all_results.append(comparison)
        
        # Update counters
        if comparison['passed']:
            passed_tests += 1
        else:
            failed_tests += 1
        
        # Print results for this test
        print_comparison_results(comparison)
    
    # Print summary
    print("="*80)
    print("SUMMARY")
    print("="*80)
    print(f"Total tests: {len(tests)}")
    print(f"Passed: {passed_tests}")
    print(f"Failed: {failed_tests}")
    print(f"Pass rate: {(passed_tests/len(tests)*100):.2f}%")
    
    if failed_tests > 0:
        print("\nFAILED TESTS:")
        for result in all_results:
            if not result['passed']:
                print(f"  Test {result['test_num']}: {result['total_mismatches']} mismatches")
    
    print("="*80)
    
    return all_results

def run_single_test_detailed(test_num, filename='thousandrandtests.txt'):
    """Run a single test with detailed output"""
    tests = read_test_matrices_from_file(filename)
    if tests is None:
        return
    
    # Find the specific test
    test_data = None
    for test in tests:
        if test['test_num'] == test_num:
            test_data = test
            break
    
    if test_data is None:
        print(f"Test {test_num} not found in file.")
        return
    
    print(f"="*60)
    print(f"DETAILED TEST {test_num}")
    print(f"="*60)
    
    input_matrix = test_data['input']
    expected_output = test_data['expected_output']
    
    print("Input Matrix:")
    print_state(input_matrix)
    print()
    
    # Run ChaCha20
    actual_output = run_chacha20_on_matrix(input_matrix)
    
    print("Actual Output:")
    print_state(actual_output)
    print()
    
    print("Expected Output:")
    print_state(expected_output)
    print()
    
    # Compare
    comparison = compare_matrices(actual_output, expected_output, test_num)
    print_comparison_results(comparison)
    
    return comparison

# ============================================================================
# ORIGINAL TEST AND VALIDATION FUNCTIONS
# ============================================================================

def compare_with_expected(state, verbose=False):
    """Compares state with expected test vector result"""
    expected = [
        [0x837778ab, 0xe238d763, 0xa67ae21e, 0x5950bb2f],
        [0xc4f2d0c7, 0xfc62bb2f, 0x8fa018fc, 0x3f5ec7b7],
        [0x335271c2, 0xf29489f3, 0xeabda8fc, 0x82e46ebd],
        [0xd19c12b4, 0xb04e16de, 0x9e83d0cb, 0x4e3c50a2]
    ]
    
    all_match = True
    failed_positions = []
    
    for i in range(4):
        for j in range(4):
            if expected[i][j] != state[i][j]:
                all_match = False
                failed_positions.append((i, j))
    
    if verbose or not all_match:
        print("After 20 rounds comparison:")
        for i in range(4):
            for j in range(4):
                expected_val = expected[i][j]
                actual_val = state[i][j]
                match = expected_val == actual_val
                status = "PASS" if match else "FAIL"
                print(f"[{i}][{j}]: Expected 0x{expected_val:08X}, Got 0x{actual_val:08X} {status}")
    
    result_msg = "PASS - All values match" if all_match else f"FAIL - {len(failed_positions)} mismatches"
    print(f"20-round test: {result_msg}")
    
    return all_match

def test_vector_validation(verbose=False):
    """
    Complete ChaCha20 test vector validation function.
    Runs the full algorithm and validates against known test vectors.
    """
    print("="*50)
    print("CHACHA20 TEST VECTOR VALIDATION")
    print("="*50)
    
    # Initialize and fill with test vector
    state = []
    fill_state_with_test_vector(state)
    
    if verbose:
        print_state(state, "Initial test vector")
    
    # Save initial state and run 20 rounds
    initial_state = copy_state(state)
    twentyrounds(state)
    
    # Test after 20 rounds
    test1_result = compare_with_expected(state, verbose)
    
    # Memory cleanup
    del state, initial_state
    gc.collect()
    
    return test1_result

#will generate output matrices for repeating hex patterns
def pattern_tests():
    pattern_matrices_hex = []
    for i in range(16):
        hex_string = f"0x{i:x}{i:x}{i:x}{i:x}{i:x}{i:x}{i:x}{i:x}"
        int_value = int(hex_string,16)

        matrix = np.full((4,4),int_value)
        pattern_matrices_hex.append(matrix)
        print(f"Pattern {hex_string} \n")
        run_chacha20_on_matrix(matrix)
        print("\n")

    return pattern_matrices_hex     
    #     hex_matrices = []
    # #convert matrices to hex ints
    # for matrix in  pattern_matrices_hex:
    #     hex_matrix = [
    #         [int(f'0x{val:08x}', 16) for val in row]
    #         for row in matrix
    #     ]
    #     hex_matrices.append(hex_matrix)



# ============================================================================
# MAIN EXECUTION
# ============================================================================

if __name__ == "__main__":

    #pattern_matrices = pattern_tests()


    


    # Run the original golden model test first
    #print("Running original ChaCha20 test vector validation with standard test vectors...")
    #test_vector_validation(verbose=True)
    #print("\n")
    
    # Run comprehensive test suite on file
   # print("Running comprehensive test suite on random matrices...")
    
    # You can uncomment this line to run all tests:
    #results = run_comprehensive_test_suite('thousandrandtests.txt')
    
    # Or run a single test with detailed output:
  #  run_single_test_detailed(0, 'thousandrandtests.txt')
    
    # For demonstration, let's run the first few tests
    # print("Running first 5 tests as demonstration...")
    # tests = read_test_matrices_from_file('thousandrandtests.txt')
    # if tests:
    #     for i in range(min(5, len(tests))):
    #         test_data = tests[i]
    #         actual_output = run_chacha20_on_matrix(test_data['input'])
    #         comparison = compare_matrices(actual_output, test_data['expected_output'], test_data['test_num'])
    #         print_comparison_results(comparison)
        
    #     print(f"\nTo run all {len(tests)} tests, uncomment the line:")
    #     print("results = run_comprehensive_test_suite('thousandrandtests.txt')")
    # else:
    #     print("Could not read test file. Make sure 'thousandrandtests.txt' is in the current directory.")