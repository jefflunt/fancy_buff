# a text buffer with marks, selections, and rudimentary editing
class FancyBuff
  attr_reader :length,
              :marks,
              :selections

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
  def [](line_range)
    @content[line_range]
  end

  # col: starting column (zero-based)
  # row: starting line (zero-based)
  # wid: the number of characters per line
  # hgt: the number of rows
  def rect(col, row, wid, hgt)
    @content[row..(row + hgt - 1)]
      .map{|row| row.chars[col..(col + wid - 1)].join }
  end

  # set a mark, as in the Vim sense
  #
  # sym: the name of the mark
  # char_num: the number of characters from the top of the buffer to set the
  #   mark
  def mark(sym, char_num)
    @marks[sym] = [length, char_num].min

    nil
  end

  # remote a mark by name
  #
  # sym: the name of the mark to remove
  def unmark(sym)
    @marks.delete(sym)
    
    nil
  end

  # selects a named range of characters. selections are used to highlight
  # chunks of text that you can refer to later. by giving them a name it's like
  # having a clipboard with multiple clips on it.
  #
  # sym: the name of the selection
  # char_range: a Range representing the starting and ending char of the
  #   selection
  def select(sym, char_range)
    @selections[sym] = char_range

    nil
  end

  # deletes a named selection
  #
  # sym: the name of the selection
  # char_range: a Range representing the starting and ending char of the
  #   selection
  def unselect(sym)
    @selections.delete(sym)

    nil
  end

  # index: the index to insert it at (NOT the 1-based line number)
  # line: the line to insert
  #
  # NOTE: if `index` is greater than the number of lines in content, then the
  # line is simply appended to the end of the buffer
  def insert_line(index, line)
    @content.insert([lines, index].min, line)
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
