defmodule Servy.BearController do
  require Logger

  import Servy.View, only: [render: 3]

  alias Servy.Wildthings
  alias Servy.Bear
  alias Servy.BearView

  def index(conv) do
    bears = 
      Wildthings.list_bears()
      |> Enum.sort(&Bear.order_asc_by_name(&1, &2))

    render(conv, &BearView.index/1, bears)
  end

  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)

    render(conv, &BearView.show/1, bear)
  end

  def create(conv, %{"name" => name, "type" => type}) do
    %{ conv | status: 201, resp_body: "Created a #{type} bear named #{name}."}
  end

  def destroy(conv, _params) do
    msg = "Deleting a bear is forbidden."
    Logger.warn(msg)
    %{ conv | status: 403, resp_body: "Deleting a bear is forbidden." }
  end
end

