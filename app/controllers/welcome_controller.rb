class WelcomeController < ApplicationController
  def index

  end

  def home
      gdbm = GDBM.new("tmp/limits.db")
      @limits = gdbm.to_hash
      gdbm.close
  end
end
