defmodule Servy.SensorServer do
  @process_name :sensor_server

  use GenServer

  defmodule State do
    defstruct refresh_interval: 60
  end

  # Client Interface

  def start_link(interval \\ 60) do
    IO.puts "Starting the sensor server (interval #{interval})"

    initial_state = %State{refresh_interval: interval}

    GenServer.start_link(__MODULE__, initial_state, name: @process_name)
  end

  def get_sensor_data do
    GenServer.call @process_name, :get_sensor_data
  end

  # Server Callbacks

  def init(state) do
    initial_state = run_tasks_to_get_sensor_data()
    schedule_refresh(state.refresh_interval)

    {:ok, initial_state}
  end

  def handle_info(:refresh, state) do
    IO.puts "Refreshing the cache..."
    
    new_state = run_tasks_to_get_sensor_data()
    
    schedule_refresh(state.refresh_interval)

    {:noreply, new_state}
  end

  def handle_info(unexpected, state) do
    IO.puts "Server doesnt know how to handle #{inspect unexpected}"
    
    {:noreply, state}
  end

  defp schedule_refresh(interval) do
    Process.send_after(self(), :refresh, :timer.minutes(interval))
  end

  def handle_call(:get_sensor_data, _from, state) do
    {:reply, state, state}
  end

  defp run_tasks_to_get_sensor_data do
    IO.puts "Running tasks to get sensor data..."

    task = Task.async(fn -> Servy.Tracker.get_location("bigfoot") end)

    snapshots =
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Task.async(fn -> Servy.VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Task.await/1)

    where_is_bigfoot = Task.await(task)

    %{snapshots: snapshots, location: where_is_bigfoot}
  end
end
