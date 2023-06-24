require 'minitest/autorun'
require_relative './fancy_buff'

class TestFancyBuff < Minitest::Test
  def setup
    @content = "line 1\nline 2\nline 3"
    @buff = FancyBuff.new
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

    @buff.win_down

#    assert_equal 1, @buff.r
#    assert_equal 0, @buff.c
#    assert_equal 5, @buff.w
#    assert_equal 6, @buff.h
#
#    @buff.win_down
#
#    assert_equal 2, @buff.r
#    assert_equal 0, @buff.c
#    assert_equal 5, @buff.w
#    assert_equal 6, @buff.h
  end

  def test_visible_lines
    assert_equal 3, @buff.visible_lines

    @buff.win_down
    assert_equal 2, @buff.visible_lines

    @buff.win_down
    assert_equal 1, @buff.visible_lines

    @buff.win_down  # cannot scroll past the last line
    assert_equal 1, @buff.visible_lines

    @buff.win = [0, 0, @buff.w, 1]
    assert_equal 1, @buff.visible_lines

    @buff.win_down
    assert_equal 1, @buff.visible_lines

    @buff.win_down
    assert_equal 1, @buff.visible_lines

    @buff.win_down  # cannot scroll past the last line
    assert_equal 1, @buff.visible_lines
  end

  def test_blank_lines
    assert_equal 3, @buff.blank_lines

    @buff.win_down
    assert_equal 4, @buff.blank_lines

    @buff.win_down
    assert_equal 5, @buff.blank_lines

    @buff.win_down # cannot scroll past the last line
    assert_equal 5, @buff.blank_lines

    @buff.win = [0, 0, @buff.w, 1]
    assert_equal 0, @buff.r
    assert_equal 0, @buff.blank_lines

    @buff.win_down
    assert_equal 1, @buff.r
    assert_equal 0, @buff.blank_lines

    @buff.win_down
    assert_equal 2, @buff.r
    assert_equal 0, @buff.blank_lines

    @buff.win_down # cannot scroll past the last line
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
