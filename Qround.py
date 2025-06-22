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
    # Convert 4x4 state indices to flat array indices and extract values
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

    # Put the results back into the state
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
            # Generate random 32-bit value (0 to 0xFFFFFFFF)
            random_value = random.randint(0, 0xFFFFFFFF)
            row.append(random_value)
        state.append(row)
    return state


def print_state(state):
    """Prints a 4x4 state in a nicely formatted way"""
    print("4x4 state:")
    for row in state:
        formatted_row = []
        for val in row:
            # Check if value is already a hex string or an integer
            if isinstance(val, str) and val.startswith('0x'):
                formatted_row.append(val)
            else:
                # Convert integer to hex string
                formatted_row.append(f"0x{val:08X}")
        print(" ".join(formatted_row))
    print()  # Add blank line after state


def copy_state(state):
    """Creates a deep copy of the state matrix"""
    return [row.copy() for row in state]


def fill_state_with_test_vector(state):
    """Fills the state with the ChaCha20 test vector values"""
    # Clear the existing state
    state.clear()
    
    # Test vector values (converted from hex strings to integers)
    test_values = [
        [0x61707865, 0x3320646e, 0x79622d32, 0x6b206574],
        [0x03020100, 0x07060504, 0x0b0a0908, 0x0f0e0d0c],
        [0x13121110, 0x17161514, 0x1b1a1918, 0x1f1e1d1c],
        [0x00000001, 0x09000000, 0x4a000000, 0x00000000]
    ]
    
    # Fill the state with test vector values
    for row in test_values:
        state.append(row.copy())  # Use copy() to avoid reference issues
    
    return state


def add_initial_to_final(initial_state, final_state):
    """Saves initial state and adds it to the final state (ChaCha20 final step)"""
    print("=== ADDING INITIAL STATE TO FINAL STATE ===")
    print("Initial state:")
    print_state(initial_state)
    
    print("Final state before addition:")
    print_state(final_state)
    
    # Create a new state matrix for the addition result
    added_state = []
    for i in range(4):
        row = []
        for j in range(4):
            # Add corresponding elements and append to new row
            sum_value = add(final_state[i][j], initial_state[i][j])
            row.append(sum_value)
        added_state.append(row)
    
    print("Added state (initial + final):")
    print_state(added_state)
    
    return added_state


# ============================================================================
# TEST AND VALIDATION FUNCTIONS
# ============================================================================

def compare_with_expected(state):
    """Compares the final state with the expected test vector result"""
    expected = [
        [0x837778ab, 0xe238d763, 0xa67ae21e, 0x5950bb2f],
        [0xc4f2d0c7, 0xfc62bb2f, 0x8fa018fc, 0x3f5ec7b7],
        [0x335271c2, 0xf29489f3, 0xeabda8fc, 0x82e46ebd],
        [0xd19c12b4, 0xb04e16de, 0x9e83d0cb, 0x4e3c50a2]
    ]
    
    print("=== TEST COMPARISON ===")
    print("Expected vs Actual:")
    
    all_match = True
    for i in range(4):
        for j in range(4):
            expected_val = expected[i][j]
            actual_val = state[i][j]
            match = expected_val == actual_val
            
            if not match:
                all_match = False
            
            # Use ASCII characters instead of Unicode symbols
            status = "PASS" if match else "FAIL"
            print(f"[{i}][{j}]: Expected 0x{expected_val:08X}, Got 0x{actual_val:08X} {status}")
    
    print("\n" + "="*50)
    if all_match:
        print("TEST PASSED! All values match the expected result.")
    else:
        print("TEST FAILED! Some values don't match.")
    print("="*50)
    
    return all_match

def compare_with_expected_added_state(added_state):
    """Compares the added_state with the expected result after adding initial state"""
    expected_added = [
        [0xe4e7f110, 0x15593bd1, 0x1fdd0f50, 0xc47120a3],
        [0xc7f4d1c7, 0x0368c033, 0x9aaa2204, 0x4e6cd4c3],
        [0x466482d2, 0x09aa9f07, 0x05d7c214, 0xa2028bd9],
        [0xd19c12b5, 0xb94e16de, 0xe883d0cb, 0x4e3c50a2]
    ]
    
    print("=== ADDED STATE TEST COMPARISON ===")
    print("Expected vs Actual (Added State):")
    
    all_match = True
    for i in range(4):
        for j in range(4):
            expected_val = expected_added[i][j]
            actual_val = added_state[i][j]
            match = expected_val == actual_val
            
            if not match:
                all_match = False
            
            status = "[OK]" if match else "[X]"
            print(f"[{i}][{j}]: Expected 0x{expected_val:08X}, Got 0x{actual_val:08X} {status}")
    
    print("\n" + "="*50)
    if all_match:
        print("ADDED STATE TEST PASSED! All values match the expected result.")
    else:
        print("ADDED STATE TEST FAILED! Some values don't match.")
    print("="*50)
    
    return all_match


def test_vector_validation():
    """
    Complete ChaCha20 test vector validation function.
    Runs the full algorithm and validates against known test vectors.
    """
    print("="*60)
    print("STARTING CHACHA20 TEST VECTOR VALIDATION")
    print("="*60)
    
    # Initialize state
    state = []
    
    # Fill with test vector
    print("Step 1: Loading test vector...")
    fill_state_with_test_vector(state)
    print("Initial test vector loaded:")
    print_state(state)
    
    # Save initial state for final addition
    initial_state = copy_state(state)
    
    # Run 20 rounds of ChaCha20
    print("Step 2: Running 20 rounds of ChaCha20...")
    twentyrounds(state)
    
    print("Step 3: Comparing state after 20 rounds (before adding initial state)...")
    compare_with_expected(state)
    
    # Save final state and add initial state
    final_state = copy_state(state)
    print("Step 4: Adding initial state to final state...")
    added_state = add_initial_to_final(initial_state, final_state)
    
    # Test the final result
    print("Step 5: Final validation of added state...")
    result = compare_with_expected_added_state(added_state)
    
    print("="*60)
    if result:
        print("*** CHACHA20 TEST VECTOR VALIDATION COMPLETED SUCCESSFULLY! ***")
    else:
        print("*** CHACHA20 TEST VECTOR VALIDATION FAILED! ***")
    print("="*60)
    
    # Clean up memory - delete all large variables
    print("Step 6: Cleaning up memory...")
    del state
    del initial_state
    del final_state
    del added_state
    
    # Force garbage collection to free memory immediately
    gc.collect()
    print("Memory cleanup completed.")
    
    return result

# ============================================================================
# MAIN EXECUTION
# ============================================================================

if __name__ == "__main__":
    test_vector_validation()