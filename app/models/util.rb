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
    Digest::MD5.hexdigest(with_key).upcase
  end

  def self.hash_to_xml(h)
    "<xml>" + h.to_a.map { |e| "<#{e[0]}>#{e[1]}</#{e[0]}>" } .join + "</xml>"
  end

  def self.billno_random_str
    mch_id = "1445887202"
    date = Time.now.strftime("%Y%m%d%H%M%S")
    ran = Random.rand(1...10000).to_s
    str = mch_id + date + ran
    return str
  end
end
