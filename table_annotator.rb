#!/usr/bin/env ruby
require 'rest-client'

class Annotator
	def initialize(annotator_url)
		@annotator = annotator_url
	end

	def annotate(text)
		r = RestClient.get @annotator, {params: {text:text}}
		a = JSON.parse(r)

		if a['denotations'].empty?
			{}
		else
			a
		end
	end
end

def find_index(d)
	idx = nil

	b = d["span"]["begin"]
	len = @row_index.length


	for i in 0 ... len
		next if @row_index[i].nil?
		if b >= @row_index[i]
			idx = i
		else
			break
		end
	end

	idx
end

if __FILE__ == $0
	require 'csv'
	require 'json'

	annotator_url = 'https://pubdictionaries.org/text_annotation.json?dictionary=EBI_biome_list&longest=true'
	delimiter = ', '

	## command line option processing
	require 'optparse'
	optparse = OptionParser.new do|opts|
		opts.banner = "Usage: table_annotator.rb [options] input_tsv output_tsv"

		opts.on('-a', '--annotator_URL', "specifies the URL of the annotator to use. (default: #{annotator_url})") do |a|
			annotator = a
		end

		opts.on('-d', '--delimiter', "specifies the delimiter. (default: '#{delimiter}')") do |d|
			delimiter = d
		end

		opts.on('-h', '--help', 'displays this screen') do
			puts opts
			exit
		end
	end

	optparse.parse!

	if ARGV.length < 2 || annotator_url.empty?
		puts optparse.help
		exit 1
	end

	filename_tsv_in  = ARGV[0]
	filename_tsv_out = ARGV[1]
	puts "Annotator URL   : #{annotator_url}"
	puts "Input TSV file  : #{filename_tsv_in}"
	puts "Output TSV file : #{filename_tsv_out}"
	puts "Delimiter       : '#{delimiter}'"
	puts

	headers = []
	num_col = 0
	col_host = nil

	annotator = Annotator.new(annotator_url)
	# CSV.foreach(filename_tsv_in, col_sep: "\t") do |row|
	CSV.foreach(filename_tsv_in) do |row|
		if headers.empty?
			headers = row
			num_col = headers.count
			col_host = headers.index('host')
			puts "The number of columns: #{num_col}"
			puts "The 'host' column: #{col_host}"
			next
		end

		summary = []

		annotation = if row[col_host].nil?
		# if true
			row_whole_text = ''
			row_index = []

			for i in 0 ... num_col do
				if row[i].nil? || row[i].empty?
					row_index[i] = nil
				else
					row_whole_text += ' ' unless row_whole_text.empty?
					row_index[i] = row_whole_text.length
					row_whole_text += row[i]
				end
			end

			@row_index = row_index

			whole_result = annotator.annotate(row_whole_text)

			# get the column results
			col_results = if whole_result.empty?
				[]
			else
				whole_result["denotations"].collect do |d|
					header = headers[find_index(d)]
					"#{d['obj']} [#{header}]"
					# "#{d} [#{header}]"
				end
			end

			col_results
		else
			[]
		end

		puts row.push(annotation.join(delimiter)).join("\t")
		# puts annotation.join("\n")
		# puts "---"
	end
end
