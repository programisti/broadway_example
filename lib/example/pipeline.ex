defmodule Example.Pipeline do
   use Broadway

   alias Broadway.Message

   @queue_name "my_queue"

   def start_link(_opts) do
     Broadway.start_link(__MODULE__,
       name: __MODULE__,
       producer: [
         module: {BroadwayRabbitMQ.Producer,
           queue: @queue_name
         },
         transformer: {__MODULE__, :transform, []},
         concurrency: 2
       ],
       processors: [
         default: [
           concurrency: 50
         ]
       ],
       batchers: [
         default: [
           batch_size: 10,
           batch_timeout: 1500,
           concurrency: 5
         ]
       ]
     )
   end

   @impl true
   def handle_message(processor, %Message{data: data} = message, _context) do
     payload = Jason.decode!(data)
     message = message.update_data(message, &(Jason.decode(&1)))
     IO.inspect data, label: "received by processor - " <> to_string(processor) <> ", +++ message"

     message # return
   end

   @impl true
   def handle_batch(_, messages, _batch_info, _context) do
     list = messages |> Enum.map(fn e -> e.data end)
     IO.inspect(list, label: "Got batch")
     messages
   end

   def transform(event, _opts) do
     %Message{
       data: event,
       acknowledger: {__MODULE__, :ack_id, :ack_data}
     }
   end

   def ack(:ack_id, successful, failed) do
     # Write ack code here
     IO.inspect successful, label: "successful"
     IO.inspect failed, label: "failed"
   end
 end
