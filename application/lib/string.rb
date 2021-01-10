class String
  def to_valid_float
    # Exemple:
    # "asdfd12s3a.0,02" => 123.002

    # Array of allowed characters
    accept_chars = (0..9).to_a.map { |n| n.to_s } + ['.']

    text = self.gsub(',', '.')
    filtered_string = text.split('').filter { |char| accept_chars.include? char }
    filtered_string = filtered_string.join.partition '.'
    filtered_string[2] = filtered_string[2].gsub '.', ''
    filtered_string.join('').to_f
  end
end