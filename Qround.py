import random
import gc

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
# TEST AND VALIDATION FUNCTIONS
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

def compare_with_expected_added_state(added_state, verbose=False):
    """Compares added_state with expected result after adding initial state"""
    expected_added = [
        [0xe4e7f110, 0x15593bd1, 0x1fdd0f50, 0xc47120a3],
        [0xc7f4d1c7, 0x0368c033, 0x9aaa2204, 0x4e6cd4c3],
        [0x466482d2, 0x09aa9f07, 0x05d7c214, 0xa2028bd9],
        [0xd19c12b5, 0xb94e16de, 0xe883d0cb, 0x4e3c50a2]
    ]
    
    all_match = True
    failed_positions = []
    
    for i in range(4):
        for j in range(4):
            if expected_added[i][j] != added_state[i][j]:
                all_match = False
                failed_positions.append((i, j))
    
    if verbose or not all_match:
        print("Added state comparison:")
        for i in range(4):
            for j in range(4):
                expected_val = expected_added[i][j]
                actual_val = added_state[i][j]
                match = expected_val == actual_val
                status = "[OK]" if match else "[X]"
                print(f"[{i}][{j}]: Expected 0x{expected_val:08X}, Got 0x{actual_val:08X} {status}")
    
    result_msg = "PASS - All values match" if all_match else f"FAIL - {len(failed_positions)} mismatches"
    print(f"Final test: {result_msg}")
    
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
    
    # Add initial state and test final result
    final_state = copy_state(state)
    added_state = add_initial_to_final(initial_state, final_state)
    
    if verbose:
        print_state(added_state, "Final added state")
    
    test2_result = compare_with_expected_added_state(added_state, verbose)
    
    # Final results
    overall_result = test1_result and test2_result
    print("="*50)
    
    if overall_result:
        print("*** CHACHA20 VALIDATION: SUCCESS ***")
    else:
        print("*** CHACHA20 VALIDATION: FAILED ***")
        if not test1_result:
            print("  - 20-round test failed")
        if not test2_result:
            print("  - Final state test failed")
    
    print("="*50)
    
    # Memory cleanup
    del state, initial_state, final_state, added_state
    gc.collect()
    
    return overall_result

# ============================================================================
# MAIN EXECUTION
# ============================================================================

if __name__ == "__main__":
    # Run with verbose=True to see detailed output
    test_vector_validation(verbose=True)