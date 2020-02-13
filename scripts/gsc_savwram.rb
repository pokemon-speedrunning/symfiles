# ruby gsc_savwram.rb poke[gold|silver|crystal]

class SavWram
  def initialize(path)
    load_sym(File.join(__dir__, "..", path + ".sym"))
  end
  
  def sav_addr(bank, addr)
    bank * 0x2000 + (addr - 0xA000)
  end

  def load_sym(path)
    @sram = {}
    @wram = {}

    @sram["sOptions"] = sav_addr(0x01, 0xA000)
    @sram["sGameData"] = sav_addr(0x01, 0xA009)
    
    File.open(path, "r") do |file|
      file.readlines.each do |line|
        line = line.split(";", 2)[0].strip
        
        next if line == ""
        
        line = line.split(" ", 2)
        info = line[0].split(":", 2)
        bank = info[0].to_i(16)
        addr = info[1].to_i(16)
        
        case addr
        when 0xA000..0xBFFF
          @sram[line[1]] = sav_addr(bank, addr)
        when 0xC000..0xDFFF
          if bank < 2
            @wram[line[1]] = addr
            @wram[addr] = line[1]
          end
        end
      end
    end
  end
  
  def make()
    ["Options", "GameData", "CrystalData"].each do |section|
      w = "w" + section
      
      next unless @wram[w]

      w_end = w + "End"
      s_base = @sram["s" + section]

      (@wram[w]...@wram[w_end]).each do |w_addr|
        w_loc = get_label(w_addr)
        s_addr = s_base + w_addr - @wram[w]
        print(format("\n%s = %04X (%04X)", w_loc, w_addr, s_addr))
      end
    end
  end
  
  def get_label(addr)
    floor = addr.downto(0) { |n| break n if @wram.has_key?(n) }
    "#{format("%04X", addr - floor)}+#{@wram[floor]}"
  end
end

symfile = ARGV[0]
File.open(File.join(__dir__, symfile + '.txt'), 'w') do |out|
  $stdout = out
  puts "wram label = wram addr (sav addr)\n"
  SavWram.new(symfile).make()
end
