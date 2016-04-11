import v
import keys

import neovim
import subprocess
import threading
import time
import os
import sys

def getNvim():
    return neovim.attach("child", argv=["/bin/env/", "nvim", "--embed"])

def welcomeMessage():
    print("Hi, welcome to V!\nUsage:\n\tv [file.v]\n\tv [file.v] [secondaryFile.txt])")

def main():
    args = sys.argv
    if len(args) < 2:
        welcomeMessage()
        return
    
    vFile = args[1]
    secondaryFile = ""
    if len(args) >= 3:
        secondaryFile = args[2]

    if not os.path.exists(vFile):
        fileNotFoundMessage(vFile)
        return

    vInstance = v.V(secondaryFile)

    with open(vFile) as source:
        for line in source:
            for char in line:
                vInstance.keyStroke(char)
            vInstance.keyStroke(keys.enter)

    for line in vInstance.getText():
        for char in line:
            print(char)

    vInstance.cleanUp()

if __name__ == "__main__":
    main()
