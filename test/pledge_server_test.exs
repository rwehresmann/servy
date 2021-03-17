defmodule PledgeServerTest do
  use ExUnit.Case

  import Servy.Plugins, only: [write_emoji: 1]

  alias Servy.PledgeServer

  test "caches the 3 most recent pledges and totals their amounts" do
    PledgeServer.start()

    PledgeServer.create_pledge("Moe", 10)
    PledgeServer.create_pledge("Bart", 20)
    PledgeServer.create_pledge("Liza", 30)
    PledgeServer.create_pledge("Homer", 40)

    expected_result = [{"Homer", 40}, {"Liza", 30}, {"Bart", 20}]

    assert PledgeServer.recent_pledges() == expected_result

    assert PledgeServer.total_pledged() == 90
  end
end
