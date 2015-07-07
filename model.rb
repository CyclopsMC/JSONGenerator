class Model
  def initialize(*args)
    @block_name = args.shift
    @texture_bindings = args.shift
    @states = args.shift
    @default_model = args.shift
  end

  def resource_name
    "#{MOD_ID}:#{model_name}"
  end

  def model_name
    @states ? "#{@block_name}_#{@states.join('_')}" : @block_name
  end

  def file_name
    "#{model_name}.json"
  end

  def to_json_h
    parent = @default_model ? "#{MOD_ID}:block/#{@default_model.model_name}" : "block/cube_all"
    { parent: parent, textures: @texture_bindings }
  end

  def to_s
    "M #{model_name}: #{@default_model ? @default_model.model_name : ''} > #{@texture_bindings}"
  end

  # block_name, default_state, other_states
  def self.models_from_block_state(block_state)
    models = {}

    # Generate a default model
    default_model = Model.new(block_state.block_name, block_state.default_state)

    # For each variant we generate a model with texture bindings that extend the default model
    block_state.variants.each do |variant|
      if variant == "normal"
        models["normal"] = default_model
        return models
      end

      active_states = variant.select{|k,v| v}.keys
      if active_states.empty?
        models[variant] = default_model
      else
        active_state_bindings = block_state.states.select{|k,v| active_states.include?(k)}
        texture_bindings = {}
        active_state_bindings.each{|_,b| texture_bindings.merge!(b)}

        models[variant] = Model.new(block_state.block_name, texture_bindings, active_states, default_model)
      end
    end

    models
  end
end