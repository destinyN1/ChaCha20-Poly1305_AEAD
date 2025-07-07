matrix_a = [
    [0x837778ab, 0xe238d763, 0xa67ae21e, 0x5950bb2f],
    [0xc4f2d0c7, 0xfc62bb2f, 0x8fa018fc, 0x3f5ec7b7],
    [0x335271c2, 0xf29489f3, 0xeabda8fc, 0x82e46ebd],
    [0xd19c12b4, 0xb04e16de, 0x9e83d0cb, 0x4e3c50a2]
]

matrix_b = [
    [0x61707865, 0x3320646e, 0x79622d32, 0x6b206574],
    [0x03020100, 0x07060504, 0x0b0a0908, 0x0f0e0d0c],
    [0x13121110, 0x17161514, 0x1b1a1918, 0x1f1e1d1c],
    [0x00000001, 0x09000000, 0x4a000000, 0x00000000]
]

def add_hex_matrices(m1, m2):
    result = []
    for row1, row2 in zip(m1, m2):
        result_row = []
        for val1, val2 in zip(row1, row2):
            sum_val = (val1 + val2) & 0xFFFFFFFF  # Ensure 32-bit wrap-around
            result_row.append(sum_val)
        result.append(result_row)
    return result

def print_matrix_hex(matrix):
    for row in matrix:
        print("{" + ", ".join(f"0x{val:08X}" for val in row) + "}")

# Perform the addition
result_matrix = add_hex_matrices(matrix_a, matrix_b)

# Print the result
print("Resulting Matrix:")
print_matrix_hex(result_matrix)