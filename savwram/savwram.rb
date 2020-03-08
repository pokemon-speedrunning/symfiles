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

  def make_txt
    # hardcode some stuff for the main logic to work
    case @repo
    when "pokered", "pokeyellow"
      add_rby_hardcodes
      w_start_prefix = "Start"
      s_section_names = ["PlayerName", "MainData", "SpriteData", "PartyData", "BoxData", "TilesetType"]
    when "pokegold", "pokecrystal"
      add_gsc_hardcodes
      w_start_prefix = ""
      s_section_names = ["Options", "GameData", "CrystalData"]
    else
      raise ArgumentError.new("Invalid repo (#{@repo}). Expected one of poke[red|yellow|gold|crystal].")
    end

    # common code to write the "wram/sav address" mappings for rby+gsc
    s_section_names.each do |name|
      w_start_label = "w" + name + w_start_prefix
      next unless @wram[w_start_label]

      w_end_label = "w" + name + "End"
      s_base_addr = @sram["s" + name]

      (@wram[w_start_label]...@wram[w_end_label]).each do |w_addr|
        w_label = get_label(w_addr)
        s_addr = s_base_addr + w_addr - @wram[w_start_label]
        puts format("%s = %04X (%04X)", w_label, w_addr, s_addr)
      end
    end
  end

  def add_rby_hardcodes
    # wram/sram hardcodes
    @wram["wPlayerNameStart"] = @wram["wPlayerName"]
    @wram["wPlayerNameEnd"] = @wram["wPlayerNameStart"] + 11
    @wram["wTilesetTypeStart"] = @wram["wSavedTilesetType"]
    @wram["wTilesetTypeEnd"] = @wram["wTilesetTypeStart"] + 1
    @sram["sBoxData"] = @sram["sCurBoxData"]
  end

  def add_gsc_hardcodes
    # wram/sram hardcodes
    @sram["sOptions"] = sav_addr(0x01, 0xA000)
    @sram["sGameData"] = sav_addr(0x01, 0xA009)
  end

  def get_label(addr)
    # get the lowest-level label for the address
    floor = addr.downto(0) { |n| break n if @wram.has_key?(n) }
    format("%04X+%s", addr - floor, @wram[floor])
  end
end

out_name = repo + ".txt"
puts "Outputting to #{out_name}"

File.open(File.join(__dir__, "out", out_name), "w") do |out_file|
  $stdout = out_file
  puts "wram label = wram addr (sav addr)"
  puts
  SavWram.new(repo).make_txt
end
