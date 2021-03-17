defmodule Servy.PledgeServer do
  use GenServer

  @process_name __MODULE__

  defmodule State do
    defstruct cache_size: 3, pledges: []
  end

  # Client interface

  def start do
    IO.puts "Starting the pledge server..."
    GenServer.start(__MODULE__, %State{}, name: @process_name)
  end

  def create_pledge(name, amount) do
    GenServer.call(@process_name, {:create_pledge, name, amount})
  end

  def recent_pledges do
    GenServer.call(@process_name, :recent_pledges)
  end

  def total_pledged do
    GenServer.call(@process_name, :total_pledged)
  end

  def clear do
    GenServer.cast(@process_name, :clear)
  end

  def set_cache_size(size) do
    GenServer.cast @process_name, {:set_cache_size, size}
  end

  # Server

  # Not required, but we override this method from GenServer
  # to prepopulate our state.
  def init(state) do
    pledges = fetch_recent_pledges_from_service()
    new_state = %{state | pledges: pledges}

    {:ok, new_state}
  end

  def handle_cast(:clear, state) do
    {:noreply, %{ state | pledges: [] }}
  end

  def handle_cast({:set_cache_size, size}, state) do
    resized_cache = Enum.take(state.pledges, size)
    new_state = %{state | cache_size: size, pledges: resized_cache}
    
    {:noreply, new_state}
  end

  def handle_call(:total_pledged, _from, state) do
    total = Enum.map(state.pledges, &elem(&1, 1)) |> Enum.sum
    
    {:reply, total, state}
  end

  def handle_call(:recent_pledges, _from, state) do
    {:reply, state.pledges, state}
  end

  def handle_call({:create_pledge, name, amount}, _from, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent_pledges = Enum.take(state.pledges, state.cache_size - 1)
    cached_pledges = [{name, amount} | most_recent_pledges]
    new_state = %{state | pledges: cached_pledges}

    {:reply, id, new_state}
  end

  # Not required, but here you can override how the server handles
  # unexpected messages.
  def handle_info(message, state) do
    IO.puts "The server doesn't know how to handle #{inspect message}"
    
    {:noreply, state}
  end

  defp send_pledge_to_service(_name, _amount) do
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

  defp fetch_recent_pledges_from_service do
    [ {"wilma", 15}, {"fred", 25} ]
  end
end

#{:ok, pid} = Servy.PledgeServer.start()

#send pid, {:stop, "uga buga"}

#Servy.PledgeServer.set_cache_size(4)

#IO.inspect Servy.PledgeServer.create_pledge("larry", 10)
#IO.inspect Servy.PledgeServer.create_pledge("moe", 20)
#IO.inspect Servy.PledgeServer.create_pledge("homer", 30)
#IO.inspect Servy.PledgeServer.create_pledge("lisa", 40)
#IO.inspect Servy.PledgeServer.create_pledge("harry o potter", 50)

#Servy.PledgeServer.clear()

#IO.inspect Servy.PledgeServer.recent_pledges()

#IO.inspect Servy.PledgeServer.total_pledged()
