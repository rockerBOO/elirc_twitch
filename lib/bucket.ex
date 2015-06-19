defmodule Elirc.Bucket do
  def get(bucket, key) do
    :ets.lookup(bucket, key)
  end

  def put(bucket, key, value) do
    :ets.insert(bucket, {key, value})
  end

  def delete(bucket, key) do
    :ets.delete(bucket, key)
  end
end