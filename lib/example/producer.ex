defmodule Producer do
  @moduledoc false

  @queue_name "my_queue"

  def dispatch do
    {:ok, connection} = AMQP.Connection.open()
    {:ok, channel} = AMQP.Channel.open(connection)
    AMQP.Queue.declare(channel, @queue_name, durable: true)

    Enum.each(1..100, fn symbol ->
      write_queue(channel, symbol)
    end)

    AMQP.Connection.close(connection)
  end

  defp write_queue(channel, symbol) do
    AMQP.Basic.publish(channel, "", @queue_name, symbol)
  end
end
