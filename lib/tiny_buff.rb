# a text buffer with marks, selections, and rudimentary editing
class TinyBuff
  attr_reader :length

  # content: the starting content of the buffer as a String
  def initialize(content='')
    @content = content.lines.map(&:chomp)
    @marks = {}
    @selections = {}

    @length = @content
      .map{|l| l.length }
      .sum
  end

  # returns the number of lines
  def lines
    @content.length
  end

  # line_range: the Range of lines to return (NOT line indexes numbers)
  # max_len (optional): the maximum length of each line to return; useful when you want to
  #   return a rectangular region of text for display, for example
  def [](line_range, max_len=nil)
    !!max_len ? @content[line_range] : @content[line_range].map{|l| l[..max_len] }
  end

  # col: starting column (zero-based)
  # row: starting line (zero-based)
  # wid: the number of characters per line
  # hgt: the number of rows
  def rect(col, row, wid, hgt)
    @content[row..(row + hgt - 1)]
      .map{|row| row.chomp.chars[col..(col + wid - 1)].join }
  end

  # set a mark, as in the Vim sense
  #
  # sym: the name of the mark
  # char_num: the number of characters from the top of the buffer to set the
  #   mark
  def mark(sym, char_num)
    @marks[sym] = char_num

    nil
  end

  # selects a named range of characters 
  #
  # sym: the name of the range
  # char_range: a Range representing the starting and ending byte of the
  #   selection
  def select(sym, char_range)
    @selections[sym] = char_range

    nil
  end

  # line: the line to insert
  # index: the index to insert it at (NOT the 1-based line number)
  def insert_line(line, index)
    @content.insert(line, index)
    @length += line.length
  end

  # str: the String to insert
  # char_num: the char_num at which to start the insertion
  def insert_text(str, char_num)
    # TODO: this is tricky because if the string contains multiple lines then
    # you're not just inserting in the middle of an existing line, you're
    # inserting some text which may include multiple lines
  end

  # index: the indext of the line to delete (NOT the 1-based line number)
  def delete_at(index)
    @length -= @content[index].length
    @content.delete_at(index)
  end

  # char_range: the range of characters to remove from this TinyBuff
  def delete_range(char_range)
    # TODO: this deletes the Range of characters, which may span multiple lines
  end

  # line: the line to add to the end of the buffer
  def push(line)
    @content << line
    @length += line.length

    nil
  end
  alias << push

  # deletes and returns the last line of this buffer
  def pop
    @length -= (@content.pop).length

    nil
  end

  # line: the line to be added to the beginning of the buffer
  def unshift(line)
    @content.unshift(line)
    @length += line.length

    nil
  end
  alias >> unshift

  # deletes and returns the first line of the buffer
  def shift
    @length -= (@content.shift).length
  end

  def to_s
    @content.join("\n")
  end
end
