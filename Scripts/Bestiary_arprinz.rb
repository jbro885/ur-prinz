#==========================================================================
# *** Bestiary/Monster Book
#--------------------------------------------------------------------------
#  This plugin provides a list of enemies defeated in-game. The bestiary
# shows the quantity of enemies slain, along with other stats, from health
# to treasures to weaknesses and strengths.
#
# * Version: 1.0.1
#
# * Updated: 2017-10-25
#
# * Coded by: boaromayo/Quesada's Swan
#
# Optional prerequisites:
#  * Expanded iconset for elements
#==========================================================================
#==========================================================================
# ** Game_System
#--------------------------------------------------------------------------
#  This class handles system data. It saves the disable state of saving and 
# menus. Instances of this class are referenced by $game_system.
#==========================================================================
class Game_System
  #------------------------------------------------------------------------
  # * Add new public instance variables
  #------------------------------------------------------------------------
  attr_accessor :enemy_encounter			# Checks if enemy encountered?
  attr_accessor :enemy_slain?				# Number of enemies slain
  attr_accessor	:enemy_count				# Number of a certain enemy defeated
  #------------------------------------------------------------------------
  # * Add initialize method
  #------------------------------------------------------------------------
  alias bestiary_initialize initialize
  def initialize
	bestiary_initialize
	@enemy_encounter = []
	@enemy_slain? = 0
	@enemy_count = []
	$data_enemies.size.each do |enemy|
	  @enemy_encounter[enemy] = false
	  @enemy_count[enemy] = 0
	end
  end
end

#==========================================================================
# ** Game_Troop
#--------------------------------------------------------------------------
#  This class handles enemy groups and battle-related data. Also performs
# battle events. The instance of this class is referenced by $game_troop.
#==========================================================================
class Game_Troop < Game_Unit

end

#==========================================================================
# ** Window_BestiaryStat
#--------------------------------------------------------------------------
#  This window displays the number of monsters slain.
#==========================================================================
class Window_BestiaryStat < Window_Help
  #------------------------------------------------------------------------
  # * Object Initialization
  #------------------------------------------------------------------------
  def initialize
    super
    draw_progress
  end
  #------------------------------------------------------------------------
  # * Draw Progress
  #------------------------------------------------------------------------
  def draw_progress
    completed = $game_system.enemy_slain
    max_i = $data_enemies.size 
	pct = (completed / max_i) * 100
    prog_text = "Progress: " + completed.to_s + "/" + max_i.to_s
    set_text(prog_text)
  end
end

#==========================================================================
# ** Window_BestiaryList
#--------------------------------------------------------------------------
#  This window displays the list of monsters.
#==========================================================================
class Window_BestiaryList < Window_Selectable
  #------------------------------------------------------------------------
  # * Object Initialization
  #------------------------------------------------------------------------
  def initialize
    super(0, 0, Graphics.width, Graphics.height - fitting_height(2))
    @data = []
  end
  #------------------------------------------------------------------------
  # * Get Column Count
  #------------------------------------------------------------------------
  def col_max
    return 2
  end
  #------------------------------------------------------------------------
  # * Get Number of Enemies Slain
  #------------------------------------------------------------------------
  def enemy_now
	$game_system.enemy_slain
  end
  #------------------------------------------------------------------------
  # * Get Maximum Number of Enemies In Bestiary
  #------------------------------------------------------------------------
  def enemy_max
    $data_enemies.size
  end
  #------------------------------------------------------------------------
  # * Get Data of Selected Enemy
  #------------------------------------------------------------------------
  def enemy(id)
    @data[id]
  end
  #------------------------------------------------------------------------
  # * Get Enemies Data
  #------------------------------------------------------------------------
  def enemies
	@data
  end
end

