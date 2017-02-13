class Tenant < ActiveRecord::Base

  before_create :generate_api_key


  def limits
      gdbm = GDBM.new("tmp/limits.db")
      return gdbm[self.api_key].to_i
      gdbm.close
  end


  private

  def generate_api_key
    self.api_key = SecureRandom.hex(16)
  end



end
