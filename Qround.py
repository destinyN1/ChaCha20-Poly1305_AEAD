

def add(x,y):
    
    result = (x + y) & 0xFFFFFFFF   
    return f"{result:08X}"  # Returns just the hex digits, uppercase, 8 digits



def xor(x,y):
  
    result =  (x ^ y) & 0xFFFFFFFF
    return f"{result:08X}"

#16 bit roll
def roll16(x):

    return f"0x{((x << 16) | (x >> 16)) & 0xFFFFFFFF:08X}"


#12 bit roll
def roll12(x):
    
    return f"0x{((x << 12) | (x >> 12)) & 0xFFFFFFFF:08X}"


#8 bit roll
def roll8(x):
    
    return f"0x{((x << 8) | (x >> 24)) & 0xFFFFFFFF:08X}"

#7 bit roll
def roll7(x):
    
    return f"0x{((x << 7) | (x >> 25)) & 0xFFFFFFFF:08X}"



a = 0x00000AAA
b = 0x00000BBB

print(add(a,b))
print("\n")
print(xor(a,b))
print("\n")
print(roll16(a))
print("\n")
print(roll12(a))
print("\n")
print(roll8(a))
print("\n")
print(roll7(a))






#Qurater round ops for single qround
def Qround(state,a,b,c,d):

#matrix element selection logic


    #need to add logic here to convert matrix element selection to actual values
    #e.g Qround(state,0,4,8,12)

    a = add(a,b)
    d = xor(d,a)
    d = roll16(d)

    c = add(c,d)
    b = xor(b,c)
    b = roll12(b)

    a = add(a,b)
    d = xor(d,a)
    d = roll8(d)

    c = add(c,d)
    b = xor(b,c)
    b = roll7(b)

    return state


#performs 4 column and 4 diagonal rounds (2 rounds total)
def inner_block(state):

  Qround()  
    