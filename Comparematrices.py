# Matrix 1 (braced format)
matrix1 = [
    [0xE4E7F110, 0x15593BD1, 0x1FDD0F50, 0xC47120A3],
    [0xC7F4D1C7, 0x0368C033, 0x9AAA2204, 0x4E6CD4C3],
    [0x466482D2, 0x09AA9F07, 0x05D7C214, 0xA2028BD9],
    [0xD19C12B5, 0xB94E16DE, 0xE883D0CB, 0x4E3C50A2]
]

# Matrix 2 (line-by-line format)
matrix2 = [
    [0xE4E7F110, 0x15593BD1, 0x1FDD0F50, 0xC47120A3],
    [0xC7F4D1C7, 0x0368C033, 0x9AAA2204, 0x4E6CD4C3],
    [0x466482D2, 0x09AA9F07, 0x05D7C214, 0xA2028BD9],
    [0xD19C12B5, 0xB94E16DE, 0xE883D0CB, 0x4E3C50A2]
]

# Compare function
def compare_matrices(m1, m2):
    for i in range(4):
        for j in range(4):
            if m1[i][j] != m2[i][j]:
                print(f"Mismatch at [{i}][{j}]: {hex(m1[i][j])} != {hex(m2[i][j])}")
                return False
    return True

# Run the comparison
if compare_matrices(matrix1, matrix2):
    print(" Matrices are equal.")
else:
    print(" Matrices are NOT equal.")
