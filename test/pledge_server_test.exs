defmodule PledgeServerTest do
  use ExUnit.Case

  import Servy.Plugins, only: [write_emoji: 1]

  alias Servy.PledgeServerHandRolled

  test "caches the 3 most recent pledges and totals their amounts" do
    PledgeServerHandRolled.start()

    PledgeServerHandRolled.create_pledge("Moe", 10)
    PledgeServerHandRolled.create_pledge("Bart", 20)
    PledgeServerHandRolled.create_pledge("Liza", 30)
    PledgeServerHandRolled.create_pledge("Homer", 40)

    expected_result = [{"Homer", 40}, {"Liza", 30}, {"Bart", 20}]

    assert PledgeServerHandRolled.recent_pledges() == expected_result

    assert PledgeServerHandRolled.total_pledged() == 90
  end
end
