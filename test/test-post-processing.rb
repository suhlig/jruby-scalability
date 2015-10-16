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

    assert_equal('1.05,1.56,2.08,1.57', line0)
    assert_equal('0.53,1.05,2.65,0.52', line1)
    assert_equal('1.57,2.13,2.13,0.53', line2)
  end
end
