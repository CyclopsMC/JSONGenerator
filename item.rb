class Item
  attr_reader :item_name

  def initialize(item_name)
    @item_name = item_name
  end

  def file_name
    "#{item_name}.json"
  end

  def to_json_h
    {
      parent: "cyclopscore:item/flat",
      textures: {
        layer0: "#{MOD_ID}:items/#{item_name}"
      }
    }
  end
end