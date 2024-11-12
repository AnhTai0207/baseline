# defmodule Socket.Application do

#     @moduledoc false

#     use Application

#     def start(_type, _args) do
#       children = [
#         Socket.Websocket
#       ]


#       opts = [strategy: :one_for_all, name: Socket.Supervisor]
#       Supervisor.start_link(children, opts)
#     end
#   end
