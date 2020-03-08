usage_str = "Usage: ruby savwram.rb poke[red|blue|yellow|gold|silver|crystal]"
abort usage_str unless ARGV.size == 1

sym_name = ARGV[0]
repo = case sym_name
  when "pokeblue" then "pokered"
  when "pokesilver" then "pokegold"
  else sym_name
end

valid_repos = ["pokered", "pokeyellow", "pokegold", "pokecrystal"]
abort usage_str unless valid_repos.include? repo

class SavWram
  def initialize(repo)
    @repo = repo
    load_sym(File.join(__dir__, "..", repo + ".sym"))
  end

  def sav_addr(bank, addr)
    bank * 0x2000 + (addr - 0xA000)
  end

  def load_sym(path)
    @sram = {}
    @wram = {}

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
    # hardcode some stuff for the main logic to work
    case @repo
    when "pokered", "pokeyellow"
      w_start_prefix = "Start"
      s_sections = ["PlayerName", "MainData", "SpriteData", "PartyData", "BoxData", "TilesetType"]
      rby_ws_hardcodes()
    when "pokegold", "pokecrystal"
      w_start_prefix = ""
      s_sections = ["Options", "GameData", "CrystalData"]
      gsc_ws_hardcodes()
    else
      raise ArgumentError.new(format("Invalid repo (%s). Expected one of poke[red|yellow|gold|crystal].", @repo))
    end

    # common code to write the "wram/sav address" mappings for rby+gsc
    s_sections.each do |section|
      w_start_label = "w" + section + w_start_prefix
      next unless @wram[w_start_label]

      w_end_label = "w" + section + "End"
      s_base = @sram["s" + section]

      (@wram[w_start_label]...@wram[w_end_label]).each do |w_addr|
        w_label = get_label(w_addr)
        s_addr = s_base + w_addr - @wram[w_start_label]
        print(format("\n%s = %04X (%04X)", w_label, w_addr, s_addr))
      end
    end
  end

  def rby_ws_hardcodes()
    # wram/sram hardcodes
    @wram["wPlayerNameStart"] = @wram["wPlayerName"]
    @wram["wPlayerNameEnd"] = @wram["wPlayerNameStart"] + 11
    @wram["wTilesetTypeStart"] = @wram["wSavedTilesetType"]
    @wram["wTilesetTypeEnd"] = @wram["wTilesetTypeStart"] + 1
    @sram["sBoxData"] = @sram["sCurBoxData"]
  end

  def gsc_ws_hardcodes()
    # wram/sram hardcodes
    @sram["sOptions"] = sav_addr(0x01, 0xA000)
    @sram["sGameData"] = sav_addr(0x01, 0xA009)
  end

  def get_label(addr)
    # get the lowest-level label for the address
    floor = addr.downto(0) { |n| break n if @wram.has_key?(n) }
    "#{format("%04X", addr - floor)}+#{@wram[floor]}"
  end
end

out_name = repo + ".txt"
puts "Outputting to " + out_name

File.open(File.join(__dir__, out_name), "w") do |out_file|
  $stdout = out_file
  puts "wram label = wram addr (sav addr)\n"
  SavWram.new(repo).make()
end
