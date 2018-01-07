module BlocRecord
  class Collection < Array
    def update_all(updates)
      ids = self.map(&:id)
      self.any? ? self.first.class.update(ids, updates) : false
    end

    def not(args)
      ids = self.map(&:id)
      self.any? ? self.first.class.where(ids, args) : false
    end
  end
end
