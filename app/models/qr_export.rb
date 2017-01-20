class QrExport

  include Mongoid::Document
  include Mongoid::Timestamps

  field :num, type: Integer


  belongs_to :center
  belongs_to :book


  def self.create_qr(center, bid, num)
    qr_export = QrExport.create( center: center, book_id: bid, num: num ) 
    {qr_export_id: qr_export.id.to_s}
  end

  def message_info
    {
      id: self.id.to_s,
      name: self.book.name,
      author: self.book.author,
      num: self.num,
      created_at: self.created_at
    }
  end

  def self.qr_amount(qr_exports)
    total = qr_exports.map { |e| e.num }.sum()
    {
      total: total
    }
  end

  def self.export_qrcode_pdf(export_info)
    folder = "public/qrcodes/"
    start_point = [-20, 750]
    hor_interval = 100
    ver_interval = 110
    per_line = 6
    line_per_page = 7
    per_page = line_per_page * per_line
    last_page_idx = 0
    pdf_filename = folder + SecureRandom.uuid.to_s + ".pdf"
    Prawn::Document.generate(pdf_filename) do
      export_info.each_with_index do |info, idx|
        page_idx = idx / per_page
        if page_idx != last_page_idx
          start_new_page
          last_page_idx = page_idx
        end
        in_page_idx = idx % per_page
        ver_idx = in_page_idx / per_line
        hor_idx = in_page_idx % per_line
        start_y = start_point[1] - ver_interval * ver_idx
        start_x = start_point[0] + hor_interval * hor_idx
        bounding_box([start_x, start_y], width: 70, height: 90) do
          font("public/simsun/simsun.ttf") do
            text ActionController::Base.helpers.truncate(info[:book_name], length: 8), size: 10
          end
          image folder + info[:png_file], position: :center, width: 70, height: 70
        end
      end
    end
    return pdf_filename
  end
end