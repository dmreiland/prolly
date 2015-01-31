require "forwardable"
require "rand_var"

require "pspace/storage/rubylist"
require "pspace/storage/redis"

class PSpace

  class << self
    attr_reader :ps

    def import(data)
      @ps ||= PSpace.new(data)
    end

    def reset
      @ps ||= PSpace.new([])
      @ps.reset
    end

    def add(datum)
      @ps ||= PSpace.new([])
      @ps.add(datum)
    end

    def rv(*rand_vars)
      if rand_vars.empty?
        @ps.rand_vars
      else
        RandVar.new(@ps, *rand_vars)
      end
    end

    def stash
      @ps.stash
    end

    # unique values for a random variable.
    #
    # If there are multiple random variables, then we get combinations of the unique
    # values of the random variables
    def uniq_vals(uspec_rvs)

      def combo(list_of_vals)
        if list_of_vals.length == 1
          list_of_vals.first.map { |e| [e] }
        else
          combinations = combo(list_of_vals[1..-1])
          list_of_vals.first.flat_map { |val| combinations.map { |e| [val] + e } }
        end
      end

      combo(uspec_rvs.map { |uspec_rv| @ps.uniq_vals(uspec_rv) })
    end
  end

  extend Forwardable

  def_delegators :@storage, :reset, :add, :count, :rand_vars, :uniq_vals

  def initialize(data)
    @storage = Storage::Rubylist.new(data)
    #@storage = Storage::Redis.new(data)
  end

end

