defmodule BucketListTest do
  alias Elirc.BucketList
  use ExUnit.Case

  @bucket :test_bucket
  setup do
    # BucketList.delete(@bucket)
    BucketList.new(@bucket)
    Application.stop(:elirc)
    :ok
  end

  @value "rockerBOO"
  test "add value to bucketlist" do 
    BucketList.add(@value, @bucket)

    expected = [{:crypto.hash(:md5, @value), @value}]
    
    assert expected == BucketList.get(@value, @bucket)
  end

  @value "remove-value"
  test "remove value from bucketlist" do 
    BucketList.add(@value, @bucket)

    expected = [{:crypto.hash(:md5, @value), @value}]

    assert BucketList.get(@value, @bucket) == expected

    assert BucketList.remove(@value, @bucket)
  
    expects = []

    assert BucketList.get(@value, @bucket) == expects

    :ok
  end

  def terminate(reason, state) do
    BucketList.delete(@bucket)
    :ok
  end
end