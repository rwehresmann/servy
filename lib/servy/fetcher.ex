defmodule Servy.Fetcher do
  def async(fun) do
    caller = self()
      
    spawn(fn -> send(caller, {self(), :result, fun.()}) end)
  end

  def get_result(pid) do
    receive do 
      {^pid, :result, value} -> value 
    after 2000 ->
      raise "Timed out!"
    end
  end
end
