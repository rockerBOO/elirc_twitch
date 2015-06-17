# defmodule Elirc.BucketList do
#   def start_link(bucket, key) do
#     GenServer.start_link(__MODULE__, [bucket, key])
#   end

#   def init([bucket, key]) do
#     new(bucket)

#     {:ok, [bucket, key]}
#   end

#   def new(bucket) do
#     :ets.new(bucket, [
#       :set,
#       :named_table,
#       :public,
#       :read_concurrency
#     ])
#   end

#   def terminate(reason, state) do
#     delete(state.bucket)
#     :ok
#   end

#   def handle_call(:add, {value}, state) do
#     add(state.bucket, state.key, value)

#     {:reply, :ok, state}
#   end

#   def handle_call(:remove, {value}, state) do
#     remove(value, state.bucket, state.key)

#     {:reply, :ok, state}
#   end

#   # add value to list
#   def add(value, bucket, key) do
#     results = get(bucket, key)

#     IO.inspect results

#     results = Enum.into(results, value)

#     put(bucket, {key, results})
#   end

#   # remove value from list
#   def remove(value, bucket, key) do
#     results = get(bucket, key)

#     # remove value from list
#     results = Enum.filter(results, fn(x) -> x != value end)

#     put_result = put(bucket, {key, results})

#     {:ok, results}
#   end

#   def get(bucket, key) do
#     :ets.lookup(bucket, key)
#   end

#   def put(bucket, {key, value}) do
#     :ets.insert(bucket, {key, value})
#   end

#   def delete(bucket, key) do
#     :ets.delete(bucket, key)
#   end

#   def delete(bucket) do
#     :ets.delete(bucket)
#   end
# end