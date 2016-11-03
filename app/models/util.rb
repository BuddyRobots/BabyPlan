class Util
  def self.random_str(length)
    o = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map { |i| i.to_a }.flatten
    str = (0...length).map { o[rand(o.length)] }.join
    return str
  end
end
