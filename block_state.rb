require './block_model'

class BlockState
  attr_reader :block_name, :default_state, :states, :variants, :models

  def initialize(*args)
    @block_name = args.shift
    if args.size == 1
      @default_state = args.shift
      @states = []
      @variants = ["normal"]
    else
      @default_state = args.shift
      @states = args.shift
      @variants = []
      gen_variants(@states.keys, {}, @variants)
    end

    gen_models
  end

  def file_name
    "#{@block_name}.json"
  end

  def resource_name
    "#{MOD_ID}:#{@block_name}"
  end

  def to_json_h
    if @variants.first == "normal"
      { variants: {
        normal: { model: resource_name },
        inventory: { model: resource_name }
      } }
    else
      { variants: variants_to_json_h.merge({ inventory: { model: resource_name } }) }
    end
  end

  def to_s
    "#{@block_name}: #{@variants}"
  end

  def self.from_block(block)
    variants = {}
    if block.states.size == 1
      # Only normal state
      self.new(block.block_name, block.states[:normal])
    else
      # More complex block state
      default_state_name = :normal
      default_state = block.states[:normal]
      normal_dirs = block.states[:normal].keys
      other_states = block.states.select{|k,v| k!=:normal}
      other_dirs = other_states.values.map{|h| h.keys}.flatten.uniq

      # Check if a state != :normal should be the default state
      if normal_dirs.empty? || !(other_dirs - normal_dirs).empty?
        # Ask the user for the default state
        selected_state = nil

        while !selected_state || !other_states.keys.include?(selected_state)
          print "Block '#{block.block_name}' has multiple states, which one is the default? (#{other_states.keys.join('/')}) "
          selected_state = gets.chomp
        end
        default_state_name = selected_state

        # Merge the :normal and default state
        default_state = default_state.merge(block.states[default_state_name])
        other_states = block.states.select{|k,v| k != :normal && k != default_state_name}
      end

      # Generate all possible variants
      self.new(block.block_name, default_state, other_states)
    end
  end

  private
  def gen_variants(states, variable_binding_acc, variants)
    if states.empty?
      variants << variable_binding_acc.clone
    else
      [false, true].each do |value|
        state = states.shift
        variable_binding_acc[state] = value
        gen_variants(states, variable_binding_acc, variants)
        variable_binding_acc.delete(state)
        states.unshift(state)
      end
    end
  end

  def gen_models
    @models = BlockModel.models_from_block_state(self)
  end

  # { a: true, b: false } => a=true,b=true
  def join_hash(hash, key_delim, value_delim)
    res_arr = []
    hash.each do |k,v|
      res_arr << "#{k}#{key_delim}#{v}"
    end
    res_arr.join(value_delim)
  end

  def variants_to_json_h
    variants_h = {}
    @models.each do |k,v|
      variants_h[join_hash(k,'=',',')] = { model: v.resource_name }
    end
    variants_h
  end
end