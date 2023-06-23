# a text buffer with marks, selections, and rudimentary editing
class FancyBuff
  attr_reader :chars,
              :bytes,
              :lines,
              :length,
              :marks,
              :selections

  attr_accessor :win

  # gives you a default, empty, zero slice
  def initialize
    # size tracking
    @chars = 0        # the number of characters in the buffer (not the same as the number of bytes)
    @bytes = 0        # the number of bytes in the buffer (not the same as the number of characters)
    @lines = []

    @marks = {}
    @selections = {}
    @win = [0, 0, 0, 0]    # the default slice is at the beginning of the buffer, and has a zero size
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

  # col: starting column (zero-based)
  # row: starting line (zero-based)
  # wid: the number of characters per line
  # hgt: the number of rows
  def rect(col, row, wid, hgt)
    @lines[row..(row + hgt - 1)]
      .map{|row| row.chars[col..(col + wid - 1)].join }
  end

  # set a mark, as in the Vim sense
  #
  # sym: the name of the mark
  # char_num: the number of characters from the top of the buffer to set the
  #   mark
  def mark(sym, char_num)
    @marks[sym] = [@chars, char_num].min

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

  # line: the line to add to the end of the buffer
  def <<(line)
    line.chomp!
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
