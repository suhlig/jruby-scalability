require 'minitest/autorun'

class TestPostProcessing < MiniTest::Test
  def test_sample
    input_file_name = 'test/fixtures/cpu-load.log.api_z1.0'
    fixture = File.read('test/fixtures/cpu-load.csv')

    result = %x{bin/post-process-cpu #{input_file_name}}

    fail "Execution failed" unless $?.success?

    lines = result.lines
    line0 = lines[0].chomp
    line1 = lines[1].chomp
    line2 = lines[2].chomp
    line3 = lines[3].chomp

    assert_equal('19.54', line0)
    assert_equal('21.34', line1)
    assert_equal('21.20', line2)
    assert_equal('21.90', line3)
    assert_equal('21.57', line4)
  end
end
