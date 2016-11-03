class Util
  def self.random_str(length)
    o = [('a'..'z'), ('A'..'Z'), ('0'..'9')].map { |i| i.to_a }.flatten
    str = (0...length).map { o[rand(o.length)] }.join
    return str
  end

  def self.sign(data, key)
    data = data.sort.to_h
    data_str = data.to_a.map { |e| e.join('=') } .join('&')
    with_key = data_str + "&key=" + key
    Digest::SHA1.hexdigest(with_key).upcase
  end
end
