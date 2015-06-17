defmodule Elirc.BucketList do
  def start_link(bucket, key) do
    GenServer.start_link(__MODULE__, [bucket, key])
  end

  def init([bucket, key]) do
    new(bucket)

    {:ok, [bucket, key]}
  end

  def new(bucket) do
    :ets.new(bucket, [
      :set,
      :named_table,
      :public,
      {:read_concurrency, true}
    ])
  end

  def terminate(reason, state) do
    delete(state.bucket)
    :ok
  end

  def handle_info({ :DOWN, _ref, :process, pid, _reason }, state) do
    # :ets.match_delete(state.bucket, { :_, pid })
    { :noreply, state }
  end


  def handle_call(:add, {value}, state) do
    add(value, state.bucket)

    {:reply, :ok, state}
  end

  def handle_call(:remove, {value}, state) do
    remove(value, state.bucket)

    {:reply, :ok, state}
  end

  def hash_value(value) do
    # Hashing with md5, possible mis-match on keys
    :crypto.hash(:md5, value)
  end

  def add(value, bucket) do
    {hash_value(value), value}
      |> put(bucket)
  end

  def remove(value, bucket) do 
    delete(hash_value(value), bucket)
  end

  def get(value, bucket) do 
    lookup(hash_value(value), bucket)
  end

  # ETS 
  def lookup(value, bucket) do
    :ets.lookup(bucket, value)
  end

  def put({key, value}, bucket) do
    :ets.insert(bucket, {key, value})
  end

  def delete(key, bucket) do
    :ets.delete(bucket, key)
  end

  def delete(bucket) do
    :ets.delete(bucket)
  end
end