#!/usr/bin/env python3
import sys
class Hi ():
    def hello(self):
        print("hello")
        
    def length(self, lst: List[str]) -> int:
        return int(len(lst))
        
        
def fib(i: int) -> int:
    if i == 0 or i == 1:
        return 1
    return fib(i - 1) + fib(i - 2)

# Demonstrate overflow handling
def add(i: int, j: int) -> int:
    return i + j

if __name__ == "__main__":
    print(fib(13))
    print(add(1,12))
    h = Hi()
    h.hello()
    v = ["Hello", "World","Dummy"]
    print(h.length(v))
