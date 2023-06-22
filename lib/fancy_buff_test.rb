require 'minitest/autorun'
require_relative './fancy_buff'

class TestFancyBuff < Minitest::Test
  def setup
    @content = "line 1\nline 2\nline 3"
    @buff = FancyBuff.new(@content)
  end

  def test_length
    assert_equal 18, @buff.length
  end

  def test_lines
    assert_equal 3, @buff.lines
  end

  def test_range
    assert_equal ['line 2', 'line 3'], @buff[1..2]
  end

  def test_rect
    assert_equal ['e 1', 'e 2', 'e 3'], @buff.rect(3, 0, 3, 3)
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

  def test_insert_line
    assert_equal ['line 1', 'line 2', 'line 3'], @buff[0..5]

    @buff.insert_line(1, 'line X')
    assert_equal ['line 1', 'line X', 'line 2', 'line 3'], @buff[0..5]

    @buff.insert_line(99, 'line Y')
    assert_equal ['line 1', 'line X', 'line 2', 'line 3', 'line Y'], @buff[0..5]
  end
end
