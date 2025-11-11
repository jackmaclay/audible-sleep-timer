#!/usr/bin/env python3
import sys
import termios
import tty
import select
import time

def wait_for_spacebar(timeout=60):
    """Wait for spacebar press with timeout."""
    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)
    try:
        tty.setraw(fd)
        start_time = time.time()
        remaining = timeout
        
        # Print countdown timer
        sys.stdout.write(f"\rWaiting for spacebar: {remaining}s remaining ")
        sys.stdout.flush()
        
        while time.time() - start_time < timeout:
            # Update countdown every second
            new_remaining = int(timeout - (time.time() - start_time))
            if new_remaining != remaining:
                remaining = new_remaining
                sys.stdout.write(f"\rWaiting for spacebar: {remaining}s remaining ")
                sys.stdout.flush()
            
            # Check if input is available
            if select.select([sys.stdin], [], [], 0.1)[0]:
                char = sys.stdin.read(1)
                if char == ' ':  # spacebar
                    sys.stdout.write("\rSpacebar detected!                      \n")
                    return True
                    
        sys.stdout.write("\rTimeout reached.                      \n")
        return False
    finally:
        termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)

if __name__ == "__main__":
    if wait_for_spacebar():
        sys.exit(0)  # Spacebar was pressed
    else:
        sys.exit(1)  # Timeout occurred
