module ApplicationHelper
  # Returns a nested array that can be used as the collection for a select field
  #
  # @param model_class [Class] model class containing with the enum
  # @param enum [Symbol,String] name of the enum
  def options_for_enum(model_class, enum)
    enum_hash = model_class.send(enum.to_s.pluralize)

    enum_hash.map do |key, _value|
      [ model_class.human_attribute_name("#{enum}.#{key}"), key ]
    end
  end
end
