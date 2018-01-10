module BlocRecord
  class Collection < Array
    def update_all(updates)
      ids = self.map(&:id)
      self.any? ? self.first.class.update(ids, updates) : false
    end

    def take(num=1)
      self.any? ? self.sample(num) : false
    end

    def where(*args)
      self.any? ? self.first.class.where(args) : false
    end

    def not(args)
      not_key = args.shift.to_s
      not_value = args
      self.any? ? self.map { |pair| pair.delete_if {|key, value| key == not_key && value == not_value} }.compact : false
    end
  end
end
