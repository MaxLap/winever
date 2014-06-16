require 'test_helper'

describe Winever::CronTime do

  it "must support daily jobs with single specific time" do
    Winever::CronTime.new('12 10 * * *').supported?.must_equal true
  end

  it "must only support 5 time parts" do
    Winever::CronTime.new('12 10 * *').supported?.must_equal false
    Winever::CronTime.new('12 10 * * * *').supported?.must_equal false
  end

  it "must return a trigger" do
    skip unless windows?
    Winever::CronTime.new('12 10 * * *').triggers.size.must_equal 1
  end

  describe "current limitations" do
    it "doesn't currently support daily jobs without single specific time" do
      Winever::CronTime.new('12 10,20 * * *').supported?.must_equal false
      Winever::CronTime.new('*/2 10 * * *').supported?.must_equal false
    end

    it "doesn't support jobs that are not daily" do
      Winever::CronTime.new('12 10 1 * *').supported?.must_equal false
      Winever::CronTime.new('12 10 */2 * *').supported?.must_equal false
      Winever::CronTime.new('12 10 3,4,5 * *').supported?.must_equal false

      Winever::CronTime.new('12 10 * 1 *').supported?.must_equal false
      Winever::CronTime.new('12 10 * */2 *').supported?.must_equal false
      Winever::CronTime.new('12 10 * 3,4,5 *').supported?.must_equal false

      Winever::CronTime.new('12 10 * * 1').supported?.must_equal false
      Winever::CronTime.new('12 10 * * */2').supported?.must_equal false
      Winever::CronTime.new('12 10 * * 3,4,5').supported?.must_equal false
    end
  end


end