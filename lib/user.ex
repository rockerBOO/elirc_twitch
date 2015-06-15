# defmodule Elirc.User 
# 	@doc """
# 	Manages User list in the channel
# 	"""
# 	def init(:ok) 
#     @doc """ 
#     """
#     ets = :ets.new(@ets_registry_name,
#                  [:set, :public, :named_table, {:read_concurrency, true}])

#     children = [

#     ]

#     supervise(children, strategy: :one_for_one)
#   end
# end