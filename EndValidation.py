def reverse_matrix(matrix):
    """Reverses a 4x4 matrix element-wise."""
    flat = sum(matrix, [])
    reversed_flat = flat[::-1]
    return [reversed_flat[i:i+4] for i in range(0, 16, 4)]

def compare_matrices(m1, m2, name="Comparison"):
    """Compares two 4x4 matrices element by element."""
    print(f"--- Comparing {name} ---")
    all_match = True
    for i in range(4):
        for j in range(4):
            if m1[i][j] != m2[i][j]:
                print(f" Mismatch at [{i}][{j}]: 0x{m1[i][j]:08X} != 0x{m2[i][j]:08X}")
                all_match = False
    if all_match:
        print(" Matrices are equal.\n")
    else:
        print(" Matrices are NOT equal.\n")

def add_matrices(m1, m2):
    """Adds two 4x4 matrices element-wise with 32-bit wraparound."""
    return [[(m1[i][j] + m2[i][j]) & 0xFFFFFFFF for j in range(4)] for i in range(4)]

# ----- TEMPCHACHAMATRIX -----
TEMPCHACHAMATRIX = [
    [0x4e3c50a2, 0x9e83d0cb, 0xb04e16de, 0xd19c12b4],
    [0x82e46ebd, 0xeabda8fc, 0xf29489f3, 0x335271c2],
    [0x3f5ec7b7, 0x8fa018fc, 0xfc62bb2f, 0xc4f2d0c7],
    [0x5950bb2f, 0xa67ae21e, 0xe238d763, 0x837778ab]
]

expected_matrix = [
    [0x837778AB, 0xE238D763, 0xA67AE21E, 0x5950BB2F],
    [0xC4F2D0C7, 0xFC62BB2F, 0x8FA018FC, 0x3F5EC7B7],
    [0x335271C2, 0xF29489F3, 0xEABDA8FC, 0x82E46EBD],
    [0xD19C12B4, 0xB04E16DE, 0x9E83D0CB, 0x4E3C50A2]
]

# ----- INITINIT -----
INITINIT = [
    [0x00000000, 0x4A000000, 0x09000000, 0x00000001],
    [0x1F1E1D1C, 0x1B1A1918, 0x17161514, 0x13121110],
    [0x0F0E0D0C, 0x0B0A0908, 0x07060504, 0x03020100],
    [0x6B206574, 0x79622D32, 0x3320646E, 0x61707865]
]

initial_test_vector = [
    [0x61707865, 0x3320646E, 0x79622D32, 0x6B206574],
    [0x03020100, 0x07060504, 0x0B0A0908, 0x0F0E0D0C],
    [0x13121110, 0x17161514, 0x1B1A1918, 0x1F1E1D1C],
    [0x00000001, 0x09000000, 0x4A000000, 0x00000000]
]

# Step 1: Reverse both matrices
reversed_tempchacha = reverse_matrix(TEMPCHACHAMATRIX)
reversed_init = reverse_matrix(INITINIT)

# Step 2: Add reversed matrices
combined_reversed = add_matrices(reversed_tempchacha, reversed_init)

# Step 3: Add golden reference matrices
combined_reference = add_matrices(expected_matrix, initial_test_vector)

# Step 4: Compare results
compare_matrices(combined_reversed, combined_reference, name="(TEMP + INITINIT) vs (Expected + Test Vector)")


print(combined_reference)