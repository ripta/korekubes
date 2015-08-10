
require 'ostruct'

class DeepStruct < OpenStruct

  def initialize(h = nil)
    @table = {}
    @htable = {}

    if h
      h.each do |k, v|
        @table[k.to_sym] = v.is_a?(Hash) ? self.class.new(v) : v
        @htable[k.to_sym] = v
        new_ostruct_member(k)
      end
    end
  end

  def to_h
    @htable
  end

end

