# symfiles

Repository for occasionally-updated `.sym` files from the [pret](https://github.com/pret) GB/GBC game disassemblies.

To use the `.sym` files, place them in the directory with the corresponding ROM, rename them to match the base name of the ROM *(i.e. text before the file extension is the same)*, then load the ROM in [BGB](http://bgb.bircd.org/) and open the debugger to have convenient access to all the symbols from the pret disassemblies.

*(NOTE: You can also do `File > Reload SYM file` directly from the BGB debugger, in the event you create/update a `.sym` file while the corresponding ROM was already open in BGB.)*

The repository also contains a ruby script for generating wram to `.sav` address mappings (for RBY/GSC) in the `savwram` folder. The output text files can be seen here:
* [Red/Blue](/savwram/out/pokered.txt)
* [Yellow](/savwram/out/pokeyellow.txt)
* [Gold/Silver](/savwram/out/pokegold.txt)
* [Crystal](/savwram/out/pokecrystal.txt)