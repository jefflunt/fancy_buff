# a text buffer with marks, selections, and rudimentary editing
class FancyBuff
  attr_reader :chars,
              :bytes,
              :lines

  attr_accessor :win


  # gives you a default, empty, zero slice
  def initialize
    @lines = []
    @marks = {}
    @selections = {}
    @win = [0, 0, 0, 0]    # the default slice is at the beginning of the buffer, and has a zero size

    # size tracking
    @bytes = 0        # the number of bytes in the buffer (not the same as the number of characters)
    @chars = 0        # the number of characters in the buffer (not the same as the number of bytes)
  end

  def r
    @win[0]
  end

  def c
    @win[1]
  end

  def w
    @win[2]
  end

  def h
    @win[3]
  end

  # returns an array of strings representing the visible characters from this
  # FancyBuffer's @rect
  def win_s
    r, c, w, h = @win

    return [] if h == 0 || w == 0

    @lines[r..([r + h - 1, 0].max)]
      .map.with_index{|row, i| "#{(i + r + 1).to_s.rjust(3)} #{row.chars[c..(c + w - 1 - 4)]&.join}" }
  end

  def win_up(n=1)
    @win[0] = [@win[0] - n, 0].max
  end

  def win_down(n=1)
    @win[0] = [@win[0] + n, @lines.length - @win[3]].min
  end

  def win_left(n=1)
    @win[1] = [@win[1] - n, 0].max
  end

  def win_right(n=1)
    @win[1] = [@win[1] + n, 100].min
  end

  # returns the number of lines
  def lines
    @lines.length
  end

#  # set a mark, as in the Vim sense
#  #
#  # sym: the name of the mark
#  # char_num: the number of characters from the top of the buffer to set the
#  #   mark
#  def mark(sym, char_num)
#    @marks[sym] = char_num
#
#    nil
#  end
#
#  # selects a named range of characters 
#  #
#  # sym: the name of the range
#  # char_range: a Range representing the starting and ending byte of the
#  #   selection
#  def select(sym, char_range)
#    @selections[sym] = char_range
#
#    nil
#  end
#
#  # line: the line to insert
#  # index: the index to insert it at (NOT the 1-based line number)
#  def insert_line(line, index)
#    @lines.insert(line, index)
#    @bytes += line.length
#    @chars += line.chars.length
#  end
#
#  # str: the String to insert
#  # char_num: the char_num at which to start the insertion
#  def insert_text(str, char_num)
#    # TODO: this is tricky because if the string contains multiple lines then
#    # you're not just inserting in the middle of an existing line, you're
#    # inserting some text which may include multiple lines
#  end
#
#  # index: the indext of the line to delete (NOT the 1-based line number)
#  def delete_at(index)
#    @bytes -= @lines[index].length
#    @chars -= @lines[index].chars.length
#    @lines.delete_at(index)
#  end
#
#  # char_range: the range of characters to remove from this FancyBuff
#  def delete_range(char_range)
#    # TODO: this deletes the Range of characters, which may span multiple lines
#  end
#
  # line: the line to add to the end of the buffer
  def <<(line)
    @lines << line
    @bytes += line.length
    @chars += line.chars.length

    nil
  end
#
#  # deletes and returns the last line of this buffer
#  def pop
#    l = @lines.pop
#    @bytes -= l.length
#    @chars -= l.chars.length
#
#    nil
#  end
#
#  # line: the line to be added to the beginning of the buffer
#  def unshift(line)
#    @lines.unshift(line)
#    @bytes += line.length
#    @chars += line.chars.length
#
#    nil
#  end
#  alias >> unshift
#
#  # deletes and returns the first line of the buffer
#  def shift
#    l = @lines.shift
#    @bytes -= l.length
#    @chars -= l.chars.length
#  end
end
