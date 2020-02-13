# symfiles

Repository for occasionally-updated `.sym` files from the [pret](https://github.com/pret) GB/GBC game disassemblies.

To use the `.sym` files, place them in the directory with the corresponding ROM, rename them to match the base name of the ROM *(i.e. text before the file extension is the same)*, then load the ROM in [BGB](http://bgb.bircd.org/) and open the debugger to have convenient access to all the symbols from the pret disassemblies.

*(NOTE: You can also do `File > Reload SYM file` directly from the BGB debugger, in the event you create/update a `.sym` file while the corresponding ROM was already open in BGB.)*

The repository also contains a ruby script for generating the output found in the following pastes:
* [Red/Blue](https://pastebin.com/97PCQTR6)
* [Yellow](https://pastebin.com/Zhk6vxiM)
* [Gold/Silver](https://pastebin.com/d2i32BUN)
* [Crystal](https://pastebin.com/54peVZKy)