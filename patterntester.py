import re

def parse_output_matrices(file_content, is_hardware=False):
    """Parse output matrices from file content"""
    matrices = []
    
    # Find all output matrix sections
    matrix_sections = re.findall(r'Output Matrix:\n((?:Row \d+:.*\n?)+)', file_content, re.MULTILINE)
    
    print(f"Found {len(matrix_sections)} matrix sections in {'hardware' if is_hardware else 'software'} file")
    
    for i, section in enumerate(matrix_sections):
        matrix = []
        rows = section.strip().split('\n')
        print(f"  Matrix {i}: {len(rows)} rows")
        
        for row_idx, row in enumerate(rows):
            # Extract hex values from each row
            hex_values = re.findall(r'[0-9a-fA-F]{8}', row)
            print(f"    Row {row_idx}: {len(hex_values)} values - {hex_values}")
            matrix.append(hex_values)
        matrices.append(matrix)
        print()
    
    # Hardware file has an extra initial matrix, skip it
    if is_hardware and len(matrices) > 16:
        print(f"Skipping first matrix from hardware file (had {len(matrices)} matrices)")
        matrices = matrices[1:]  # Skip the first matrix
        print(f"Now have {len(matrices)} matrices")
    
    return matrices

def compare_matrices(sw_matrices, hw_matrices):
    """Compare software and hardware matrices"""
    print("Matrix Comparison Results:")
    print("=" * 50)
    
    print(f"Software matrices count: {len(sw_matrices)}")
    print(f"Hardware matrices count: {len(hw_matrices)}")
    print()
    
    # Ensure we have the same number of matrices
    min_count = min(len(sw_matrices), len(hw_matrices))
    
    for i in range(min_count):
        sw_matrix = sw_matrices[i]
        hw_matrix = hw_matrices[i]
        
        # Debug: print matrix dimensions
        print(f"Pattern {i:02d}:")
        print(f"  SW matrix: {len(sw_matrix)} rows")
        print(f"  HW matrix: {len(hw_matrix)} rows")
        
        if len(sw_matrix) > 0:
            print(f"  SW cols: {[len(row) for row in sw_matrix]}")
        if len(hw_matrix) > 0:
            print(f"  HW cols: {[len(row) for row in hw_matrix]}")
        
        # Check if matrices have same dimensions
        if len(sw_matrix) != len(hw_matrix):
            print(f"  Result: DIMENSION MISMATCH (rows)")
            continue
            
        all_match = True
        for row_idx in range(len(sw_matrix)):
            if len(sw_matrix[row_idx]) != len(hw_matrix[row_idx]):
                print(f"  Result: DIMENSION MISMATCH (cols in row {row_idx})")
                all_match = False
                break
            for col_idx in range(len(sw_matrix[row_idx])):
                if sw_matrix[row_idx][col_idx].lower() != hw_matrix[row_idx][col_idx].lower():
                    print(f"  Mismatch at [{row_idx}][{col_idx}]: SW={sw_matrix[row_idx][col_idx]} vs HW={hw_matrix[row_idx][col_idx]}")
                    all_match = False
                    break
            if not all_match:
                break
        
        # Print result using only ASCII characters
        if all_match:
            print(f"  Result: MATCH")
        else:
            print(f"  Result: MISMATCH")
        print()

def main():
    # Read software patterns file
    try:
        with open('softwarepatterns.txt', 'r') as f:
            sw_content = f.read()
    except FileNotFoundError:
        print("Error: softwarepatterns.txt not found")
        return
    
    # Read hardware patterns file
    try:
        with open('hwpatterns.txt', 'r') as f:
            hw_content = f.read()
    except FileNotFoundError:
        print("Error: hwpatterns.txt not found")
        return
    
    # Parse matrices from both files
    sw_matrices = parse_output_matrices(sw_content, is_hardware=False)
    hw_matrices = parse_output_matrices(hw_content, is_hardware=True)
    
    print(f"Found {len(sw_matrices)} software matrices")
    print(f"Found {len(hw_matrices)} hardware matrices")
    print()
    
    # Compare the matrices
    compare_matrices(sw_matrices, hw_matrices)

if __name__ == "__main__":
    main()