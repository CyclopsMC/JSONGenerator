require 'ostruct'

class Texture
  def initialize(texture_name)
    @texture_name = texture_name
  end

  def to_s
    "#{MOD_ID}:blocks/#{@texture_name}"
  end
end

class Block
  attr_reader :states, :block_name

  def initialize(block_name)
    @block_name = block_name
    @states = {:normal => {}}
  end

  def add_texture(states, texture)
    texture = Texture.new(texture)
    if states.empty?
      @states[:normal]["all"] = texture
      return
    end

    res = split_states_and_directions(states)

    if res.directions.size > 1
      puts "Warning: found multiple directions in one texture for #{block_name}: #{directions}"
      return
    end

    map_states_to_textures(res.real_states, res.directions, texture)
  end

  def to_s
    "#{@states.to_s}"
  end

  private

  def split_states_and_directions(states)
    # Look for directions and actual states
    real_states = []
    directions = []

    states.each do |state|
      direction = state_to_direction(state)
      if direction
        directions << direction
      elsif !ignore_state?(state)
        real_states << state
      end
    end

    OpenStruct.new(real_states: real_states, directions: directions)
  end

  def map_states_to_textures(real_states, directions, texture)
    # Map states to directions and textures
    direction = directions.first || "all"
    if real_states.empty?
      @states[:normal][direction] = texture
    else
      real_states.each do |state|
        dirs = @states[state] = {} unless dirs = @states[state]
        dirs[direction] = texture
      end
    end
  end

  def ignore_state?(state)
    begin
      Integer(state)
      return true
    rescue
    end

    ["border", "corner", "innerCorner", "inventory", "inner", "OLD"].include?(state)
  end

  # ignore: 0, 1, ..., border, corner, innerCorner, inventory, inner, OLD
  def state_to_direction(state)
    state = state.downcase
    default_directions = ["down", "up", "north", "south", "west", "east"]
    return state if default_directions.include?(state)

    case state
    when "side"
      return "all"
    when "top"
      return "up"
    when "bottom"
      return "down"
    else
      return nil
    end
  end
end