#==========================================================================
# ** Window_BestiaryLeft
#--------------------------------------------------------------------------
#  This window (the left window) displays the enemy's sprite & background.
#==========================================================================
class Window_BestiaryLeft < Window_Selectable
  #------------------------------------------------------------------------
  # * Object Initialization
  #------------------------------------------------------------------------
  def initialize(enemy)
    super(0, 0, window_width, Graphics.height)
    @enemy = enemy
    refresh
  end
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    return Graphics.width / 2
  end
  #--------------------------------------------------------------------------
  # * Get Window Height
  #--------------------------------------------------------------------------
  def window_height
    return Graphics.height / 2
  end
  #------------------------------------------------------------------------
  # * Set Enemy
  #------------------------------------------------------------------------
  def enemy=(enemy)
    return if @enemy == enemy
    @enemy = enemy
    refresh
  end
  #------------------------------------------------------------------------
  # * Get Enemy Bitmap
  #------------------------------------------------------------------------
  def enemy_bitmap(enemy)
    sprite = enemy.battler_sprite
	#draw_battler
  end
end

#==========================================================================
# ** Window_BestiaryRight
#--------------------------------------------------------------------------
#  This window (the right window) displays enemy stats (HP, MP, etc).
#==========================================================================
class Window_BestiaryRight < Window_Selectable
  #------------------------------------------------------------------------
  # * Object Initialization
  #------------------------------------------------------------------------
  def initialize(enemy)
    super(window_width, 0, window_width, Graphics.height)
    @enemy = enemy
    refresh
  end
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    return Graphics.width / 2
  end
  #--------------------------------------------------------------------------
  # * Draw Enemy Name
  #--------------------------------------------------------------------------
  def draw_enemy_name(enemy, x, y, width = 144)
    name = enemy.name
    draw_text(x, y, width, line_height, name)
  end
  #--------------------------------------------------------------------------
  # * Draw Horizontal Line
  #--------------------------------------------------------------------------
  def draw_horz_line(y)
    line_y = y + line_height / 2 - 1
    contents.fill_rect(0, line_y, contents_width, 2, line_color)
  end
  #--------------------------------------------------------------------------
  # * Get Color of Horizontal Line
  #--------------------------------------------------------------------------
  def line_color
    color = system_color
    color.alpha = 48
    color
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh(mode = 0)
    contents.clear
    draw_enemy_name(@enemy, window_width - 10, 0)
    draw_horz_line(line_height + line_height / 4 + 3)
    if mode == 0
      draw_basic_stats(@enemy, 10, 0)
      draw_other_stats(@enemy, 10, line_height * 3)
    elsif mode == 1
      draw_elem_stats(@enemy)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Basic Stats
  #--------------------------------------------------------------------------
  def draw_basic_stats(enemy, x, y)
    draw_enemy_hp(enemy, x, y + line_height * 2)
    draw_enemy_mp(enemy, x, y + line_height * 3)
	#draw_enemy_tp(enemy, x, y + line_height * 4)
  end
  #--------------------------------------------------------------------------
  # * Draw Other Stats
  #--------------------------------------------------------------------------
  def draw_other_stats(enemy, x, y)
    param_count.each { |i| draw_enemy_param(enemy, x, y + line_height * i, i) }
  end
  #--------------------------------------------------------------------------
  # * Draw Element Stats
  #--------------------------------------------------------------------------
  def draw_elem_stats(enemy)
    # Add the defense ratings starting from weakest => absorbing
    add_ratings
    elements_count.each do |elem|
	  draw_enemy_element(enemy, 10, line_height * (elem + 2), enemy.element_rate(elem))
	end
	#states_count.each do |state|
	  #draw_enemy_state(enemy, window_width - 10, line_height * (state + 2), enemy.state_rate(state))
	#end
	change_color(normal_color)
  end
  #--------------------------------------------------------------------------
  # * Enemy Parameter Count
  #--------------------------------------------------------------------------
  def param_count
    2..7 # 2 => ATK, 7 => LCK
  end
  #--------------------------------------------------------------------------
  # * Enemy Element Rate Count
  #	    NOTE: Adjust number of elements counted based on elements used.
  #--------------------------------------------------------------------------
  def elements_count
    3..14 # 3 => Fire, 14 => Void/Null
  end
  #--------------------------------------------------------------------------
  # * Enemy States Rate Count
  #		NOTE: Adjust number of states counted based on states used.
  #--------------------------------------------------------------------------
  def states_count
    1..10 # 1 => Death, 10 => Burn?
  end
  #--------------------------------------------------------------------------
  # * Draw Enemy HP
  #--------------------------------------------------------------------------
  def draw_enemy_hp(enemy, x, y, width = 288)
    change_color(system_color)
    draw_text(x, y, width, line_height, Vocab::hp)
    change_color(normal_color)
    draw_text(x + width - 32, y, width, line_height, enemy.mhp, 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Enemy MP
  #--------------------------------------------------------------------------
  def draw_enemy_mp(enemy, x, y, width = 288)
    change_color(system_color)
    draw_text(x, y, width, line_height, Vocab::mp)
    change_color(normal_color)
    draw_text(x + width - 32, y, width, line_height, enemy.mmp, 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Enemy TP
  #--------------------------------------------------------------------------
  def draw_enemy_tp(enemy, x, y, width = 288)
    change_color(system_color)
    draw_text(x, y, width, line_height, Vocab::tp)
    change_color(normal_color)
    draw_text(x + width - 32, y, width, line_height, enemy.tp, 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Enemy Parameters
  #--------------------------------------------------------------------------
  def draw_enemy_param(enemy, x, y, param_id, width = 172)
    change_color(system_color)
    draw_text(x, y, width, line_height, Vocab::param(param_id))
    change_color(normal_color)
    draw_text(x + width - 32, y, width, line_height, enemy.params(param_id), 2)
  end
  #--------------------------------------------------------------------------
  # * Add Enemy Element Defense Rating
  #     name   : rating name
  #     symbol : corresponding symbol
  #--------------------------------------------------------------------------
  def add_rating(name, symbol)
    @rate_list.push({:name=>name, :symbol=>symbol})
  end
  #--------------------------------------------------------------------------
  # * Get Enemy Element Rating Name
  #--------------------------------------------------------------------------
  def element_rating(index)
    @rate_list[index][:name]
  end
  #--------------------------------------------------------------------------
  # * Get Enemy State Rating Name
  #--------------------------------------------------------------------------
  def state_rating(index)
	@rate_list[index][:name]
  end
  #--------------------------------------------------------------------------
  # * Add Enemy Rating Names
  #--------------------------------------------------------------------------
  def add_ratings
    add_rating("Very Weak", :very_weak)
    add_rating("Weak",      :weak)
    add_rating("---------", :neutral)
    add_rating("Strong",    :strong)
    add_rating("Immune",    :immune)
    add_rating("Absorb",    :absorb)
  end
  #--------------------------------------------------------------------------
  # * Draw Enemy Elemental Stats
  #--------------------------------------------------------------------------
  def draw_enemy_element(enemy, x, y, param_id, width = 172)
    # Element tag to track enemy's element defense
    element_def = ""
    erate = enemy.element_rate(param_id)
    if erate >= 200
	  change_color(text_color(10))
      element_def = element_rating(0)
    elsif erate > 100
	  change_color(text_color(2))
      element_def = element_rating(1)
    elsif erate == 100
	  change_color(normal_color, false)
      element_def = element_rating(2)
    elsif erate > 0
      element_def = element_rating(3)
    elsif erate == 0
      element_def = element_rating(4)
    else
	  change_color(text_color(3))
      element_def = element_rating(5)
    end
	draw_icon(element_icon(param_id), x, y)
    draw_text(x + width - 32, y, width, line_height, element_def, 2)
  end
  #------------------------------------------------------------------------
  # * Draw Enemy State Stats
  #------------------------------------------------------------------------
  def draw_enemy_state(enemy, x, y, param_id, width = 172)
    # State defense tag to track enemy's status defense
    state_def = ""
    srate = enemy.state_rate(param_id)
	if srate >= 200
	  change_color(text_color(10))
	  state_def = state_rating(0)
	elsif srate > 100
	  change_color(text_color(2))
	  state_def = state_rating(1)
	elsif srate == 100
	  change_color(normal_color, false)
	  state_def = state_rating(2)
	elsif srate > 0
	  state_def = state_rating(3)
	elsif srate == 0
	  state_def = state_rating(4)
	else
	  change_color(text_color(3))
	  state_def = state_rating(5)
	end
	draw_text(x + width - 32, y, width, line_height, state_def, 2)
  end
  #------------------------------------------------------------------------
  # * Draw Enemy Items
  #------------------------------------------------------------------------
  def draw_enemy_items(enemy, x, y, width = 172)
    change_color(system_color)
    draw_text(x, y, width, line_height, "Drops")
	draw_horz_line(y + line_height)
    change_color(normal_color)
    enemy.items.each do |item|
	  draw_item_name(item, x, y + line_height * 2)
    end
  end
  #------------------------------------------------------------------------
  # * Draw Element Icons
  # 	Note: These numbers are only applicable to the big iconset.
  #------------------------------------------------------------------------
  def element_icon(index)
    # Set icon values based on icon index (adjust if icon index for each element is different)
    elem_icon = 101
	physical_icon = 2
	wood_icon = 192
	steel_icon = 146
	heart_icon = 135
	byss_icon = 136
	
	# Return icon value based on index passed
	return index + elem_icon if index > 2 && index < 11
	return 0 if index == 2
	return wood_icon if index == 11
	return steel_icon if index == 12
	return heart_icon if index == 13
	return byss_icon if index == 14
	return physical_icon
  end
  #------------------------------------------------------------------------
  # * Draw Element Icons
  #  Note: This method is for the default iconset.
  #------------------------------------------------------------------------
  #def element_icon(index)
    # Set icon values based on loaded bigicon
    #elem_icon = 93
	#physical_icon = 107
	
	# Return icon value based on index passed
	#return index + elem_icon if index > 2 && index < 11
	#return 0 if index == 2
	#return physical_icon
  #end
end

#==========================================================================
# ** Scene_Bestiary
#--------------------------------------------------------------------------
#  This class performs the bestiary scene processing.
#==========================================================================

class Scene_Bestiary < Scene_Base
  #------------------------------------------------------------------------
  # * Start Processing
  #------------------------------------------------------------------------
  def start
    super
	load_bestiary_data
    create_bestiary_list_windows
    create_bestiary_windows(@enemy)
  end
  #------------------------------------------------------------------------
  # * Create Bestiary List
  #------------------------------------------------------------------------
  def create_bestiary_list_windows
    create_stat_window
    create_list_window
  end
  #------------------------------------------------------------------------
  # * Create Stat Window
  #------------------------------------------------------------------------
  def create_stat_window
    @stat_window = Window_BestiaryStat.new
    @stat_window.activate
    @stat_window.show
  end
  #------------------------------------------------------------------------
  # * Create Bestiary List Window
  #------------------------------------------------------------------------
  def create_list_window
    @list_window = Window_BestiaryList.new
  end
  #------------------------------------------------------------------------
  # * Create Bestiary Windows
  #------------------------------------------------------------------------
  def create_bestiary_windows(enemy)
    create_left_window(enemy)
    create_right_window(enemy)
  end
  #------------------------------------------------------------------------
  # * Create Left Window
  #------------------------------------------------------------------------
  def create_left_window(enemy)
    @left_window = Window_BestiaryLeft.new(enemy)
  end
  #------------------------------------------------------------------------
  # * Create Right Window
  #------------------------------------------------------------------------
  def create_right_window(enemy)
    @right_window = Window_BestiaryRight.new(enemy)
  end
  #------------------------------------------------------------------------
  # * Load Bestiary Data
  #------------------------------------------------------------------------
  def load_bestiary_data
	enemies_encounter = $game_system.enemy_encounter
	enemies_slain	  = $game_system.enemy_slain?
	enemies_slain_no  = $game_system.enemy_count
	if enemies_slain > 0
	  enemies_encounter.each do |enemy|
	    if enemies_encounter[enemy]
		  
		else
		end
	  end
	end
  end
  #------------------------------------------------------------------------
  # * Frame Update
  #------------------------------------------------------------------------
  def update
    super
    update_all_windows
  end
  #------------------------------------------------------------------------
  # * Update All Windows
  #------------------------------------------------------------------------
  def update_all_windows
    @left_window.update
    @right_window.update
  end
  #------------------------------------------------------------------------
  # * Switch to Next Enemy
  #------------------------------------------------------------------------
  def next_enemy
  end
  #------------------------------------------------------------------------
  # * Switch to Previous Enemy
  #------------------------------------------------------------------------
  def prev_enemy
  end
end
