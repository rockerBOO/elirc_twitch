defmodule Elirc.BucketList do
  def new(bucket) do
    :ets.new(String.to_atom(bucket), [
      :ordered_set,
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

  def handle_call(:add, {[_] = values}, state) do
    add_many(values, state.bucket)

    :ok
  end

  def add_many([values], bucket) do
    values 
      |> Enum.each(fn (value) 
        -> add(value, bucket) end)
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
      |> Base.encode16
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

  def get_all(bucket) do
    debug "Get all results from ", bucket
    :ets.match(bucket, :"$1")
  end

  # ETS 
  def lookup(value, bucket) do
    :ets.lookup(bucket, value)
  end

  def put({key, value}, bucket) do
    debug "Inserting {#{key}, #{value}} to bucket ", bucket
    :ets.insert(bucket, {key, value})
  end

  def delete(key, bucket) do
    debug "Deleting #{key} from bucket ", bucket
    :ets.delete(bucket, key)
  end

  def delete(bucket) do
    debug "Deleting entire bucket ", bucket
    :ets.delete(bucket)
  end

  def debug(msg, bucket) do
    IO.puts msg <> Atom.to_string(bucket)
  end
end