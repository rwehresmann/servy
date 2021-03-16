defmodule Servy.Reminder do
  def remind(message, seconds) do
    spawn(fn -> 
      :timer.sleep(seconds * 1000) 
      IO.puts(message)
    end)
  end
end
