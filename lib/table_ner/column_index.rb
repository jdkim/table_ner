class ColumnIndex
	def initialize(headers)
		@headers = headers
		@num_col = @headers.count
		puts "The number of columns: #{@num_col}" if @headers
	end

	def update(row)
		@col_index = []
		for i in 0 ... @num_col do
			@col_index << (row[i].nil? ? nil : row[0 ... i].compact.join(' ').length)
		end
	end

	def find(d)
		idx = nil

		b = d["span"]["begin"]
		len = @col_index.length

		for i in 0 ... len
			next if @col_index[i].nil?
			if b >= @col_index[i]
				idx = i
			else
				break
			end
		end

		idx = @headers[idx] if @headers
	end
end