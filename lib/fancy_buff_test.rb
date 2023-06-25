require 'minitest/autorun'
require 'rouge'
require_relative './fancy_buff'

class TestFancyBuff < Minitest::Test
  def setup
    @content = "line 1\nline 2\nline 3"
    @formatter = Rouge::Formatters::Terminal256.new
    @lexer = Rouge::Lexers::Ruby.new
    @buff = FancyBuff.new(@formatter, @lexer)
    @content.lines.each{|l| @buff << l }
    @buff.win = [0, 0, 5, 6]
  end

  def test_rcwh_and_scroll
    assert_equal 0, @buff.r
    assert_equal 0, @buff.c
    assert_equal 5, @buff.w
    assert_equal 6, @buff.h

    assert_equal 0, @buff.r
    assert_equal 0, @buff.c
    assert_equal 5, @buff.w
    assert_equal 6, @buff.h

    @buff.win_down!

    assert_equal 1, @buff.r
    assert_equal 0, @buff.c
    assert_equal 5, @buff.w
    assert_equal 6, @buff.h

    @buff.win_down!

    assert_equal 2, @buff.r
    assert_equal 0, @buff.c
    assert_equal 5, @buff.w
    assert_equal 6, @buff.h
  end

  def test_caret_and_manual_win_adjustments
    # upon initialization, visual caret is in top-left corner of win(dow),
    # adjusted for the line number display
    assert_equal [0, 0, 5, 6], @buff.win
    assert_equal [0, 0], @buff.caret

    # when the window moves to a place where the visual caret is no longer in
    # the window, the visual caret moves with the top-left corner of the
    # win(dow), adjusted for the line number display
    @buff.win = [1, 1, 5, 6]
    assert_equal [1, 1, 5, 6], @buff.win
    assert_equal [1, 1], @buff.caret

    # this reset of the visual caret applies across multiple moves
    @buff.win = [2, 2, 5, 6]
    assert_equal [2, 2, 5, 6], @buff.win
    assert_equal [2, 2], @buff.caret

    # when the caret position doesn't need to be updated, but the window moves,
    # then the visual caret location may move with it
    @buff.win = [0, 0, 5, 6]
    assert_equal [0, 0, 5, 6], @buff.win
    assert_equal [2, 2], @buff.caret
  end

  def test_caret_and_relative_win_adjustments
    # upon initialization, visual caret is in top-left corner of win(dow),
    # adjusted for the line number display
    assert_equal [0, 0, 5, 6], @buff.win
    assert_equal [0, 0], @buff.caret

    # when the window moves to a place where the visual caret is no longer in
    # the window, the visual caret moves with the top-left corner of the
    # win(dow), adjusted for the line number display
    @buff.win_down!
    assert_equal [0, 1, 5, 6], @buff.win
    assert_equal [0, 1], @buff.caret

    # this reset of the visual caret applies across multiple moves
    @buff.win_right!
    assert_equal [1, 1, 5, 6], @buff.win
    assert_equal [1, 1], @buff.caret

    # when the caret position doesn't need to be updated, but the window moves,
    # then the visual caret location may move with it
    @buff.win_up!
    assert_equal [1, 0, 5, 6], @buff.win
    assert_equal [1, 1], @buff.caret

    @buff.win_left!
    assert_equal [0, 0, 5, 6], @buff.win
    assert_equal [1, 1], @buff.caret
  end

  def test_visual_caret_with_manual_wins_adjust
    # upon initialization, caret is in top-left corner of win(dow)
    assert_equal [0, 0, 5, 6], @buff.win
    assert_equal [2, 0], @buff.visual_caret
    assert_equal 2, @buff.line_no_width + 1

    # when the window moves to a place where the caret is no longer in the
    # window, the caret moves with the top-left corner of the win(dow)
    @buff.win = [1, 1, 5, 6]
    assert_equal [1, 1, 5, 6], @buff.win
    assert_equal [2, 0], @buff.visual_caret
    assert_equal 2, @buff.line_no_width + 1

    # this reset of the caret applies across multiple moves
    @buff.win = [2, 2, 5, 6]
    assert_equal [2, 2, 5, 6], @buff.win
    assert_equal [2, 0], @buff.visual_caret
    assert_equal 2, @buff.line_no_width + 1

    # if the window moves but the caret's position stays within the window,
    # then the caret doesn't move
    @buff.win = [0, 0, 5, 6]
    assert_equal [0, 0, 5, 6], @buff.win
    assert_equal [4, 2], @buff.visual_caret
    assert_equal 2, @buff.line_no_width + 1
  end

  def test_visual_caret_with_win_up_down_left_right
    # upon initialization, caret is in top-left corner of win(dow)
    assert_equal [0, 0, 5, 6], @buff.win
    assert_equal [2, 0], @buff.visual_caret
    assert_equal 2, @buff.line_no_width + 1

    # when the windows moves down one step, the visual caret stays in the
    # top-left corner
    @buff.win_down!
    assert_equal [0, 1, 5, 6], @buff.win
    assert_equal [2, 0], @buff.visual_caret
    assert_equal 2, @buff.line_no_width + 1

    # when the window moves right one step, the visual caret stays in the
    # top-left corner
    @buff.win_right!
    assert_equal [1, 1, 5, 6], @buff.win
    assert_equal [2, 0], @buff.visual_caret
    assert_equal 2, @buff.line_no_width + 1

    # when the window moves back up and to the left, the visual caret stays
    # over the same logical caret place
    @buff.win_up!
    assert_equal [1, 0, 5, 6], @buff.win
    assert_equal [2, 1], @buff.visual_caret
    assert_equal 2, @buff.line_no_width + 1

    @buff.win_left!
    assert_equal [0, 0, 5, 6], @buff.win
    assert_equal [3, 1], @buff.visual_caret
    assert_equal 2, @buff.line_no_width + 1
  end

  def test_substr_with_color
    input = "\e[31mHello \e[32mWorld\e[0m!\n"
    #                              1     11   indexes of printable characters
    #              012345      67890     12
    assert_equal "\e[31m\e[32morld\e[0m", @buff.substr_with_color(input, 7, 10)
    assert_equal "\e[31mlo \e[32mW\e[0m", @buff.substr_with_color(input, 3, 6)
    assert_equal "\e[31m\e[32morld\e[0m!\e[0m", @buff.substr_with_color(input, 7, 99)
  end

  def test_visible_lines
    assert_equal 3, @buff.visible_lines

    @buff.win_down!
    assert_equal 2, @buff.visible_lines

    @buff.win_down!
    assert_equal 1, @buff.visible_lines

    @buff.win_down! # cannot scroll past the last line
    assert_equal 1, @buff.visible_lines

    @buff.win = [0, 0, @buff.w, 1]
    assert_equal 1, @buff.visible_lines

    @buff.win_down!
    assert_equal 1, @buff.visible_lines

    @buff.win_down!
    assert_equal 1, @buff.visible_lines

    @buff.win_down! # cannot scroll past the last line
    assert_equal 1, @buff.visible_lines
  end

  def test_blank_lines
    assert_equal 3, @buff.blank_lines

    @buff.win_down!
    assert_equal 4, @buff.blank_lines

    @buff.win_down!
    assert_equal 5, @buff.blank_lines

    @buff.win_down! # cannot scroll past the last line
    assert_equal 5, @buff.blank_lines

    @buff.win = [0, 0, @buff.w, 1]
    assert_equal 0, @buff.r
    assert_equal 0, @buff.blank_lines

    @buff.win_down!
    assert_equal 1, @buff.r
    assert_equal 0, @buff.blank_lines

    @buff.win_down!
    assert_equal 2, @buff.r
    assert_equal 0, @buff.blank_lines

    @buff.win_down! # cannot scroll past the last line
    assert_equal 2, @buff.r
    assert_equal 0, @buff.blank_lines
  end

  def test_mark_and_unmark
    @buff.mark(:within_length_range, 3)
    assert_equal 3, @buff.marks[:within_length_range]

    @buff.mark(:outside_length_range, 99)
    assert_equal 18, @buff.marks[:outside_length_range]

    assert_nil @buff.marks[:invalid_mark]
    assert_equal({within_length_range: 3, outside_length_range: 18}, @buff.marks)

    @buff.unmark(:within_length_range)
    @buff.unmark(:outside_length_range)
    @buff.unmark(:invalid_mark)

    assert_nil @buff.marks[:within_length_range]
    assert_nil @buff.marks[:outside_length_range]
    assert_nil @buff.marks[:invalid_mark]
    assert_equal({}, @buff.marks)
  end

  def test_select_and_unselect
    assert_equal({}, @buff.selections)

    @buff.select(:sel1, 3..20)
    assert_equal({sel1: 3..20}, @buff.selections)

    @buff.select(:sel2, 4..15)
    assert_equal({sel1: 3..20, sel2: 4..15}, @buff.selections)

    @buff.unselect(:invalid_unselect)
    assert_equal({sel1: 3..20, sel2: 4..15}, @buff.selections)

    @buff.unselect(:sel1)
    assert_equal({sel2: 4..15}, @buff.selections)

    @buff.unselect(:sel2)
    assert_equal({}, @buff.selections)
  end
end
