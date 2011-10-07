require 'logger'
require 'singleton'

class Phenomenal::Error < StandardError; end
  
class Phenomenal::Logger 
  attr_accessor :logger
  include Singleton
  
  def info(msg)
    logger.info(msg)
  end
  
  def debug(msg)
    logger.debug(msg)
  end
  
  def warn(msg)
    logger.warn(msg)
  end
  
  def error(msg)
    logger.error(msg)
    raise(Phenomenal::Error, msg)
  end
  
  private
  def initialize
    self.logger = Logger.new(STDOUT)
    self.logger.level = Logger::DEBUG
    self.logger.datetime_format = "%Y-%m-%d - %H:%M:%S"
  end
end
  

