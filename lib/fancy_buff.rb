# a text buffer with marks, selections, and rudimentary editing
class FancyBuff
  attr_reader :chars,
              :bytes,
              :lines,
              :length,
              :max_char_width,
              :marks,
              :selections

  # allows the consuming application to set the window size, since that
  # application is probably mananging the other buffers in use
  attr_accessor :win

  # gives you a default, empty, zero slice
  #
  # formatter - a Rouge formatter
  # lexer - a Rouge lexer
  def initialize(formatter, lexer)
    @formatter = formatter
    @lexer = lexer

    # size tracking
    @chars = 0        # the number of characters in the buffer (not the same as the number of bytes)
    @bytes = 0        # the number of bytes in the buffer (not the same as the number of characters)
    @lines = []
    @max_char_width = 0
    @all_buff = @lines.join("\n")

    @marks = {}
    @selections = {}
    @win = [0, 0, 0, 0]    # the default slice is at the beginning of the buffer, and has a zero size
  end

  # index of first visible row
  def r
    @win[0]
  end

  # index of first visible column
  def c
    @win[1]
  end

  # width of the buffer window
  def w
    @win[2]
  end

  # height of the buffer window
  def h
    @win[3]
  end

  # returns an array of strings representing the visible characters from this
  # FancyBuffer's @rect
  def win_s
    r, c, w, h = @win

    return [] if h == 0 || w == 0

    line_no_width = @lines.length.to_s.length
    text = @formatter
      .format(@lexer.lex(@lines.join("\n")))
      .lines[r..(r + visible_lines - 1)]
      .map.with_index{|row, i| "#{(i + r + 1).to_s.rjust(line_no_width)} #{substr_with_color(row, c,  c + w - line_no_width - 2)}" }
      .map{|l| l.chomp + "\e[0K" } +
      Array.new(blank_lines) { "\e[0K" }
  end

  # input - a String that may or may not contain ANSI color codes
  # start - the starting index of printable characters to keep
  # finish - the ending index of printable characters to keep
  #
  # treats `input' like a String that does
  def substr_with_color(input, start, finish)
    ansi_pattern = /\A\e\[[0-9;]+m/
    printable_counter = 0
    remaining = input.clone.chomp
    result = ''

    loop do
      break if remaining.empty? || printable_counter > finish

      match = remaining.match(ansi_pattern)
      if match
        result += match[0]
        remaining = remaining.sub(match[0], '')
      else
        result += remaining[0] if printable_counter >= start
        remaining = remaining[1..-1]
        printable_counter += 1
      end
    end

    result + "\e[0m"
  end

  # the number of visible lines from @lines at any given time
  def visible_lines
    [h, @lines.length - r].min
  end

  # the number of blank lines in the buffer after showing all visible lines
  def blank_lines
    [@win[3] - visible_lines, 0].max
  end

  # scrolls the visible window up
  def win_up(n=1)
    @win[0] = [@win[0] - n, 0].max
  end

  # scrolls the visible window down
  def win_down(n=1)
    @win[0] = [@win[0] + n, @lines.length - 1].min
  end

  # scrolls the visible window left
  def win_left(n=1)
    @win[1] = [@win[1] - n, 0].max
  end

  # scrolls the visible window right
  def win_right(n=1)
    @win[1] = [@win[1] + n, max_char_width - 1].min
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
    @max_char_width = line.chars.length if line.chars.length > @max_char_width

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
