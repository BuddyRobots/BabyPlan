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

end